import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shizukamark/presentation/providers/apply_mark_controller.dart';

void main() {
  group('Message Hash calculation tests', () {
    test('computeMessageHash produces 32-hex lowercase prefix of sha256', () {
      const String testMsg = 'Hello, World!';
      final List<int> utf8Bytes = utf8.encode(testMsg);
      final String expectedFullSha256 = sha256.convert(utf8Bytes).toString();
      final String expectedHash32 =
          expectedFullSha256.substring(0, 32).toLowerCase();

      final String actualHash = ApplyMarkController.computeMessageHash(testMsg);
      expect(actualHash, expectedHash32);
      expect(actualHash.length, 32);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(actualHash), isTrue);
    });

    test('computeMessageHash with Russian unicode text', () {
      const String testMsg = 'Секретное сообщение для стеганографии';
      final List<int> utf8Bytes = utf8.encode(testMsg);
      final String expectedFullSha256 = sha256.convert(utf8Bytes).toString();
      final String expectedHash32 =
          expectedFullSha256.substring(0, 32).toLowerCase();

      final String actualHash = ApplyMarkController.computeMessageHash(testMsg);
      expect(actualHash, expectedHash32);
      expect(actualHash.length, 32);
    });

    test('hashes are deterministic and consistent', () {
      const String msg = 'Deterministic Key 123';
      final String h1 = ApplyMarkController.computeMessageHash(msg);
      final String h2 = ApplyMarkController.computeMessageHash(msg);
      expect(h1, h2);
    });
  });
}
