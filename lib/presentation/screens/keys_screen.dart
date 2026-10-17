import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../core/result.dart';
import '../../data/zip/zip_service.dart';
import '../../domain/models/key_info.dart';
import '../../l10n/app_localizations.dart';
import '../dialogs/confirm_delete_dialog.dart';
import '../dialogs/create_key_dialog.dart';
import '../providers/keys_provider.dart';
import '../widgets/snack_bar_service.dart';

class KeysScreen extends ConsumerWidget {
  const KeysScreen({super.key});

  Future<void> _handleDeleteKey(
      BuildContext context, WidgetRef ref, KeyInfo key) async {
    final l10n = AppLocalizations.of(context)!;
    final String displayName =
        key.name.isNotEmpty ? key.name : p.basename(key.keyPath);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDeleteDialog(keyName: displayName),
    );

    if (confirmed == true) {
      final Result<void> delRes =
          await ref.read(keysProvider.notifier).deleteKey(key.keyPath);
      if (delRes.isSuccess && context.mounted) {
        SnackBarService.showSuccess(context, l10n.keysDeleted);
      } else if (context.mounted) {
        SnackBarService.showError(context, delRes.error ?? l10n.errorDeleteKey);
      }
    }
  }

  Future<void> _handleCreateKey(BuildContext context) async {
    await showDialog<KeyInfo>(
      context: context,
      builder: (ctx) => const CreateKeyDialog(),
    );
  }

  Future<void> _handleImport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        final String zipPath = result.files.single.path!;
        final ZipService zipService = ZipService();
        final Result<void> importRes = await zipService.zipIn(zipPath);

        if (importRes.isSuccess && context.mounted) {
          await ref.read(keysProvider.notifier).loadKeys();
          SnackBarService.showSuccess(context, l10n.importSuccess);
        } else if (context.mounted) {
          SnackBarService.showError(
            context,
            importRes.error ?? l10n.importErrorBadZip,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
            context, l10n.importErrorGeneral(e.toString()));
      }
    }
  }

  Future<void> _handleExport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final String defaultName =
          'shizukamark_export_${DateTime.now().millisecondsSinceEpoch}.zip';
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: l10n.exportDialogTitle,
        fileName: defaultName,
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (outputPath != null) {
        if (!outputPath.toLowerCase().endsWith('.zip')) {
          outputPath = '$outputPath.zip';
        }
        final ZipService zipService = ZipService();
        final Result<void> exportRes = await zipService.zipOut(outputPath);

        if (exportRes.isSuccess && context.mounted) {
          SnackBarService.showSuccess(context, l10n.exportSuccess);
        } else if (context.mounted) {
          SnackBarService.showError(
            context,
            exportRes.error ?? l10n.errorExportData,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarService.showError(
            context, l10n.exportErrorGeneral(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final keysAsync = ref.watch(keysProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.keysTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Многострочный пролистываемый список ключей
              Expanded(
                child: keysAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Text('Ошибка: $err',
                        style: const TextStyle(color: Colors.red)),
                  ),
                  data: (keys) {
                    if (keys.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.keysEmpty,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: keys.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final KeyInfo key = keys[index];
                        final String title = key.name.isNotEmpty
                            ? key.name
                            : l10n.keysUnnamed(p.basename(key.keyPath));

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFD0D5DD)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          child: Row(
                            children: [
                              // Left: non-editable text field with key name
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(fontSize: 15),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Right: cross button with strict width
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                icon: const Text(
                                  '✕',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFFD32F2F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                tooltip: l10n.keysDeleteTitle,
                                onPressed: () =>
                                    _handleDeleteKey(context, ref, key),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 2. Кнопка "Создать новый ключ"
              ElevatedButton.icon(
                onPressed: () => _handleCreateKey(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.keysCreateButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Кнопка "Импорт данных"
              OutlinedButton.icon(
                onPressed: () => _handleImport(context, ref),
                icon: const Icon(Icons.file_download_outlined),
                label: Text(l10n.homeImport),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 8),

              // 4. Кнопка "Экспорт данных"
              OutlinedButton.icon(
                onPressed: () => _handleExport(context),
                icon: const Icon(Icons.file_upload_outlined),
                label: Text(l10n.homeExport),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
