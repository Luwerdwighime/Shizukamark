#!/usr/bin/env bash
set -euo pipefail

# Build script for audiowmark and its dependencies for Android NDK
# Generates libaudiowmark.so for arm64-v8a, armeabi-v7a, and x86_64

NDK="${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-}}"
if [ -z "$NDK" ]; then
    echo "ERROR: ANDROID_NDK_HOME or ANDROID_NDK_ROOT must be set."
    exit 1
fi

API_LEVEL=24
HOST_TAG="linux-x86_64"
TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/$HOST_TAG"
SYSROOT="$TOOLCHAIN/sysroot"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build_native"
OUTPUT_DIR="$PROJECT_ROOT/android/app/src/main/jniLibs"

ABIS=("arm64-v8a" "armeabi-v7a" "x86_64")
if [ $# -gt 0 ]; then
    ABIS=("$@")
fi

mkdir -p "$BUILD_DIR"

# Download dependencies if needed
SRC_DIR="$BUILD_DIR/sources"
mkdir -p "$SRC_DIR"

FFTW_VER="3.3.10"
SAMPLERATE_VER="0.2.2"
SNDFILE_VER="1.2.2"
AUDIOWMARK_COMMIT="master"

cd "$SRC_DIR"

if [ ! -d "fftw-$FFTW_VER" ]; then
    echo "=== Downloading FFTW $FFTW_VER ==="
    curl -sSL "http://www.fftw.org/fftw-$FFTW_VER.tar.gz" | tar -xz
fi

if [ ! -d "libsamplerate-$SAMPLERATE_VER" ]; then
    echo "=== Downloading libsamplerate $SAMPLERATE_VER ==="
    curl -sSL "https://github.com/libsndfile/libsamplerate/releases/download/$SAMPLERATE_VER/libsamplerate-$SAMPLERATE_VER.tar.xz" | tar -xJ
fi

if [ ! -d "libsndfile-$SNDFILE_VER" ]; then
    echo "=== Downloading libsndfile $SNDFILE_VER ==="
    curl -sSL "https://github.com/libsndfile/libsndfile/releases/download/$SNDFILE_VER/libsndfile-$SNDFILE_VER.tar.xz" | tar -xJ
fi

if [ ! -d "audiowmark" ]; then
    echo "=== Cloning audiowmark ==="
    git clone --depth 1 https://github.com/swesterfeld/audiowmark.git audiowmark
fi

for ABI in "${ABIS[@]}"; do
    echo "=================================================="
    echo "=== Building for ABI: $ABI ==="
    echo "=================================================="

    PREFIX="$BUILD_DIR/prefix-$ABI"
    mkdir -p "$PREFIX"

    case "$ABI" in
        arm64-v8a)
            TARGET_HOST="aarch64-linux-android"
            CLANG_TARGET="aarch64-linux-android$API_LEVEL"
            ;;
        armeabi-v7a)
            TARGET_HOST="armv7a-linux-androideabi"
            CLANG_TARGET="armv7a-linux-androideabi$API_LEVEL"
            ;;
        x86_64)
            TARGET_HOST="x86_64-linux-android"
            CLANG_TARGET="x86_64-linux-android$API_LEVEL"
            ;;
        *)
            echo "Unknown ABI: $ABI"
            exit 1
            ;;
    esac

    export CC="$TOOLCHAIN/bin/${CLANG_TARGET}-clang"
    export CXX="$TOOLCHAIN/bin/${CLANG_TARGET}-clang++"
    export AR="$TOOLCHAIN/bin/llvm-ar"
    export AS="$TOOLCHAIN/bin/llvm-as"
    export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"
    export STRIP="$TOOLCHAIN/bin/llvm-strip"
    export CFLAGS="-fPIC -O3 -I$PREFIX/include"
    export CXXFLAGS="-fPIC -O3 -I$PREFIX/include"
    export LDFLAGS="-L$PREFIX/lib"

    # 1. Build FFTW (single precision for audiowmark)
    if [ ! -f "$PREFIX/lib/libfftw3f.a" ]; then
        echo "--- Building FFTW for $ABI ---"
        mkdir -p "$BUILD_DIR/fftw-$ABI"
        cd "$BUILD_DIR/fftw-$ABI"
        "$SRC_DIR/fftw-$FFTW_VER/configure" \
            --host="$TARGET_HOST" \
            --prefix="$PREFIX" \
            --enable-static \
            --disable-shared \
            --enable-float \
            --disable-fortran
        make -j"$(nproc)"
        make install
    fi

    # 2. Build libsamplerate
    if [ ! -f "$PREFIX/lib/libsamplerate.a" ]; then
        echo "--- Building libsamplerate for $ABI ---"
        mkdir -p "$BUILD_DIR/samplerate-$ABI"
        cd "$BUILD_DIR/samplerate-$ABI"
        "$SRC_DIR/libsamplerate-$SAMPLERATE_VER/configure" \
            --host="$TARGET_HOST" \
            --prefix="$PREFIX" \
            --enable-static \
            --disable-shared
        make -j"$(nproc)"
        make install
    fi

    # 3. Build libsndfile (minimal, without external ogg/vorbis/flac for simplicity of static link)
    if [ ! -f "$PREFIX/lib/libsndfile.a" ]; then
        echo "--- Building libsndfile for $ABI ---"
        mkdir -p "$BUILD_DIR/sndfile-$ABI"
        cd "$BUILD_DIR/sndfile-$ABI"
        "$SRC_DIR/libsndfile-$SNDFILE_VER/configure" \
            --host="$TARGET_HOST" \
            --prefix="$PREFIX" \
            --enable-static \
            --disable-shared \
            --disable-external-libs
        make -j"$(nproc)"
        make install
    fi

    # 4. Build audiowmark
    echo "--- Building audiowmark for $ABI ---"
    mkdir -p "$BUILD_DIR/audiowmark-$ABI"
    cd "$BUILD_DIR/audiowmark-$ABI"

    # Audiowmark uses autotools or meson. If configure script is present:
    if [ ! -f "$SRC_DIR/audiowmark/configure" ]; then
        cd "$SRC_DIR/audiowmark"
        NOCONFIGURE=1 ./autogen.sh || autoreconf -fi
        cd "$BUILD_DIR/audiowmark-$ABI"
    fi

    export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
    export FFTW_CFLAGS="-I$PREFIX/include"
    export FFTW_LIBS="-L$PREFIX/lib -lfftw3f"
    export LIBSNDFILE_CFLAGS="-I$PREFIX/include"
    export LIBSNDFILE_LIBS="-L$PREFIX/lib -lsndfile"
    export SAMPLERATE_CFLAGS="-I$PREFIX/include"
    export SAMPLERATE_LIBS="-L$PREFIX/lib -lsamplerate"

    "$SRC_DIR/audiowmark/configure" \
        --host="$TARGET_HOST" \
        --prefix="$PREFIX" \
        --enable-static \
        --disable-shared

    make -j"$(nproc)"

    # Copy binary and name it libaudiowmark.so so Android extracts it to nativeLibraryDir
    DEST_DIR="$OUTPUT_DIR/$ABI"
    mkdir -p "$DEST_DIR"
    cp src/audiowmark "$DEST_DIR/libaudiowmark.so"
    "$STRIP" "$DEST_DIR/libaudiowmark.so"
    chmod 755 "$DEST_DIR/libaudiowmark.so"
    echo "Successfully built $DEST_DIR/libaudiowmark.so"
done

echo "=== All ABIs built successfully! ==="
