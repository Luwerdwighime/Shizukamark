import 'dart:io';
import 'package:path/path.dart' as p;
import '../../core/audio_processor.dart';
import '../../core/path_constants.dart';
import '../../core/result.dart';
import '../../core/stego_processor.dart';
import '../../core/wakelock_manager.dart';
import '../../domain/models/progress_state.dart';
import '../../l10n/app_localizations.dart';

class ReadMarkController {
  final AudioProcessor _audioProcessor;
  final StegoProcessor _stegoProcessor;

  bool _isCancelled = false;

  ReadMarkController({
    AudioProcessor? audioProcessor,
    StegoProcessor? stegoProcessor,
  })  : _audioProcessor = audioProcessor ?? FFmpegAudioProcessor(),
        _stegoProcessor = stegoProcessor ?? AudiowmarkStegoProcessor();

  void cancel() {
    _isCancelled = true;
    _audioProcessor.cancel();
    _stegoProcessor.cancel();
    PathConstants.cleanupTempWavFiles();
    WakelockManager.disable();
  }

  Future<Result<String>> execute({
    required String inputAudioPath,
    required bool isPatient,
    required Function(ProgressDialogState) onProgress,
    AppLocalizations? l10n,
  }) async {
    _isCancelled = false;

    if (!await File(inputAudioPath).exists()) {
      return failure(
          l10n?.readMarkErrorNoFile ?? 'Выберите помеченное водяным знаком музло');
    }

    final String titleDecoding = l10n?.progressDecoding ?? 'Декодирование аудио';
    final String titleReading =
        l10n?.progressReadingWatermark ?? 'Чтение водяного знака';
    final String titleDone = l10n?.progressDone ?? 'Завершено';

    final List<OperationStep> steps = [
      OperationStep(title: titleDecoding, isRunning: true),
      OperationStep(title: titleReading),
    ];

    ProgressDialogState state = ProgressDialogState(
      steps: steps,
      progress: 0.1,
      currentOperation: titleDecoding,
    );
    onProgress(state);

    await WakelockManager.enable();
    await PathConstants.cleanupTempWavFiles();

    final String docsDir = await PathConstants.getDocsDir();
    final String inWavPath = p.join(docsDir, PathConstants.inWav);

    try {
      // --- STEP 1: Decode to PCM WAV 16-bit ---
      if (_isCancelled) {
        return failure(l10n?.errorOperationCancelled ?? 'Операция отменена');
      }
      final Result<void> decodeRes =
          await _audioProcessor.decodeToPcm(inputAudioPath, inWavPath);
      if (decodeRes.isError) {
        final prefix = l10n?.errorDecoding ?? 'Ошибка декодирования';
        return failure('$prefix: ${decodeRes.error}');
      }

      // Update progress to Step 2
      steps[0] = steps[0].copyWith(isCompleted: true, isRunning: false);
      steps[1] = steps[1].copyWith(isRunning: true);
      state = state.copyWith(
        steps: List.from(steps),
        progress: 0.5,
        currentOperation: titleReading,
      );
      onProgress(state);

      // --- STEP 2: StegoProcessor Get ---
      if (_isCancelled) {
        return failure(l10n?.errorOperationCancelled ?? 'Операция отменена');
      }
      final Result<String> stegoRes =
          await _stegoProcessor.get(PathConstants.inWav, isPatient);
      if (stegoRes.isError) {
        return failure(stegoRes.error!);
      }

      steps[1] = steps[1].copyWith(isCompleted: true, isRunning: false);
      state = state.copyWith(
        steps: List.from(steps),
        progress: 1.0,
        currentOperation: titleDone,
      );
      onProgress(state);

      return success(stegoRes.value!);
    } finally {
      await PathConstants.cleanupTempWavFiles();
      await WakelockManager.disable();
    }
  }
}
