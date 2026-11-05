import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';

class LanguageMenuButton extends ConsumerWidget {
  const LanguageMenuButton({super.key});

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final currentLocale =
            ref.watch(localeProvider) ?? Localizations.localeOf(dialogCtx);

        return SimpleDialog(
          title: const Text('Language'),
          children: supportedLanguages.map((item) {
            final isSelected =
                currentLocale.languageCode == item.locale.languageCode;
            return SimpleDialogOption(
              onPressed: () {
                ref.read(localeProvider.notifier).setLocale(item.locale);
                Navigator.of(dialogCtx).pop();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Text(item.flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check, color: Colors.blueGrey),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'language') {
          _showLanguageDialog(context, ref);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'language',
          child: Text('Language 🎌'),
        ),
      ],
    );
  }
}
