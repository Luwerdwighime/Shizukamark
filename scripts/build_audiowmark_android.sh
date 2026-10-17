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

SRC_DIR="$BUILD_DIR/sources"
mkdir -p "$SRC_DIR"

FFTW_VER="3.3.10"
SNDFILE_VER="1.2.2"
MPG123_VER="1.32.7"
GPG_ERROR_VER="1.49"
GCRYPT_VER="1.10.3"
ZITA_VER="1.11.2"

cd "$SRC_DIR"

# 1. Download FFTW
if [ ! -d "fftw-$FFTW_VER" ]; then
    echo "=== Downloading FFTW $FFTW_VER ==="
    curl -sSL "https://www.fftw.org/fftw-$FFTW_VER.tar.gz" || \
    curl -sSL "http://www.fftw.org/fftw-$FFTW_VER.tar.gz" | tar -xz
fi

# 2. Download libsndfile
if [ ! -d "libsndfile-$SNDFILE_VER" ]; then
    echo "=== Downloading libsndfile $SNDFILE_VER ==="
    curl -sSL "https://github.com/libsndfile/libsndfile/releases/download/$SNDFILE_VER/libsndfile-$SNDFILE_VER.tar.xz" | tar -xJ
fi

# 3. Download mpg123
if [ ! -d "mpg123-$MPG123_VER" ]; then
    echo "=== Downloading mpg123 $MPG123_VER ==="
    curl -sSL "https://www.mpg123.de/download/mpg123-$MPG123_VER.tar.bz2" || \
    curl -sSL "https://downloads.sourceforge.net/project/mpg123/mpg123/$MPG123_VER/mpg123-$MPG123_VER.tar.bz2" | tar -xj
fi

# 4. Download libgpg-error
if [ ! -d "libgpg-error-$GPG_ERROR_VER" ]; then
    echo "=== Downloading libgpg-error $GPG_ERROR_VER ==="
    curl -sSL "https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-$GPG_ERROR_VER.tar.bz2" || \
    curl -sSL "https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-$GPG_ERROR_VER.tar.bz2" || \
    curl -sSL "https://mirrors.dotsrc.org/gnupg/libgpg-error/libgpg-error-$GPG_ERROR_VER.tar.bz2" | tar -xj
fi

# 5. Download libgcrypt
if [ ! -d "libgcrypt-$GCRYPT_VER" ]; then
    echo "=== Downloading libgcrypt $GCRYPT_VER ==="
    curl -sSL "https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$GCRYPT_VER.tar.bz2" || \
    curl -sSL "https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-$GCRYPT_VER.tar.bz2" || \
    curl -sSL "https://mirrors.dotsrc.org/gnupg/libgcrypt/libgcrypt-$GCRYPT_VER.tar.bz2" | tar -xj
fi

# 6. Download zita-resampler
if [ ! -d "zita-resampler-$ZITA_VER" ]; then
    echo "=== Downloading zita-resampler $ZITA_VER ==="
    curl -sSL "http://kokkinizita.linuxaudio.org/linuxaudio/downloads/zita-resampler-$ZITA_VER.tar.xz" | tar -xJ
fi

# 7. Clone audiowmark
if [ ! -d "audiowmark" ]; then
    echo "=== Cloning audiowmark ==="
    git clone --depth 1 https://github.com/swesterfeld/audiowmark.git audiowmark
fi

for ABI in "${ABIS[@]}"; do
    echo "=================================================="
    echo "=== Building for ABI: $ABI ==="
    echo "=================================================="

    PREFIX="$BUILD_DIR/prefix-$ABI"
    mkdir -p "$PREFIX/lib/pkgconfig" "$PREFIX/include"

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
    export LDFLAGS="-L$PREFIX/lib -static-libstdc++"

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

    # 2. Build libsndfile (minimal static)
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

    # 3. Build mpg123
    if [ ! -f "$PREFIX/lib/libmpg123.a" ]; then
        echo "--- Building mpg123 for $ABI ---"
        mkdir -p "$BUILD_DIR/mpg123-$ABI"
        cd "$BUILD_DIR/mpg123-$ABI"
        "$SRC_DIR/mpg123-$MPG123_VER/configure" \
            --host="$TARGET_HOST" \
            --prefix="$PREFIX" \
            --enable-static \
            --disable-shared \
            --disable-modules \
            --disable-network \
            --disable-output
        make -j"$(nproc)"
        make install
    fi

    # 4. Build libgpg-error (base dependency for libgcrypt)
    if [ ! -f "$PREFIX/lib/libgpg-error.a" ]; then
        echo "--- Building libgpg-error for $ABI ---"
        mkdir -p "$BUILD_DIR/gpg-error-$ABI"
        cd "$BUILD_DIR/gpg-error-$ABI"

        # Ensure lock-obj headers exist for Android targets
        mkdir -p "$SRC_DIR/libgpg-error-$GPG_ERROR_VER/src/syscfg"
        cp -n "$SRC_DIR/libgpg-error-$GPG_ERROR_VER/src/syscfg/lock-obj-pub.aarch64-unknown-linux-gnu.h" \
              "$SRC_DIR/libgpg-error-$GPG_ERROR_VER/src/syscfg/lock-obj-pub.aarch64-unknown-linux-android.h" 2>/dev/null || true
        cp -n "$SRC_DIR/libgpg-error-$GPG_ERROR_VER/src/syscfg/lock-obj-pub.x86_64-unknown-linux-gnu.h" \
              "$SRC_DIR/libgpg-error-$GPG_ERROR_VER/src/syscfg/lock-obj-pub.x86_64-unknown-linux-android.h" 2>/dev/null || true
        cp -n "$SRC_DIR/libgpg-error-$GPG_ERROR_VER/src/syscfg/lock-obj-pub.arm-unknown-linux-androideabi.h" \
              "$SRC_DIR/libgpg-error-$GPG_ERROR_VER/src/syscfg/lock-obj-pub.arm-unknown-linux-android.h" 2>/dev/null || true

        "$SRC_DIR/libgpg-error-$GPG_ERROR_VER/configure" \
            --host="$TARGET_HOST" \
            --prefix="$PREFIX" \
            --enable-static \
            --disable-shared \
            --disable-doc \
            --disable-tests \
            --disable-nls
        make -j"$(nproc)"
        make install
    fi

    # 5. Build libgcrypt
    if [ ! -f "$PREFIX/lib/libgcrypt.a" ]; then
        echo "--- Building libgcrypt for $ABI ---"
        mkdir -p "$BUILD_DIR/gcrypt-$ABI"
        cd "$BUILD_DIR/gcrypt-$ABI"
        "$SRC_DIR/libgcrypt-$GCRYPT_VER/configure" \
            --host="$TARGET_HOST" \
            --prefix="$PREFIX" \
            --with-libgpg-error-prefix="$PREFIX" \
            --enable-static \
            --disable-shared \
            --disable-doc \
            --disable-asm
        make -j"$(nproc)"
        make install
    fi

    # 6. Build zita-resampler (statically compiled for Android)
    if [ ! -f "$PREFIX/lib/libzita-resampler.a" ]; then
        echo "--- Building zita-resampler for $ABI ---"
        mkdir -p "$BUILD_DIR/zita-resampler-$ABI"
        cd "$BUILD_DIR/zita-resampler-$ABI"
        $CXX $CXXFLAGS -I"$SRC_DIR/zita-resampler-$ZITA_VER/source" \
            -c "$SRC_DIR/zita-resampler-$ZITA_VER/source/resampler.cc" \
               "$SRC_DIR/zita-resampler-$ZITA_VER/source/vresampler.cc" \
               "$SRC_DIR/zita-resampler-$ZITA_VER/source/resampler-table.cc" \
               "$SRC_DIR/zita-resampler-$ZITA_VER/source/cresampler.cc"
        $AR rcs "$PREFIX/lib/libzita-resampler.a" resampler.o vresampler.o resampler-table.o cresampler.o
        $RANLIB "$PREFIX/lib/libzita-resampler.a"
        mkdir -p "$PREFIX/include/zita-resampler"
        cp "$SRC_DIR/zita-resampler-$ZITA_VER/source/zita-resampler/"*.h "$PREFIX/include/zita-resampler/"

        # Generate zita-resampler.pc
        cat <<EOF > "$PREFIX/lib/pkgconfig/zita-resampler.pc"
prefix=$PREFIX
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: zita-resampler
Description: Fast, high quality sample rate conversion library
Version: $ZITA_VER
Libs: -L\${libdir} -lzita-resampler
Cflags: -I\${includedir}
EOF
    fi

    # 7. Build audiowmark
    echo "--- Building audiowmark for $ABI ---"
    mkdir -p "$BUILD_DIR/audiowmark-$ABI"
    cd "$BUILD_DIR/audiowmark-$ABI"

    if [ ! -f "$SRC_DIR/audiowmark/configure" ]; then
        cd "$SRC_DIR/audiowmark"
        autoreconf -f -i -Wno-portability
        cd "$BUILD_DIR/audiowmark-$ABI"
    fi

    export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
    export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
    export FFTW_CFLAGS="-I$PREFIX/include"
    export FFTW_LIBS="-L$PREFIX/lib -lfftw3f"
    export LIBSNDFILE_CFLAGS="-I$PREFIX/include"
    export LIBSNDFILE_LIBS="-L$PREFIX/lib -lsndfile"
    export LIBMPG123_CFLAGS="-I$PREFIX/include"
    export LIBMPG123_LIBS="-L$PREFIX/lib -lmpg123"
    export LIBGCRYPT_CFLAGS="-I$PREFIX/include"
    export LIBGCRYPT_LIBS="-L$PREFIX/lib -lgcrypt -lgpg-error"

    # Static link flags: place static libraries and runtime in LIBS so Automake puts them after objects
    export LIBS="-L$PREFIX/lib -lsndfile -lfftw3f -lmpg123 -lzita-resampler -lgcrypt -lgpg-error -static-libstdc++ -lm -ldl"

    "$SRC_DIR/audiowmark/configure" \
        --host="$TARGET_HOST" \
        --prefix="$PREFIX" \
        --enable-static \
        --disable-shared \
        --with-libgcrypt-prefix="$PREFIX" \
        --with-libzita-resampler-prefix="$PREFIX" \
        LIBS="$LIBS"

    make -j"$(nproc)" -C src audiowmark

    # Locate the executable (libtool may put the real ELF in .libs/)
    if [ -f "src/.libs/audiowmark" ]; then
        BIN="src/.libs/audiowmark"
    else
        BIN="src/audiowmark"
    fi

    DEST_DIR="$OUTPUT_DIR/$ABI"
    mkdir -p "$DEST_DIR"
    cp "$BIN" "$DEST_DIR/libaudiowmark.so"
    "$STRIP" "$DEST_DIR/libaudiowmark.so"
    chmod 755 "$DEST_DIR/libaudiowmark.so"
    echo "Successfully built $DEST_DIR/libaudiowmark.so"
done

echo "=== All ABIs built successfully! ==="
