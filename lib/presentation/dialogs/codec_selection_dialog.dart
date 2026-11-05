import 'package:flutter/material.dart';
import '../../domain/models/audio_codec.dart';
import '../../l10n/app_localizations.dart';

class CodecSelectionDialog extends StatefulWidget {
  final AudioCodec initialCodec;

  const CodecSelectionDialog({
    super.key,
    this.initialCodec = AudioCodec.aac,
  });

  @override
  State<CodecSelectionDialog> createState() => _CodecSelectionDialogState();
}

class _CodecSelectionDialogState extends State<CodecSelectionDialog> {
  late AudioCodec _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCodec;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.codecDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4),
              child: Text(
                l10n.codecLossyHeader,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
            ),
            _buildRadio(AudioCodec.aac, l10n),
            _buildRadio(AudioCodec.opus, l10n),
            _buildRadio(AudioCodec.mp3, l10n),
            const Divider(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              child: Text(
                l10n.codecLosslessHeader,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
            ),
            _buildRadio(AudioCodec.flac, l10n),
            _buildRadio(AudioCodec.wav, l10n),
            _buildRadio(AudioCodec.alac, l10n),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancelButton),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: Text(l10n.codecSelectButton),
        ),
      ],
    );
  }

  Widget _buildRadio(AudioCodec codec, AppLocalizations l10n) {
    final String label = (codec == AudioCodec.aac)
        ? l10n.codecAacRecommended
        : codec.displayName;
    return RadioListTile<AudioCodec>(
      value: codec,
      groupValue: _selected,
      dense: true,
      title: Text(label),
      onChanged: (val) {
        if (val != null) setState(() => _selected = val);
      },
    );
  }
}
