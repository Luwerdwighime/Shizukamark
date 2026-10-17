import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/path_constants.dart';
import '../../core/result.dart';
import '../db/database_helper.dart';
import '../keys/keys_storage.dart';

class ZipService {
  final DatabaseHelper _databaseHelper;
  final KeysStorage _keysStorage;

  ZipService({
    DatabaseHelper? databaseHelper,
    KeysStorage? keysStorage,
  })  : _databaseHelper = databaseHelper ?? DatabaseHelper(),
        _keysStorage = keysStorage ?? KeysStorage();

  /// Sanitizes an archive file path against Zip-Slip path traversal vulnerability
  static bool isSafePath(String entryName) {
    if (entryName.startsWith('/') ||
        entryName.startsWith('\\') ||
        entryName.contains(':')) {
      return false;
    }
    final List<String> segments = p.split(entryName);
    for (final String s in segments) {
      if (s == '..' || s == '.') return false;
    }
    return true;
  }

  /// Exports keys and messages.sqlite to a ZIP archive at destinationPath
  Future<Result<void>> zipOut(String destinationPath) async {
    try {
      final Archive archive = Archive();
      final String docs = await PathConstants.getDocsDir();

      // 1. Ensure messages.sqlite exists and add it
      await _databaseHelper.getDatabase();
      final File dbFile = File(p.join(docs, PathConstants.dbName));
      if (await dbFile.exists()) {
        final List<int> dbBytes = await dbFile.readAsBytes();
        archive.addFile(
            ArchiveFile(PathConstants.dbName, dbBytes.length, dbBytes));
      }

      // 2. Ensure keys/ directory entry is present in archive
      archive.addFile(ArchiveFile.directory('keys/'));
      final Directory keysDir = Directory(await PathConstants.getKeysDir());
      if (await keysDir.exists()) {
        final List<FileSystemEntity> entities = await keysDir.list().toList();
        for (final FileSystemEntity entity in entities) {
          if (entity is File && entity.path.endsWith('.key')) {
            final List<int> keyBytes = await entity.readAsBytes();
            final String fileName = p.basename(entity.path);
            archive.addFile(
                ArchiveFile('keys/$fileName', keyBytes.length, keyBytes));
          }
        }
      }

      // 3. Encode and write ZIP
      final ZipEncoder encoder = ZipEncoder();
      final List<int> zipBytes = encoder.encode(archive);

      final File destFile = File(destinationPath);
      await destFile.parent.create(recursive: true);
      await destFile.writeAsBytes(zipBytes);

      return success(null);
    } catch (e) {
      return failure('Ошибка создания zip-архива: $e');
    }
  }

  /// Imports keys and messages from ZIP archive at sourcePath
  Future<Result<void>> zipIn(String sourcePath) async {
    final File zipFile = File(sourcePath);
    if (!await zipFile.exists()) {
      return failure('zip архив с неправильным содержимым');
    }

    Directory? tempExtractDir;
    try {
      final List<int> bytes = await zipFile.readAsBytes();
      final Archive archive = ZipDecoder().decodeBytes(bytes);

      // Validate archive structure and Zip-Slip safety
      bool hasDb = false;
      bool hasKeysDirOrKeys = false;

      for (final ArchiveFile file in archive) {
        if (!isSafePath(file.name)) {
          return failure('zip архив с неправильным содержимым');
        }
        final String normalized = file.name.replaceAll('\\', '/');
        if (normalized == PathConstants.dbName) {
          hasDb = true;
        }
        if (normalized.startsWith('keys/') || normalized == 'keys') {
          hasKeysDirOrKeys = true;
        }
      }

      if (!hasDb || !hasKeysDirOrKeys) {
        return failure('zip архив с неправильным содержимым');
      }

      final Directory tempDir = await getTemporaryDirectory();
      tempExtractDir = await tempDir.createTemp('shizukamark_import_');

      File? tempDbFile;
      final List<({String name, List<int> bytes})> candidateKeys = [];

      // Extract entries
      for (final ArchiveFile file in archive) {
        final String normalized = file.name.replaceAll('\\', '/');
        if (file.isFile) {
          final List<int> data = file.content as List<int>;
          if (normalized == PathConstants.dbName) {
            tempDbFile =
                File(p.join(tempExtractDir.path, PathConstants.dbName));
            await tempDbFile.writeAsBytes(data);
          } else if (normalized.startsWith('keys/') &&
              normalized.endsWith('.key')) {
            candidateKeys.add((name: p.basename(normalized), bytes: data));
          }
        }
      }

      if (tempDbFile == null) {
        return failure('zip архив с неправильным содержимым');
      }

      // 1. Import database records from temporary messages.sqlite
      final Database tempDb = await openReadOnlyDatabase(tempDbFile.path);
      try {
        final List<Map<String, dynamic>> rows = await tempDb.query('messages');
        for (final Map<String, dynamic> row in rows) {
          final String? msg = row['msg'] as String?;
          final String? hash = row['hash'] as String?;
          final int? ts = row['ts'] as int?;
          if (msg != null && hash != null && ts != null) {
            await _databaseHelper.insertMessage(msg: msg, hash: hash, ts: ts);
          }
        }
      } finally {
        await tempDb.close();
      }

      // 2. Import keys with deduplication by hex content
      final Directory localKeysDir = await _keysStorage.getKeysDirectory();
      for (final keyData in candidateKeys) {
        final String content = utf8.decode(keyData.bytes, allowMalformed: true);
        final parsed = KeysStorage.parseKeyFile(content);

        if (parsed.hexKey != null && parsed.hexKey!.isNotEmpty) {
          final bool alreadyExists =
              await _keysStorage.hasKeyWithHex(parsed.hexKey!);
          if (alreadyExists) {
            // Key is already present in library -> skip creating duplicate
            continue;
          }
        }

        // New key -> generate unique 8-hex filename and save
        final String newFileName =
            await _keysStorage.generateUniqueKeyFileName();
        final File newKeyFile = File(p.join(localKeysDir.path, newFileName));
        await newKeyFile.writeAsBytes(keyData.bytes);
      }

      return success(null);
    } catch (e) {
      return failure('zip архив с неправильным содержимым');
    } finally {
      if (tempExtractDir != null && await tempExtractDir.exists()) {
        try {
          await tempExtractDir.delete(recursive: true);
        } catch (_) {}
      }
    }
  }
}

/// Top-level zipIn function per specification call tree
Future<Result<void>> zipIn(String sourcePath) => ZipService().zipIn(sourcePath);

/// Top-level zipOut function per specification call tree
Future<Result<void>> zipOut(String destinationPath) =>
    ZipService().zipOut(destinationPath);
