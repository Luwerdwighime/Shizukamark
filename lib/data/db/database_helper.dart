import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../core/path_constants.dart';
import '../../core/result.dart';
import '../../domain/models/message_entity.dart';

class DatabaseHelper {
  Database? _db;
  static final RegExp _hashRegex = RegExp(r'^[0-9a-f]{32}$');

  /// Validates that text is non-empty printable Unicode
  static bool isValidMessage(String msg) {
    if (msg.trim().isEmpty) return false;
    for (final int codeUnit in msg.codeUnits) {
      // Allow standard printable characters and common newlines/tabs
      if ((codeUnit < 32 &&
              codeUnit != 9 &&
              codeUnit != 10 &&
              codeUnit != 13) ||
          codeUnit == 127) {
        return false;
      }
    }
    return true;
  }

  /// Validates 32-hex lowercase hash
  static bool isValidHash(String hash) {
    return _hashRegex.hasMatch(hash);
  }

  /// Opens or returns existing SQLite database connection
  Future<Database> getDatabase() async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    final String docs = await PathConstants.getDocsDir();
    final String dbPath = p.join(docs, PathConstants.dbName);

    final Database db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            msg TEXT NOT NULL,
            hash VARCHAR(32) NOT NULL UNIQUE,
            ts INTEGER NOT NULL
          )
        ''');
      },
    );
    _db = db;
    return db;
  }

  /// Inserts a message with validation and hash deduplication (INSERT OR IGNORE)
  Future<Result<int>> insertMessage({
    required String msg,
    required String hash,
    required int ts,
  }) async {
    if (!isValidMessage(msg)) {
      return failure(
          'Некорректное сообщение: должно содержать печатные символы');
    }
    final String lowerHash = hash.toLowerCase();
    if (!isValidHash(lowerHash)) {
      return failure('Некорректный хэш сообщения: требуется 32 hex-символа');
    }

    try {
      final Database db = await getDatabase();
      final int rowId = await db.insert(
        'messages',
        {
          'msg': msg,
          'hash': lowerHash,
          'ts': ts,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return success(rowId);
    } catch (e) {
      return failure('Ошибка записи сообщения в базу данных: $e');
    }
  }

  /// Finds message text by its 32-hex hash
  Future<Result<String?>> findMessageByHash(String hash) async {
    final String lowerHash = hash.toLowerCase();
    if (!isValidHash(lowerHash)) {
      return failure('Некорректный формат хэша для поиска');
    }

    try {
      final Database db = await getDatabase();
      final List<Map<String, dynamic>> rows = await db.query(
        'messages',
        columns: ['msg'],
        where: 'hash = ?',
        whereArgs: [lowerHash],
        limit: 1,
      );
      if (rows.isEmpty) {
        return success(null);
      }
      return success(rows.first['msg'] as String?);
    } catch (e) {
      return failure('Ошибка чтения из базы данных: $e');
    }
  }

  /// Retrieves all messages
  Future<Result<List<MessageEntity>>> getAllMessages() async {
    try {
      final Database db = await getDatabase();
      final List<Map<String, dynamic>> rows = await db.query(
        'messages',
        orderBy: 'ts DESC',
      );
      final List<MessageEntity> list =
          rows.map((r) => MessageEntity.fromMap(r)).toList();
      return success(list);
    } catch (e) {
      return failure('Ошибка чтения списка сообщений: $e');
    }
  }

  /// Closes database connection
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}

/// Messages wrapper alias as specified in the architecture specification
typedef Messages = DatabaseHelper;
