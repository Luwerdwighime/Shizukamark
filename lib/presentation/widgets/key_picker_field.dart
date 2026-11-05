import 'package:flutter/material.dart';
import '../../domain/models/key_info.dart';
import '../../l10n/app_localizations.dart';
import '../dialogs/select_key_dialog.dart';
import 'fs_picker_field.dart';

class KeyPickerField extends StatelessWidget {
  final KeyInfo? selectedKey;
  final String hintText;
  final ValueChanged<KeyInfo> onKeySelected;

  const KeyPickerField({
    super.key,
    required this.selectedKey,
    required this.hintText,
    required this.onKeySelected,
  });

  Future<void> _openSelectDialog(BuildContext context) async {
    final KeyInfo? picked = await showDialog<KeyInfo>(
      context: context,
      builder: (ctx) => const SelectKeyDialog(),
    );
    if (picked != null) {
      onKeySelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool hasSelection =
        selectedKey != null && selectedKey!.keyPath.isNotEmpty;
    final String rawFileName =
        hasSelection ? selectedKey!.keyPath.split('/').last : '';
    final String breakableFileName =
        FsPickerField.formatBreakablePath(rawFileName);
    final String unnamed = l10n != null
        ? l10n.keysUnnamed(breakableFileName)
        : '(Unnamed) · $breakableFileName';
    final String displayText = hasSelection
        ? (selectedKey!.name.isNotEmpty
            ? FsPickerField.formatBreakablePath(selectedKey!.name)
            : unnamed)
        : hintText;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD0D5DD)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openSelectDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: hasSelection ? 13 : 15,
                      height: 1.25,
                      color: hasSelection
                          ? Colors.black87
                          : const Color(0xFF98A2B3),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '🔍',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
