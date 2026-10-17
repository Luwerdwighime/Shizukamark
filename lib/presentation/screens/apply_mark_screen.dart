import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../core/result.dart';
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
  bool _useCustomSave = false;

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

    // 2. Resolve destination path if custom save is selected
    String? customPath;
    if (_useCustomSave) {
      final String baseName = p.basenameWithoutExtension(_inputAudioPath!);
      final String defaultFileName = '${baseName}_wm${chosenCodec.extension}';
      customPath = await FilePicker.platform.saveFile(
        dialogTitle: l10n.codecDialogTitle,
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: [chosenCodec.extension.replaceFirst('.', '')],
      );
      if (customPath == null) {
        return; // User cancelled save location picker
      }
    }

    // 3. Open progress dialog
    ProgressDialogState currentState = ProgressDialogState(
      steps: const [],
      progress: 0.0,
      currentOperation: l10n.progressPreparing,
    );

    late StateSetter setDialogState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
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

    // 4. Execute process
    final Result<String> result = await _controller.execute(
      secretMessage: secretMessage,
      inputAudioPath: _inputAudioPath!,
      selectedKey: _selectedKey!,
      codec: _selectedCodec,
      customSavePath: customPath,
      onProgress: (newState) {
        currentState = newState;
        if (mounted) {
          setDialogState(() {});
        }
      },
    );

    // Close progress dialog if still open
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (result.isSuccess && mounted) {
      // Pop back to home screen and show success SnackBar
      Navigator.of(context).pop();
      SnackBarService.showSuccess(
        context,
        l10n.applyMarkSuccessSaved(result.value ?? ''),
      );
    } else if (mounted) {
      SnackBarService.showError(
        context,
        result.error ?? l10n.errorApplyingWatermark,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.applyMarkTitle),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD0D5DD)),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<bool>(
                      value: false,
                      groupValue: _useCustomSave,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.applyMarkUseMediaStore,
                        style: const TextStyle(fontSize: 14),
                      ),
                      onChanged: (val) =>
                          setState(() => _useCustomSave = false),
                    ),
                    RadioListTile<bool>(
                      value: true,
                      groupValue: _useCustomSave,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.applyMarkUseCustomSave,
                        style: const TextStyle(fontSize: 14),
                      ),
                      onChanged: (val) => setState(() => _useCustomSave = true),
                    ),
                  ],
                ),
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
