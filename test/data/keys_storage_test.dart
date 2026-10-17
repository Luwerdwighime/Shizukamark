import 'package:flutter_test/flutter_test.dart';
import 'package:shizukamark/data/keys/keys_storage.dart';

void main() {
  group('KeysStorage file parsing tests', () {
    test('parses .key file with name and key hex', () {
      const String content = '''
# audiowmark key file
name "Artist Master Key 2026"
key 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
''';

      final parsed = KeysStorage.parseKeyFile(content);
      expect(parsed.name, 'Artist Master Key 2026');
      expect(parsed.hexKey,
          '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef');
    });

    test('parses .key file without name (unnamed key)', () {
      const String content = '''
# audiowmark key file
key c6141f3d25720eb0dbd0e38ee2355ff40123456789abcdef0123456789abcdef
''';

      final parsed = KeysStorage.parseKeyFile(content);
      expect(parsed.name, '');
      expect(parsed.hexKey,
          'c6141f3d25720eb0dbd0e38ee2355ff40123456789abcdef0123456789abcdef');
    });

    test('parses .key file with empty or malformed lines gracefully', () {
      const String content = '''
# empty comment
unknown_field 123
''';

      final parsed = KeysStorage.parseKeyFile(content);
      expect(parsed.name, '');
      expect(parsed.hexKey, isNull);
    });

    test('parses .key file with special characters in name', () {
      const String content = '''
name "Studio A / Track #1 (Final)"
key 11223344556677889900aabbccddeeff11223344556677889900aabbccddeeff
''';

      final parsed = KeysStorage.parseKeyFile(content);
      expect(parsed.name, 'Studio A / Track #1 (Final)');
      expect(parsed.hexKey,
          '11223344556677889900aabbccddeeff11223344556677889900aabbccddeeff');
    });
  });
}
