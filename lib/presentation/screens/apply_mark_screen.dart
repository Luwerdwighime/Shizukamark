import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../core/result.dart';
import '../../data/settings/export_settings.dart';
import '../../domain/models/audio_codec.dart';
import '../../domain/models/key_info.dart';
import '../../domain/models/progress_state.dart';
import '../../l10n/app_localizations.dart';
import '../dialogs/codec_selection_dialog.dart';
import '../dialogs/create_key_dialog.dart';
import '../dialogs/progress_dialog.dart';
import '../providers/apply_mark_controller.dart';
import '../widgets/fs_picker_field.dart';
import '../widgets/key_picker_field.dart';
import '../widgets/language_menu_button.dart';
import '../widgets/snack_bar_service.dart';

class ApplyMarkScreen extends ConsumerStatefulWidget {
  const ApplyMarkScreen({super.key});

  @override
  ConsumerState<ApplyMarkScreen> createState() => _ApplyMarkScreenState();
}

class _ApplyMarkScreenState extends ConsumerState<ApplyMarkScreen> {
  final TextEditingController _msgController = TextEditingController();
  String? _inputAudioPath;
  KeyInfo? _selectedKey;
  AudioCodec _selectedCodec = AudioCodec.aac;

  final ApplyMarkController _controller = ApplyMarkController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateKey() async {
    final KeyInfo? created = await showDialog<KeyInfo>(
      context: context,
      builder: (ctx) => const CreateKeyDialog(),
    );
    if (created != null && mounted) {
      setState(() {
        _selectedKey = created;
      });
    }
  }

  Future<void> _handleApplyMark() async {
    final l10n = AppLocalizations.of(context)!;
    final String secretMessage = _msgController.text.trim();

    if (secretMessage.isEmpty) {
      SnackBarService.showError(context, l10n.applyMarkErrorNoMessage);
      return;
    }
    if (_inputAudioPath == null || _inputAudioPath!.isEmpty) {
      SnackBarService.showError(context, l10n.applyMarkErrorNoFile);
      return;
    }
    if (_selectedKey == null || _selectedKey!.keyPath.isEmpty) {
      SnackBarService.showError(context, l10n.applyMarkErrorNoKey);
      return;
    }

    // 1. Choose codec dialog
    final AudioCodec? chosenCodec = await showDialog<AudioCodec>(
      context: context,
      builder: (ctx) => CodecSelectionDialog(initialCodec: _selectedCodec),
    );
    if (chosenCodec == null) return;
    _selectedCodec = chosenCodec;

    // 2. Open progress dialog
    ProgressDialogState currentState = ProgressDialogState(
      steps: const [],
      progress: 0.0,
      currentOperation: l10n.progressPreparing,
    );

    StateSetter? setDialogState;
    BuildContext? progressDialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        progressDialogContext = dialogCtx;
        return StatefulBuilder(
          builder: (ctx, setStateFunc) {
            setDialogState = setStateFunc;
            return ProgressDialogWidget(
              state: currentState,
              onCancel: () {
                _controller.cancel();
                Navigator.of(dialogCtx).pop();
              },
            );
          },
        );
      },
    );

    // 3. Execute process
    Result<String> result;
    try {
      result = await _controller.execute(
        secretMessage: secretMessage,
        inputAudioPath: _inputAudioPath!,
        selectedKey: _selectedKey!,
        codec: _selectedCodec,
        l10n: l10n,
        onProgress: (newState) {
          currentState = newState;
          if (mounted) {
            setDialogState?.call(() {});
          }
        },
        onSave: ({required tempPath, required targetFileName, required bytes}) async {
          // Close progress dialog so the SAF save picker is shown cleanly
          if (progressDialogContext != null &&
              Navigator.of(progressDialogContext!).canPop()) {
            Navigator.of(progressDialogContext!).pop();
            progressDialogContext = null;
          }

          final String? initialDir = await ExportSettings.getExportDir();
          final String? outputPath = await FilePicker.platform.saveFile(
            dialogTitle: l10n.codecDialogTitle,
            fileName: targetFileName,
            initialDirectory: initialDir,
            type: FileType.custom,
            allowedExtensions: [_selectedCodec.extension.replaceFirst('.', '')],
            bytes: bytes,
          );

          if (outputPath == null) {
            return failure(l10n.errorOperationCancelled);
          }

          if (!Platform.isAndroid && !Platform.isIOS) {
            String finalPath = outputPath;
            if (!finalPath
                .toLowerCase()
                .endsWith(_selectedCodec.extension.toLowerCase())) {
              finalPath = '$finalPath${_selectedCodec.extension}';
            }
            final File destFile = File(finalPath);
            await destFile.parent.create(recursive: true);
            await destFile.writeAsBytes(bytes);
          }

          final String chosenDir = p.dirname(outputPath);
          if (chosenDir.isNotEmpty && chosenDir != '.') {
            await ref.read(exportDirProvider.notifier).setDir(chosenDir);
          }

          return success(outputPath);
        },
      );
    } catch (e) {
      result = failure(e.toString());
    }

    // Close progress dialog if still open
    if (progressDialogContext != null &&
        Navigator.of(progressDialogContext!).canPop()) {
      Navigator.of(progressDialogContext!).pop();
    }

    if (result.isSuccess && mounted) {
      // Pop back to home screen and show success SnackBar
      Navigator.of(context).pop();
      SnackBarService.showSuccess(
        context,
        l10n.applyMarkSuccessSaved(result.value ?? ''),
      );
    } else if (mounted) {
      String errorMessage = result.error ?? l10n.errorApplyingWatermark;
      if (errorMessage.contains('Операция отменена') ||
          errorMessage.contains('Operation cancelled')) {
        errorMessage = l10n.errorOperationCancelled;
      } else if (errorMessage.contains('Аудио слишком короткое') ||
          errorMessage.contains('Audio too short')) {
        errorMessage = l10n.errorAudioTooShort;
      } else if (errorMessage
              .contains('Поддерживается только моно или стерео') ||
          errorMessage.contains('Only mono or stereo')) {
        errorMessage = l10n.errorStereoOnly;
      } else if (errorMessage.contains('Выходной файл не был создан') ||
          errorMessage.contains('Output file was not created')) {
        errorMessage = l10n.errorOutputFileNotCreated;
      }
      SnackBarService.showError(
        context,
        errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.applyMarkTitle),
        actions: const [
          LanguageMenuButton(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Textarea 4 lines, vertically expandable
              TextField(
                controller: _msgController,
                minLines: 4,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: l10n.applyMarkSecretHint,
                  counter: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _msgController,
                    builder: (context, value, _) {
                      return Text(
                        l10n.applyMarkCharCount(value.text.characters.length),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF667085),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. МФС для музла
              FsPickerField(
                selectedPath: _inputAudioPath,
                hintText: l10n.applyMarkFileHint,
                onFileSelected: (path) =>
                    setState(() => _inputAudioPath = path),
              ),
              const SizedBox(height: 16),

              // 3. МВК для ключа
              KeyPickerField(
                selectedKey: _selectedKey,
                hintText: l10n.applyMarkKeyHint,
                onKeySelected: (k) => setState(() => _selectedKey = k),
              ),
              const SizedBox(height: 8),

              // 4. серым hint шрифтом центрированно по экрану "или"
              Center(
                child: Text(
                  l10n.applyMarkOr,
                  style:
                      const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),

              // 5. кнопка "Создать новый ключ"
              OutlinedButton.icon(
                onPressed: _handleCreateKey,
                icon: const Icon(Icons.add),
                label: Text(l10n.applyMarkCreateKey),
              ),
              const SizedBox(height: 16),

              // 6. модуль сохранения: выбор места экспорта
              Consumer(
                builder: (context, ref, _) {
                  final String currentExportDir = ref.watch(exportDirProvider);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          try {
                            final String? pickedDir =
                                await FilePicker.platform.getDirectoryPath(
                              dialogTitle: l10n.applyMarkExportFolder,
                              initialDirectory: currentExportDir,
                            );
                            if (pickedDir != null && pickedDir.isNotEmpty) {
                              await ref
                                  .read(exportDirProvider.notifier)
                                  .setDir(pickedDir);
                            }
                          } catch (_) {}
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.folder_outlined,
                                  color: Color(0xFF475467), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.applyMarkExportFolder,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF475467),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      FsPickerField.formatBreakablePath(
                                          currentExportDir.isEmpty
                                              ? (Platform.isAndroid
                                                  ? '/storage/emulated/0'
                                                  : '/')
                                              : currentExportDir),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF1D2939),
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.edit_outlined,
                                  size: 18, color: Color(0xFF98A2B3)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // 7. снизу экрана кнопка "Наложить водяной знак"
              ElevatedButton(
                onPressed: _handleApplyMark,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.applyMarkButton,
                    style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
