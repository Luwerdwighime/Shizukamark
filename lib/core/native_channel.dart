import 'package:flutter/services.dart';
import 'result.dart';

class NativeChannel {
  static const MethodChannel _channel =
      MethodChannel('com.luwerdwighime.shizukamark/native');

  /// Retrieves applicationInfo.nativeLibraryDir on Android
  static Future<Result<String>> getNativeLibraryDir() async {
    try {
      final String? path =
          await _channel.invokeMethod<String>('getNativeLibraryDir');
      if (path == null || path.isEmpty) {
        return failure('Не удалось получить директорию нативных библиотек');
      }
      return success(path);
    } on PlatformException catch (e) {
      return failure('Ошибка доступа к нативным библиотекам: ${e.message}');
    } catch (e) {
      return failure('Непредвиденная ошибка платформы: $e');
    }
  }

  /// Saves output audio file into MediaStore (Music/Shizukamark) on Android
  static Future<Result<String>> saveAudioToMediaStore({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final String? savedPath = await _channel.invokeMethod<String>(
        'saveAudioToMediaStore',
        {
          'filePath': filePath,
          'fileName': fileName,
          'mimeType': mimeType,
        },
      );
      if (savedPath == null || savedPath.isEmpty) {
        return failure('Ошибка сохранения файла через MediaStore');
      }
      return success(savedPath);
    } on PlatformException catch (e) {
      return failure('Ошибка сохранения файла в систему: ${e.message}');
    } catch (e) {
      return failure('Непредвиденная ошибка сохранения: $e');
    }
  }
}
