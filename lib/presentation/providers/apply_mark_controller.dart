import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/audio_processor.dart';
import '../../core/native_channel.dart';
import '../../core/path_constants.dart';
import '../../core/result.dart';
import '../../core/stego_processor.dart';
import '../../core/wakelock_manager.dart';
import '../../data/db/database_helper.dart';
import '../../domain/models/audio_codec.dart';
import '../../domain/models/key_info.dart';
import '../../domain/models/progress_state.dart';

class ApplyMarkController {
  final AudioProcessor _audioProcessor;
  final StegoProcessor _stegoProcessor;
  final DatabaseHelper _databaseHelper;

  bool _isCancelled = false;

  ApplyMarkController({
    AudioProcessor? audioProcessor,
    StegoProcessor? stegoProcessor,
    DatabaseHelper? databaseHelper,
  })  : _audioProcessor = audioProcessor ?? FFmpegAudioProcessor(),
        _stegoProcessor = stegoProcessor ?? AudiowmarkStegoProcessor(),
        _databaseHelper = databaseHelper ?? DatabaseHelper();

  void cancel() {
    _isCancelled = true;
    _audioProcessor.cancel();
    _stegoProcessor.cancel();
    PathConstants.cleanupTempWavFiles();
    WakelockManager.disable();
  }

  /// Computes 32-hex lowercase SHA-256 hash of UTF-8 message bytes
  static String computeMessageHash(String message) {
    final List<int> bytes = utf8.encode(message);
    final String fullHash = sha256.convert(bytes).toString();
    return fullHash.substring(0, 32).toLowerCase();
  }

  /// Runs the full watermarking pipeline with callback updates for the progress dialog
  Future<Result<String>> execute({
    required String secretMessage,
    required String inputAudioPath,
    required KeyInfo selectedKey,
    required AudioCodec codec,
    String? customSavePath,
    required Function(ProgressDialogState) onProgress,
  }) async {
    _isCancelled = false;

    // 1. Validations
    if (!DatabaseHelper.isValidMessage(secretMessage)) {
      return failure('Введите секретное сообщение');
    }
    if (!await File(inputAudioPath).exists()) {
      return failure('Выберите музло');
    }
    if (selectedKey.keyPath.isEmpty) {
      return failure('Создайте или выберите ключ');
    }

    final String hash32 = computeMessageHash(secretMessage);

    // Initial progress state
    final List<OperationStep> steps = [
      const OperationStep(title: 'Декодирование аудио', isRunning: true),
      const OperationStep(title: 'Наложение водяного знака'),
      const OperationStep(title: 'Кодирование аудио'),
    ];

    ProgressDialogState state = ProgressDialogState(
      steps: steps,
      progress: 0.05,
      currentOperation: 'Декодирование аудио',
    );
    onProgress(state);

    await WakelockManager.enable();
    await PathConstants.cleanupTempWavFiles();

    final String docsDir = await PathConstants.getDocsDir();
    final String inWavPath = p.join(docsDir, PathConstants.inWav);
    final String outWavPath = p.join(docsDir, PathConstants.outWav);
    String? tempEncodedPath;

    try {
      // --- STEP 1: Decode to PCM WAV 16-bit ---
      if (_isCancelled) return failure('Операция отменена');
      final Result<void> decodeRes = await _audioProcessor.decodeToPcm(inputAudioPath, inWavPath);
      if (decodeRes.isError) {
        return failure(decodeRes.error!);
      }

      // Update progress to Step 2
      steps[0] = steps[0].copyWith(isCompleted: true, isRunning: false);
      steps[1] = steps[1].copyWith(isRunning: true);
      state = state.copyWith(
        steps: List.from(steps),
        progress: 0.35,
        currentOperation: 'Наложение водяного знака',
      );
      onProgress(state);

      // --- STEP 2: StegoProcessor Add ---
      if (_isCancelled) return failure('Операция отменена');
      final Result<void> stegoRes = await _stegoProcessor.add(
        PathConstants.inWav,
        PathConstants.outWav,
        hash32,
        keyPath: selectedKey.keyPath,
      );
      if (stegoRes.isError) {
        return failure('Ошибка наложения водяного знака: ${stegoRes.error}');
      }

      // Update progress to Step 3
      steps[1] = steps[1].copyWith(isCompleted: true, isRunning: false);
      steps[2] = steps[2].copyWith(isRunning: true);
      state = state.copyWith(
        steps: List.from(steps),
        progress: 0.70,
        currentOperation: 'Кодирование аудио',
      );
      onProgress(state);

      // --- STEP 3: Encode to target codec ---
      if (_isCancelled) return failure('Операция отменена');
      final Directory tempDir = await getTemporaryDirectory();
      final String inputBaseName = p.basenameWithoutExtension(inputAudioPath);
      final String targetFileName = '${inputBaseName}_wm${codec.extension}';
      tempEncodedPath = p.join(tempDir.path, targetFileName);

      final Result<void> encodeRes = await _audioProcessor.encodeFromPcm(
        outWavPath,
        tempEncodedPath,
        codec: codec,
        origSourcePath: inputAudioPath,
      );
      if (encodeRes.isError) {
        return failure(encodeRes.error!);
      }

      // --- STEP 4: Save to Destination (MediaStore or Custom Path) ---
      String finalSavedPath;
      if (customSavePath != null && customSavePath.isNotEmpty) {
        try {
          final File src = File(tempEncodedPath);
          final File dst = File(customSavePath);
          await dst.parent.create(recursive: true);
          await src.copy(dst.path);
          finalSavedPath = dst.path;
        } catch (e) {
          return failure('Ошибка сохранения: $e');
        }
      } else {
        final Result<String> saveRes = await NativeChannel.saveAudioToMediaStore(
          filePath: tempEncodedPath,
          fileName: targetFileName,
          mimeType: codec.mimeType,
        );
        if (saveRes.isError) {
          return failure('Ошибка сохранения: ${saveRes.error}');
        }
        finalSavedPath = saveRes.value!;
      }

      // --- STEP 5: Save message to SQLite database ---
      await _databaseHelper.insertMessage(
        msg: secretMessage,
        hash: hash32,
        ts: DateTime.now().millisecondsSinceEpoch,
      );

      // Mark Step 3 completed
      steps[2] = steps[2].copyWith(isCompleted: true, isRunning: false);
      state = state.copyWith(
        steps: List.from(steps),
        progress: 1.0,
        currentOperation: 'Завершено',
      );
      onProgress(state);

      return success(finalSavedPath);
    } finally {
      await PathConstants.cleanupTempWavFiles();
      if (tempEncodedPath != null) {
        try {
          final File f = File(tempEncodedPath);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
      await WakelockManager.disable();
    }
  }
}
