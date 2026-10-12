import 'package:flutter_test/flutter_test.dart';
import 'package:shizukamark/data/db/database_helper.dart';

void main() {
  group('Database message and hash validation tests', () {
    test('isValidMessage allows standard printable Unicode strings', () {
      expect(DatabaseHelper.isValidMessage('Hello World!'), isTrue);
      expect(DatabaseHelper.isValidMessage('Привет, мир! 12345'), isTrue);
      expect(DatabaseHelper.isValidMessage('Multiline\nMessage\r\nWith\tTabs'), isTrue);
      expect(DatabaseHelper.isValidMessage('Special symbols: #@\$%^&*()_+-=[]{}|;:",.<>?/'), isTrue);
    });

    test('isValidMessage rejects empty or whitespace-only messages', () {
      expect(DatabaseHelper.isValidMessage(''), isFalse);
      expect(DatabaseHelper.isValidMessage('   '), isFalse);
      expect(DatabaseHelper.isValidMessage('\n\t\r'), isFalse);
    });

    test('isValidMessage rejects non-printable control characters', () {
      // ASCII 0 (NUL), 7 (BEL), 27 (ESC), 127 (DEL)
      expect(DatabaseHelper.isValidMessage('Hello\x00World'), isFalse);
      expect(DatabaseHelper.isValidMessage('Hello\x07World'), isFalse);
      expect(DatabaseHelper.isValidMessage('Hello\x1bWorld'), isFalse);
      expect(DatabaseHelper.isValidMessage('Hello\x7fWorld'), isFalse);
    });

    test('isValidHash accepts exact 32 lowercase hex characters', () {
      expect(DatabaseHelper.isValidHash('0123456789abcdef0123456789abcdef'), isTrue);
      expect(DatabaseHelper.isValidHash('c6141f3d25720eb0dbd0e38ee2355ff4'), isTrue);
    });

    test('isValidHash rejects non-32 characters or non-hex characters', () {
      // 31 characters
      expect(DatabaseHelper.isValidHash('0123456789abcdef0123456789abcde'), isFalse);
      // 33 characters
      expect(DatabaseHelper.isValidHash('0123456789abcdef0123456789abcdef0'), isFalse);
      // Uppercase characters
      expect(DatabaseHelper.isValidHash('0123456789ABCDEF0123456789ABCDEF'), isFalse);
      // Non-hex characters
      expect(DatabaseHelper.isValidHash('0123456789abcdef0123456789abcdeg'), isFalse);
      expect(DatabaseHelper.isValidHash(''), isFalse);
    });
  });
}
