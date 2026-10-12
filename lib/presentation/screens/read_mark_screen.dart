import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/result.dart';
import '../../domain/models/progress_state.dart';
import '../../l10n/app_localizations.dart';
import '../dialogs/progress_dialog.dart';
import '../providers/read_mark_controller.dart';
import '../widgets/fs_picker_field.dart';
import '../widgets/snack_bar_service.dart';

class ReadMarkScreen extends StatefulWidget {
  const ReadMarkScreen({super.key});

  @override
  State<ReadMarkScreen> createState() => _ReadMarkScreenState();
}

class _ReadMarkScreenState extends State<ReadMarkScreen> {
  String? _inputAudioPath;
  String _extractedMessage = '';
  bool _isPatient = false;

  final ReadMarkController _controller = ReadMarkController();

  Future<void> _handleReadMark() async {
    final l10n = AppLocalizations.of(context)!;
    if (_inputAudioPath == null || _inputAudioPath!.isEmpty) {
      SnackBarService.showError(context, l10n.readMarkErrorNoFile);
      return;
    }

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

    final Result<String> result = await _controller.execute(
      inputAudioPath: _inputAudioPath!,
      isPatient: _isPatient,
      onProgress: (newState) {
        currentState = newState;
        if (mounted) {
          setDialogState(() {});
        }
      },
    );

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (result.isSuccess && mounted) {
      setState(() {
        _extractedMessage = result.value ?? '';
      });
      SnackBarService.showSuccess(context, l10n.readMarkSuccess);
    } else if (mounted) {
      SnackBarService.showError(
        context,
        result.error ?? l10n.errorWatermarkNotFound,
      );
    }
  }

  void _copyToClipboard() {
    final l10n = AppLocalizations.of(context)!;
    if (_extractedMessage.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _extractedMessage));
      SnackBarService.showSuccess(context, l10n.readMarkCopied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool hasMessage = _extractedMessage.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.readMarkTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. МФС для музла
              FsPickerField(
                selectedPath: _inputAudioPath,
                hintText: l10n.readMarkFileHint,
                onFileSelected: (path) => setState(() => _inputAudioPath = path),
              ),
              const SizedBox(height: 12),

              // 2. Серым hint шрифтом
              Text(
                l10n.readMarkImportHint,
                style: const TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // 3. Блок вывода секретного сообщения с SelectableText и кнопкой копирования
              Container(
                constraints: const BoxConstraints(minHeight: 110),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD0D5DD)),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SelectableText(
                      hasMessage ? _extractedMessage : l10n.readMarkOutputHint,
                      minLines: 4,
                      style: TextStyle(
                        fontSize: 15,
                        color: hasMessage ? Colors.black87 : const Color(0xFF98A2B3),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton.icon(
                        onPressed: hasMessage ? _copyToClipboard : null,
                        icon: const Text('📋', style: TextStyle(fontSize: 16)),
                        label: Text(l10n.readMarkCopyButton),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Галочка переключателя: "Использовать усердное чтение"
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPatient,
                title: Text(
                  l10n.readMarkPatientCheckbox,
                  style: const TextStyle(fontSize: 15),
                ),
                subtitle: Text(
                  l10n.readMarkPatientSubtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                onChanged: (val) {
                  setState(() => _isPatient = val ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),

              // 5. Кнопка "Прочитать водяной знак"
              ElevatedButton(
                onPressed: _handleReadMark,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.readMarkButton, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
