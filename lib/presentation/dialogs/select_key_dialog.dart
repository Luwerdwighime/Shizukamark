import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../domain/models/key_info.dart';
import '../../l10n/app_localizations.dart';
import '../providers/keys_provider.dart';

class SelectKeyDialog extends ConsumerWidget {
  const SelectKeyDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final keysAsync = ref.watch(keysProvider);

    return AlertDialog(
      title: Text(l10n.selectKeyTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: keysAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ошибка: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (keys) {
            if (keys.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  l10n.keysEmpty,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              itemCount: keys.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final KeyInfo key = keys[index];
                final String title = key.name.isNotEmpty
                    ? key.name
                    : l10n.keysUnnamed(p.basename(key.keyPath));

                return ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontSize: 15),
                  ),
                  onTap: () => Navigator.of(context).pop(key),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(l10n.cancelButton),
        ),
      ],
    );
  }
}
