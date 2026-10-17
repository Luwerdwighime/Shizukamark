import 'package:flutter_test/flutter_test.dart';
import 'package:shizukamark/core/result.dart';

void main() {
  group('Result functional type tests', () {
    test('success creates a Result with value and null error', () {
      final Result<int> res = success(42);
      expect(res.value, 42);
      expect(res.error, isNull);
      expect(res.isSuccess, isTrue);
      expect(res.isError, isFalse);
    });

    test('failure creates a Result with null value and error message', () {
      final Result<int> res = failure('something went wrong');
      expect(res.value, isNull);
      expect(res.error, 'something went wrong');
      expect(res.isSuccess, isFalse);
      expect(res.isError, isTrue);
    });

    test('success with string value', () {
      final Result<String> res = success('secret_msg');
      expect(res.value, 'secret_msg');
      expect(res.isSuccess, isTrue);
    });

    test('success with void / null value', () {
      final Result<bool?> res = success(null);
      expect(res.value, isNull);
      expect(res.error, isNull);
      expect(res.isSuccess, isTrue);
    });
  });
}
