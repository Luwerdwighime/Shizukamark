import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FsPickerField extends StatelessWidget {
  final String? selectedPath;
  final String hintText;
  final List<String>? allowedExtensions;
  final ValueChanged<String> onFileSelected;

  const FsPickerField({
    super.key,
    required this.selectedPath,
    required this.hintText,
    required this.onFileSelected,
    this.allowedExtensions = const ['mp3', 'wav', 'flac', 'm4a', 'aac', 'opus', 'ogg'],
  });

  Future<void> _pickFile(BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        onFileSelected(result.files.single.path!);
      }
    } catch (e) {
      // Ignored if cancelled
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selectedPath != null && selectedPath!.isNotEmpty;

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
              hasSelection ? selectedPath! : hintText,
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
            onPressed: () => _pickFile(context),
          ),
        ],
      ),
    );
  }
}
