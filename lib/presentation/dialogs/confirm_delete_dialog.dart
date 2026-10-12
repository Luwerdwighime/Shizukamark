import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String keyName;

  const ConfirmDeleteDialog({
    super.key,
    required this.keyName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.keysDeleteTitle),
      content: Text(l10n.keysDeleteConfirm(keyName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.okButton),
        ),
      ],
    );
  }
}
