import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shizukamark/data/settings/export_settings.dart';

void main() {
  group('ExportSettings tests', () {
    test(
        'getDefaultDir returns /storage/emulated/0 on Android and empty on other platforms',
        () {
      final defaultDir = ExportSettings.getDefaultDir();
      if (Platform.isAndroid) {
        expect(defaultDir, '/storage/emulated/0');
      } else {
        expect(defaultDir, '');
      }
    });
  });
}
