import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'native_channel.dart';
import 'path_constants.dart';
import 'result.dart';

class AudiowmarkService {
  Process? _activeProcess;

  /// Kills currently running audiowmark process if active
  void cancelCurrent() {
    final Process? proc = _activeProcess;
    if (proc != null) {
      try {
        proc.kill(ProcessSignal.sigkill);
      } catch (_) {}
      _activeProcess = null;
    }
  }

  /// Resolves the absolute path to libaudiowmark.so in nativeLibraryDir
  Future<Result<String>> _getBinaryPath() async {
    final Result<String> nativeDirRes =
        await NativeChannel.getNativeLibraryDir();
    if (nativeDirRes.isError) {
      return failure(nativeDirRes.error!);
    }
    final String binaryPath = p.join(nativeDirRes.value!, 'libaudiowmark.so');
    final File binFile = File(binaryPath);
    if (!await binFile.exists()) {
      return failure('Бинарный файл audiowmark не найден: $binaryPath');
    }
    return success(binaryPath);
  }

  /// Internal process runner with stdout/stderr capture and cancellation support
  Future<Result<String>> _runCommand(List<String> args) async {
    final Result<String> binRes = await _getBinaryPath();
    if (binRes.isError) {
      return failure(binRes.error!);
    }
    final String binaryPath = binRes.value!;
    final String docsDir = await PathConstants.getDocsDir();

    try {
      final Process process = await Process.start(
        binaryPath,
        args,
        workingDirectory: docsDir,
      );
      _activeProcess = process;

      final StringBuffer stdoutBuf = StringBuffer();
      final StringBuffer stderrBuf = StringBuffer();

      process.stdout
          .transform(utf8.decoder)
          .listen((data) => stdoutBuf.write(data));
      process.stderr
          .transform(utf8.decoder)
          .listen((data) => stderrBuf.write(data));

      final int exitCode = await process.exitCode;
      _activeProcess = null;

      final String stdoutStr = stdoutBuf.toString();
      final String stderrStr = stderrBuf.toString().trim();

      if (exitCode != 0) {
        if (stderrStr.isNotEmpty) {
          return failure(stderrStr);
        }
        return failure('Код ошибки audiowmark: $exitCode');
      }

      return success(stdoutStr);
    } catch (e) {
      _activeProcess = null;
      return failure('Сбой выполнения audiowmark: $e');
    }
  }

  /// Generates a new key: ["gen-key", "keys/$fileName", "--name", name]
  Future<Result<void>> genKey(
      {required String fileName, required String name}) async {
    final List<String> args = [
      'gen-key',
      'keys/$fileName',
      '--name',
      name,
    ];
    final Result<String> res = await _runCommand(args);
    if (res.isError) {
      return failure(res.error!);
    }

    final String docsDir = await PathConstants.getDocsDir();
    final File keyFile = File(p.join(docsDir, 'keys/$fileName'));
    if (!await keyFile.exists()) {
      return failure('Файл ключа не был создан');
    }

    return success(null);
  }

  /// Embeds watermark: ["add", "in.wav", "out.wav", "--key", keyPath, hash32]
  Future<Result<void>> add({
    required String inWav,
    required String outWav,
    required String keyPath,
    required String hash32,
  }) async {
    final List<String> args = [
      'add',
      inWav,
      outWav,
      '--key',
      keyPath,
      hash32,
    ];
    final Result<String> res = await _runCommand(args);
    if (res.isError) {
      return failure(res.error!);
    }

    final String docsDir = await PathConstants.getDocsDir();
    final File outFile = File(p.join(docsDir, outWav));
    if (!await outFile.exists()) {
      return failure('Файл out.wav не был создан');
    }

    return success(null);
  }

  /// Scans watermark: ["get", "in.wav", "--key", key1, ...]
  Future<Result<List<String>>> get({
    required String inWav,
    required List<String> keyPaths,
    bool patient = false,
  }) async {
    if (keyPaths.isEmpty) {
      return failure('Нет доступных ключей для сканирования');
    }

    final List<String> args = ['get', inWav];
    for (final String k in keyPaths) {
      args.addAll(['--key', k]);
    }
    if (patient) {
      args.addAll(['--detect-speed-patient', '--n-best', '32']);
    }

    final Result<String> res = await _runCommand(args);
    if (res.isError) {
      return failure(res.error!);
    }

    final List<String> hashes = parsePatternHashes(res.value!);
    return success(hashes);
  }

  /// Parses stdout lines starting with "pattern" to extract 32-hex hashes
  static List<String> parsePatternHashes(String stdout) {
    final List<String> result = [];
    final List<String> lines = stdout.split('\n');
    final RegExp hashRegex = RegExp(r'^[0-9a-f]{32}$');

    for (final String line in lines) {
      final String trimmed = line.trim();
      if (!trimmed.startsWith('pattern')) {
        continue;
      }
      // pattern <timestamp/all> <hash32> <score...>
      final List<String> parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        final String hashCandidate = parts[2].toLowerCase();
        if (hashRegex.hasMatch(hashCandidate)) {
          if (!result.contains(hashCandidate)) {
            result.add(hashCandidate);
          }
        }
      }
    }
    return result;
  }
}

/// Audiowmark wrapper alias as specified in the architecture specification
typedef Audiowmark = AudiowmarkService;
