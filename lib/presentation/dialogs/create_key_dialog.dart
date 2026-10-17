import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/result.dart';
import '../../domain/models/key_info.dart';
import '../../l10n/app_localizations.dart';
import '../providers/keys_provider.dart';
import '../widgets/snack_bar_service.dart';

class CreateKeyDialog extends ConsumerStatefulWidget {
  const CreateKeyDialog({super.key});

  @override
  ConsumerState<CreateKeyDialog> createState() => _CreateKeyDialogState();
}

class _CreateKeyDialogState extends ConsumerState<CreateKeyDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  bool _isValid(String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > 128) return false;
    for (final int cu in trimmed.codeUnits) {
      if ((cu < 32 && cu != 9 && cu != 10 && cu != 13) || cu == 127)
        return false;
    }
    return true;
  }

  void _onTextChanged(String text, AppLocalizations l10n) {
    setState(() {
      if (text.trim().isEmpty) {
        _errorText = l10n.createKeyErrorEmpty;
      } else if (text.trim().length > 128) {
        _errorText = l10n.createKeyErrorMaxLength;
      } else if (!_isValid(text)) {
        _errorText = l10n.createKeyErrorInvalidChars;
      } else {
        _errorText = null;
      }
    });
  }

  Future<void> _submit(AppLocalizations l10n) async {
    final String name = _controller.text.trim();
    if (!_isValid(name)) {
      setState(() {
        _errorText = l10n.createKeyErrorGeneral;
      });
      return;
    }

    setState(() => _isLoading = true);
    final Result<KeyInfo> result =
        await ref.read(keysProvider.notifier).createKey(name);
    setState(() => _isLoading = false);

    if (result.isSuccess && mounted) {
      Navigator.of(context).pop(result.value);
    } else if (mounted) {
      SnackBarService.showError(context, result.error ?? l10n.errorCreateKey);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool canSubmit = !_isLoading && _isValid(_controller.text);

    return AlertDialog(
      title: Text(l10n.createKeyTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.createKeyHint,
          errorText: _errorText,
        ),
        maxLength: 128,
        onChanged: (val) => _onTextChanged(val, l10n),
        onSubmitted: (_) {
          if (canSubmit) _submit(l10n);
        },
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(null),
          child: Text(l10n.cancelButton),
        ),
        ElevatedButton(
          onPressed: canSubmit ? () => _submit(l10n) : null,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.okButton),
        ),
      ],
    );
  }
}
