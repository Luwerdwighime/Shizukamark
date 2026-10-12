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
}
