import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PathConstants {
  static const String inWav = 'in.wav';
  static const String outWav = 'out.wav';
  static const String keysDir = 'keys';
  static const String dbName = 'messages.sqlite';

  /// Returns getApplicationDocumentsDirectory() path
  static Future<String> getDocsDir() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Returns getApplicationDocumentsDirectory() + "/keys" path
  static Future<String> getKeysDir() async {
    final String docs = await getDocsDir();
    return p.join(docs, keysDir);
  }

  /// Returns absolute path to in.wav
  static Future<String> getInWavPath() async {
    final String docs = await getDocsDir();
    return p.join(docs, inWav);
  }

  /// Returns absolute path to out.wav
  static Future<String> getOutWavPath() async {
    final String docs = await getDocsDir();
    return p.join(docs, outWav);
  }

  /// Deletes in.wav and out.wav if they exist
  static Future<void> cleanupTempWavFiles() async {
    try {
      final String inPath = await getInWavPath();
      final File inFile = File(inPath);
      if (await inFile.exists()) {
        await inFile.delete();
      }
    } catch (_) {}

    try {
      final String outPath = await getOutWavPath();
      final File outFile = File(outPath);
      if (await outFile.exists()) {
        await outFile.delete();
      }
    } catch (_) {}
  }
}
