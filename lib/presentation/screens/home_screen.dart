import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/result.dart';
import '../../data/zip/zip_service.dart';
import '../../l10n/app_localizations.dart';
import '../providers/keys_provider.dart';
import '../widgets/snack_bar_service.dart';
import 'apply_mark_screen.dart';
import 'keys_screen.dart';
import 'read_mark_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ApplyMarkScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.blueGrey.shade800,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.homeApplyMark,
                        style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ReadMarkScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.blueGrey.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.homeReadMark,
                        style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const KeysScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.blueGrey.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.homeKeys,
                        style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _handleImport(context, ref),
                    icon: const Icon(Icons.file_download_outlined),
                    label: Text(l10n.homeImport,
                        style: const TextStyle(fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _handleExport(context),
                    icon: const Icon(Icons.file_upload_outlined),
                    label: Text(l10n.homeExport,
                        style: const TextStyle(fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
