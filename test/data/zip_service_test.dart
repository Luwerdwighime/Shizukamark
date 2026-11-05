import 'package:flutter_test/flutter_test.dart';
import 'package:shizukamark/data/zip/zip_service.dart';

void main() {
  group('ZipService isSafePath security tests', () {
    test('allows safe relative paths', () {
      expect(ZipService.isSafePath('messages.sqlite'), isTrue);
      expect(ZipService.isSafePath('keys/'), isTrue);
      expect(ZipService.isSafePath('keys/a1b2c3d4.key'), isTrue);
      expect(ZipService.isSafePath('keys/sub/test.key'), isTrue);
    });

    test('rejects path traversal attempts (Zip-Slip)', () {
      expect(ZipService.isSafePath('../evil.sh'), isFalse);
      expect(ZipService.isSafePath('keys/../../etc/passwd'), isFalse);
      expect(ZipService.isSafePath('keys/../messages.sqlite'), isFalse);
      expect(ZipService.isSafePath('./hidden'), isFalse);
      expect(ZipService.isSafePath('keys/./same'), isFalse);
    });

    test('rejects absolute paths', () {
      expect(ZipService.isSafePath('/etc/passwd'), isFalse);
      expect(ZipService.isSafePath('/storage/emulated/0/file.txt'), isFalse);
      expect(ZipService.isSafePath('\\Windows\\System32'), isFalse);
      expect(ZipService.isSafePath('C:/Windows/file.txt'), isFalse);
      expect(ZipService.isSafePath('D:\\Data\\file.txt'), isFalse);
    });
  });

  group('ZipService timestamp and key name tests', () {
    test('formatTimestamp formats DateTime as ЧЧ:ММ:СС/ДД.ММ.ГГ', () {
      final dt = DateTime(2026, 11, 5, 14, 30, 45);
      expect(ZipService.formatTimestamp(dt), '14:30:45/05.11.26');

      final dtPadded = DateTime(2027, 3, 9, 8, 5, 3);
      expect(ZipService.formatTimestamp(dtPadded), '08:05:03/09.03.27');
    });

    test('updateKeyNameInContent replaces existing name line', () {
      const original = 'name "Old Name"\nkey 1234567890abcdef\n';
      final updated = ZipService.updateKeyNameInContent(original, 'New Name_14:30:45/05.11.26');
      expect(updated, 'name "New Name_14:30:45/05.11.26"\nkey 1234567890abcdef\n');
    });

    test('updateKeyNameInContent prepends name if no name line exists', () {
      const original = 'key 1234567890abcdef\n';
      final updated = ZipService.updateKeyNameInContent(original, 'Created Name');
      expect(updated, 'name "Created Name"\nkey 1234567890abcdef\n');
    });
  });
}
