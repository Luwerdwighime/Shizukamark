import 'package:flutter/material.dart';
import '../../domain/models/key_info.dart';
import '../dialogs/select_key_dialog.dart';

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
    final bool hasSelection =
        selectedKey != null && selectedKey!.keyPath.isNotEmpty;
    final String displayText = hasSelection
        ? (selectedKey!.name.isNotEmpty
            ? selectedKey!.name
            : '(Без имени) · ${selectedKey!.keyPath.split('/').last}')
        : hintText;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0D5DD)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayText,
              style: TextStyle(
                fontSize: 15,
                color: hasSelection ? Colors.black87 : const Color(0xFF98A2B3),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Text(
              '🔍',
              style: TextStyle(fontSize: 20),
            ),
            tooltip: hintText,
            onPressed: () => _openSelectDialog(context),
          ),
        ],
      ),
    );
  }
}
