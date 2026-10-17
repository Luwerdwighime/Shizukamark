import 'package:flutter_test/flutter_test.dart';
import 'package:shizukamark/core/audiowmark_service.dart';

void main() {
  group('Audiowmark stdout pattern parser tests', () {
    test('parses pattern lines without patient option', () {
      const String stdout = '''
pattern  0:05 0123456789abcdef0011223344556677 1.358 0.059 A
pattern  0:57 0123456789abcdef0011223344556677 1.426 0.050 B
pattern  0:57 0123456789abcdef0011223344556677 1.392 0.055 AB
pattern  1:49 0123456789abcdef0011223344556677 1.453 0.074 A
pattern  2:40 0123456789abcdef0011223344556677 1.359 0.080 B
pattern  2:40 0123456789abcdef0011223344556677 1.406 0.077 AB
pattern   all 0123456789abcdef0011223344556677 1.399 0.035
pattern  2:58 c6141f3d25720eb0dbd0e38ee2355ff4 0.185 0.382 B
pattern  2:14 df659ac435f0569c67cdac1fb2e36cd8 0.178 0.391 B
pattern  1:58 d7d7ed21e9d6da0a4ffdd5e55ffdb623 0.176 0.389 A
pattern  2:59 1c13f1532eeb6c9aa719253736849d6e 0.167 0.389 A
''';

      final List<String> hashes = AudiowmarkService.parsePatternHashes(stdout);
      expect(hashes, isNotEmpty);
      expect(hashes[0], '0123456789abcdef0011223344556677');
      expect(hashes, contains('c6141f3d25720eb0dbd0e38ee2355ff4'));
      expect(hashes, contains('df659ac435f0569c67cdac1fb2e36cd8'));
      expect(hashes, contains('d7d7ed21e9d6da0a4ffdd5e55ffdb623'));
      expect(hashes, contains('1c13f1532eeb6c9aa719253736849d6e'));
      // Check deduplication (0123456789abcdef0011223344556677 appears multiple times)
      final List<String> firstHashOccurrences =
          hashes.where((h) => h == '0123456789abcdef0011223344556677').toList();
      expect(firstHashOccurrences.length, 1);
    });

    test('parses pattern lines with patient option and speed lines ignored',
        () {
      const String stdout = '''
speed 1.049966
pattern  0:05 0123456789abcdef0011223344556677 1.209 0.147 A-SPEED
pattern  0:57 0123456789abcdef0011223344556677 1.301 0.143 B-SPEED
pattern  0:57 0123456789abcdef0011223344556677 1.255 0.145 AB-SPEED
pattern  1:49 0123456789abcdef0011223344556677 1.380 0.173 A-SPEED
pattern   all 0123456789abcdef0011223344556677 1.297 0.130 SPEED
''';

      final List<String> hashes = AudiowmarkService.parsePatternHashes(stdout);
      expect(hashes.length, 1);
      expect(hashes[0], '0123456789abcdef0011223344556677');
    });

    test('ignores non-pattern lines, banners, and malformed lines', () {
      const String stdout = '''
audiowmark 0.6.1 - audio watermarking tool
Copyright (C) 2018-2020 Stefan Westerfeld
opening in.wav
scanning audio...
pattern 0:01 not_a_32_hex_hash 1.0 0.5
time taken: 2.34s
''';

      final List<String> hashes = AudiowmarkService.parsePatternHashes(stdout);
      expect(hashes, isEmpty);
    });
  });
}
