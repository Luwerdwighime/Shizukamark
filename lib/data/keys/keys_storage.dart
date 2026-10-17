import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import '../../core/audiowmark_service.dart';
import '../../core/path_constants.dart';
import '../../core/result.dart';
import '../../domain/models/key_info.dart';

class KeysStorage {
  final AudiowmarkService _audiowmarkService;

  KeysStorage({AudiowmarkService? audiowmarkService})
      : _audiowmarkService = audiowmarkService ?? AudiowmarkService();

  /// Ensures keys directory exists with proper permissions
  Future<Directory> getKeysDirectory() async {
    final String keysPath = await PathConstants.getKeysDir();
    final Directory dir = Directory(keysPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      try {
        if (!Platform.isWindows) {
          await Process.run('chmod', ['770', dir.path]);
        }
      } catch (_) {}
    }
    return dir;
  }

  /// Generates a unique 8 lowercase hex filename (SHA-256 of 16 random bytes)
  Future<String> generateUniqueKeyFileName() async {
    final Directory dir = await getKeysDirectory();
    final Random random = Random.secure();

    while (true) {
      final List<int> randomBytes =
          List<int>.generate(16, (_) => random.nextInt(256));
      final String fullHash = sha256.convert(randomBytes).toString();
      final String shortHex = fullHash.substring(0, 8).toLowerCase();
      final String fileName = '$shortHex.key';
      final File file = File(p.join(dir.path, fileName));
      if (!await file.exists()) {
        return fileName;
      }
    }
  }

  /// Parses key name and key hex from a .key file
  static ({String name, String? hexKey}) parseKeyFile(String content) {
    String name = '';
    String? hexKey;

    final List<String> lines = content.split('\n');
    for (final String line in lines) {
      final String trimmed = line.trim();
      if (trimmed.startsWith('name')) {
        // Line format: name "Some Name"
        final int firstQuote = trimmed.indexOf('"');
        final int lastQuote = trimmed.lastIndexOf('"');
        if (firstQuote != -1 && lastQuote > firstQuote) {
          name = trimmed.substring(firstQuote + 1, lastQuote);
        }
      } else if (trimmed.startsWith('key')) {
        // Line format: key 0123456789abcdef...
        final List<String> parts = trimmed.split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          hexKey = parts[1].trim();
        }
      }
    }
    return (name: name, hexKey: hexKey);
  }

  /// Lists all keys sorted alphabetically, with unnamed keys at the end
  Future<Result<List<KeyInfo>>> listKeys() async {
    try {
      final Directory dir = await getKeysDirectory();
      final List<FileSystemEntity> entities = await dir.list().toList();
      final List<KeyInfo> result = [];

      for (final FileSystemEntity entity in entities) {
        if (entity is File && entity.path.endsWith('.key')) {
          final String content = await entity.readAsString();
          final parsed = parseKeyFile(content);
          final String relPath = 'keys/${p.basename(entity.path)}';
          result.add(KeyInfo(name: parsed.name, keyPath: relPath));
        }
      }

      // Sort alphabetically, empty/unnamed names placed at the end
      result.sort((a, b) {
        if (a.name.isEmpty && b.name.isEmpty) {
          return a.keyPath.compareTo(b.keyPath);
        }
        if (a.name.isEmpty) return 1;
        if (b.name.isEmpty) return -1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return success(result);
    } catch (e) {
      return failure('Ошибка чтения каталога ключей: $e');
    }
  }

  /// Creates a new key with given name using audiowmark gen-key
  Future<Result<KeyInfo>> createKey(String name) async {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.length > 128) {
      return failure('Имя ключа должно содержать от 1 до 128 символов');
    }

    try {
      final String fileName = await generateUniqueKeyFileName();
      final Result<void> genRes = await _audiowmarkService.genKey(
        fileName: fileName,
        name: trimmedName,
      );

      if (genRes.isError) {
        return failure(genRes.error!);
      }

      final String relPath = 'keys/$fileName';
      return success(KeyInfo(name: trimmedName, keyPath: relPath));
    } catch (e) {
      return failure('Ошибка создания ключа: $e');
    }
  }

  /// Deletes key file by its relative or absolute path
  Future<Result<void>> deleteKey(String keyPath) async {
    try {
      final String docs = await PathConstants.getDocsDir();
      final String fullPath =
          p.isAbsolute(keyPath) ? keyPath : p.join(docs, keyPath);
      final File file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
      }
      return success(null);
    } catch (e) {
      return failure('Ошибка удаления ключа: $e');
    }
  }

  /// Checks if a key with matching hex value already exists in the keys directory
  Future<bool> hasKeyWithHex(String hexKey) async {
    try {
      final Directory dir = await getKeysDirectory();
      final List<FileSystemEntity> entities = await dir.list().toList();
      for (final FileSystemEntity entity in entities) {
        if (entity is File && entity.path.endsWith('.key')) {
          final String content = await entity.readAsString();
          final parsed = parseKeyFile(content);
          if (parsed.hexKey != null &&
              parsed.hexKey!.toLowerCase() == hexKey.toLowerCase()) {
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }
}

/// Keys wrapper alias as specified in the architecture specification
typedef Keys = KeysStorage;
