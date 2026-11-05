import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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

  /// Formats DateTime as 'ЧЧ:ММ:СС/ДД.ММ.ГГ' (e.g. 14:30:15/05.11.26)
  static String formatTimestamp(DateTime dt) {
    final String hh = dt.hour.toString().padLeft(2, '0');
    final String mm = dt.minute.toString().padLeft(2, '0');
    final String ss = dt.second.toString().padLeft(2, '0');
    final String dd = dt.day.toString().padLeft(2, '0');
    final String mo = dt.month.toString().padLeft(2, '0');
    final String yy = (dt.year % 100).toString().padLeft(2, '0');
    return '$hh:$mm:$ss/$dd.$mo.$yy';
  }

  /// Updates or inserts the key name in the .key file content
  static String updateKeyNameInContent(String content, String newName) {
    final RegExp nameRegex = RegExp(r'^name\s+.*$', multiLine: true);
    if (nameRegex.hasMatch(content)) {
      return content.replaceFirst(nameRegex, 'name "$newName"');
    } else {
      return 'name "$newName"\n$content';
    }
  }

  /// Creates in-memory ZIP archive bytes containing keys and messages.sqlite
  Future<Result<Uint8List>> createZipBytes() async {
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

      // 3. Encode ZIP
      final ZipEncoder encoder = ZipEncoder();
      final List<int> zipBytes = encoder.encode(archive);

      return success(Uint8List.fromList(zipBytes));
    } catch (e) {
      return failure('Ошибка создания zip-архива: $e');
    }
  }

  /// Exports keys and messages.sqlite to a ZIP archive at destinationPath
  Future<Result<void>> zipOut(String destinationPath) async {
    final Result<Uint8List> bytesRes = await createZipBytes();
    if (bytesRes.isError) {
      return failure(bytesRes.error!);
    }
    try {
      final File destFile = File(destinationPath);
      await destFile.parent.create(recursive: true);
      await destFile.writeAsBytes(bytesRes.value!);

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

      // 1. Import database records from temporary messages.sqlite with hash deduplication
      final Database tempDb = await openReadOnlyDatabase(tempDbFile.path);
      try {
        final List<Map<String, dynamic>> rows = await tempDb.query('messages');
        for (final Map<String, dynamic> row in rows) {
          final String? msg = row['msg'] as String?;
          final String? hash = row['hash'] as String?;
          final int? ts = row['ts'] as int?;
          if (msg != null && hash != null && ts != null) {
            final String lowerHash = hash.toLowerCase();
            if (await _databaseHelper.hasMessageWithHash(lowerHash)) {
              // Same hash already exists in sqlite -> skip to avoid inflating database
              continue;
            }
            await _databaseHelper.insertMessage(
                msg: msg, hash: lowerHash, ts: ts);
          }
        }
      } finally {
        await tempDb.close();
      }

      // 2. Import keys with name/hash deduplication and timestamp renaming for collisions
      final Directory localKeysDir = await _keysStorage.getKeysDirectory();
      final List<({String name, String? hexKey, String fileName})>
          existingKeys = await _keysStorage.getAllParsedKeys();

      for (final keyData in candidateKeys) {
        String content = utf8.decode(keyData.bytes, allowMalformed: true);
        final parsed = KeysStorage.parseKeyFile(content);
        final String candidateName = parsed.name;
        final String? candidateHex = parsed.hexKey;

        // Check if this key is already present in the library:
        // Identical both by name (or renamed oldName_timestamp) and hash
        if (candidateHex != null && candidateHex.isNotEmpty) {
          final String normCandHex = candidateHex.toLowerCase();
          final bool isAlreadyImported = existingKeys.any((existing) {
            if (existing.hexKey == null ||
                existing.hexKey!.toLowerCase() != normCandHex) {
              return false;
            }
            if (existing.name == candidateName) return true;
            if (candidateName.isNotEmpty &&
                existing.name.startsWith('${candidateName}_')) {
              return true;
            }
            return false;
          });

          if (isAlreadyImported) {
            // Key is already present in library -> skip creating duplicate
            continue;
          }
        }

        // Key is not yet present. Check if candidate name collides with an existing key's name
        String targetName = candidateName;
        if (candidateName.isNotEmpty) {
          final bool hasNameCollision =
              existingKeys.any((k) => k.name == candidateName);
          if (hasNameCollision) {
            // Same name but different hash: rename with timestamp
            final String ts = formatTimestamp(DateTime.now());
            targetName = '${candidateName}_$ts';

            // Ensure uniqueness in the rare case of collision
            String uniqueTargetName = targetName;
            int counter = 1;
            while (existingKeys.any((k) => k.name == uniqueTargetName)) {
              uniqueTargetName = '${targetName}_$counter';
              counter++;
            }
            targetName = uniqueTargetName;

            content = updateKeyNameInContent(content, targetName);
          }
        }

        // Generate unique 8-hex filename and save
        final String newFileName =
            await _keysStorage.generateUniqueKeyFileName();
        final File newKeyFile = File(p.join(localKeysDir.path, newFileName));
        await newKeyFile.writeAsBytes(utf8.encode(content));

        // Track in existingKeys so subsequent keys reflect this addition
        existingKeys.add((
          name: targetName,
          hexKey: candidateHex,
          fileName: newFileName,
        ));
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

/// Top-level createZipBytes function
Future<Result<Uint8List>> createZipBytes() => ZipService().createZipBytes();
