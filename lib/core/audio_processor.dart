import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import '../domain/models/audio_codec.dart';
import 'result.dart';

abstract class AudioProcessor {
  Future<Result<void>> decodeToPcm(String inPath, String outPath);
  Future<Result<void>> encodeFromPcm(
    String inPath,
    String outPath, {
    required AudioCodec codec,
    String? origSourcePath,
  });
  void cancel();
}

class FFmpegAudioProcessor implements AudioProcessor {
  int? _activeSessionId;

  @override
  void cancel() {
    final int? id = _activeSessionId;
    if (id != null) {
      FFmpegKit.cancel(id);
      _activeSessionId = null;
    } else {
      FFmpegKit.cancel();
    }
  }

  @override
  Future<Result<void>> decodeToPcm(String inPath, String outPath) async {
    final File inFile = File(inPath);
    if (!await inFile.exists()) {
      return failure('Входной аудиофайл не найден: $inPath');
    }

    // Inspect audio properties via FFprobe
    try {
      final probeSession = await FFprobeKit.getMediaInformation(inPath);
      final mediaInfo = probeSession.getMediaInformation();
      if (mediaInfo != null) {
        // Check duration >= 5 seconds
        final String? durationStr = mediaInfo.getDuration();
        if (durationStr != null) {
          final double? duration = double.tryParse(durationStr);
          if (duration != null && duration < 5.0) {
            return failure(
                'Аудио слишком короткое для водяного знака (минимум 5 секунд)');
          }
        }

        // Check channels <= 2
        final streams = mediaInfo.getStreams();
        for (final stream in streams) {
          if (stream.getType() == 'audio') {
            final int? channels = stream.getNumberProperty('channels') as int?;
            if (channels != null && channels > 2) {
              return failure(
                  'Поддерживается только моно или стерео аудио (до 2 каналов)');
            }
          }
        }
      }
    } catch (_) {
      // If probe fails to inspect metadata, continue to ffmpeg decode
    }

    // Transcode to WAV 16-bit PCM, preserving sample rate and channels
    final String cmd = '-y -i "$inPath" -c:a pcm_s16le "$outPath"';
    final session = await FFmpegKit.executeAsync(cmd);
    _activeSessionId = session.getSessionId();

    final returnCode = await session.getReturnCode();
    _activeSessionId = null;

    if (ReturnCode.isSuccess(returnCode)) {
      final File outFile = File(outPath);
      if (await outFile.exists()) {
        return success(null);
      }
      return failure('Файл in.wav не был создан');
    } else if (ReturnCode.isCancel(returnCode)) {
      return failure('Декодирование аудио отменено пользователем');
    } else {
      final failLog = await session.getFailStackTrace();
      return failure(
          'Ошибка декодирования: ${failLog ?? "Не удалось раскодировать аудио"}');
    }
  }

  @override
  Future<Result<void>> encodeFromPcm(
    String inPath,
    String outPath, {
    required AudioCodec codec,
    String? origSourcePath,
  }) async {
    final File inFile = File(inPath);
    if (!await inFile.exists()) {
      return failure('Промежуточный файл $inPath не найден');
    }

    // Prepare FFmpeg command with target codec options
    final StringBuffer cmdBuffer = StringBuffer('-y -i "$inPath"');

    // If original source audio is provided, map its metadata and cover art
    if (origSourcePath != null && await File(origSourcePath).exists()) {
      cmdBuffer.write(' -i "$origSourcePath" -map 0:a -map_metadata 1');
      if (codec != AudioCodec.wav && codec != AudioCodec.opus) {
        cmdBuffer.write(' -map 1:v? -c:v copy');
      }
    }

    for (final String arg in codec.ffmpegArgs) {
      cmdBuffer.write(' $arg');
    }
    cmdBuffer.write(' "$outPath"');

    final session = await FFmpegKit.executeAsync(cmdBuffer.toString());
    _activeSessionId = session.getSessionId();

    final returnCode = await session.getReturnCode();
    _activeSessionId = null;

    if (ReturnCode.isSuccess(returnCode)) {
      final File outFile = File(outPath);
      if (await outFile.exists()) {
        return success(null);
      }
      return failure('Выходной файл не был создан');
    } else if (ReturnCode.isCancel(returnCode)) {
      return failure('Кодирование аудио отменено пользователем');
    } else {
      final failLog = await session.getFailStackTrace();
      return failure(
          'Ошибка сжатия кодеком: ${failLog ?? "Не удалось закодировать аудио"}');
    }
  }
}
