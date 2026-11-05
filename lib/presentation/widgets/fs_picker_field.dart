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
    this.allowedExtensions = const [
      'mp3',
      'wav',
      'flac',
      'm4a',
      'aac',
      'opus',
      'ogg'
    ],
  });

  /// Inserts zero-width spaces after slashes and dots to allow wrapping at these points
  static String formatBreakablePath(String path) {
    return path
        .replaceAll('/', '/\u200B')
        .replaceAll('\\', '\\\u200B')
        .replaceAll('.', '.\u200B');
  }

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
    final String displayText = hasSelection
        ? formatBreakablePath(selectedPath!)
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
          onTap: () => _pickFile(context),
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
