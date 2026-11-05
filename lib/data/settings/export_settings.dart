import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../core/path_constants.dart';

class ExportSettings {
  static const String _settingsFileName = 'export_dir.txt';
  static const String defaultAndroidDir = '/storage/emulated/0';

  static String getDefaultDir() {
    if (Platform.isAndroid) {
      return defaultAndroidDir;
    }
    return '';
  }

  /// Returns the saved export directory or default storage root
  static Future<String> getExportDir() async {
    try {
      final String docs = await PathConstants.getDocsDir();
      final File file = File(p.join(docs, _settingsFileName));
      if (await file.exists()) {
        final String content = (await file.readAsString()).trim();
        if (content.isNotEmpty) {
          return content;
        }
      }
    } catch (_) {}
    return getDefaultDir();
  }

  /// Saves the export directory persistently
  static Future<void> setExportDir(String dir) async {
    final String trimmed = dir.trim();
    if (trimmed.isEmpty) return;
    try {
      final String docs = await PathConstants.getDocsDir();
      final File file = File(p.join(docs, _settingsFileName));
      await file.writeAsString(trimmed);
    } catch (_) {}
  }
}

class ExportDirNotifier extends StateNotifier<String> {
  ExportDirNotifier() : super(ExportSettings.getDefaultDir()) {
    _load();
  }

  Future<void> _load() async {
    final String dir = await ExportSettings.getExportDir();
    state = dir;
  }

  Future<void> setDir(String dir) async {
    await ExportSettings.setExportDir(dir);
    state = dir;
  }
}

final exportDirProvider =
    StateNotifierProvider<ExportDirNotifier, String>((ref) {
  return ExportDirNotifier();
});
