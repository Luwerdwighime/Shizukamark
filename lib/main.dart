import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/path_constants.dart';
import 'data/db/database_helper.dart';
import 'l10n/app_localizations.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initApp();
  runApp(const ProviderScope(child: ShizukamarkApp()));
}

/// Startup operations per spec:
/// 1. Create keys/ directory in getApplicationDocumentsDirectory() (chmod 770)
/// 2. Ensure messages.sqlite table exists
/// 3. Request permissions on Android 13+
Future<void> _initApp() async {
  // 1. Ensure keys directory
  try {
    final String keysPath = await PathConstants.getKeysDir();
    final Directory keysDir = Directory(keysPath);
    if (!await keysDir.exists()) {
      await keysDir.create(recursive: true);
      try {
        if (!Platform.isWindows) {
          await Process.run('chmod', ['770', keysDir.path]);
        }
      } catch (_) {}
    }
  } catch (_) {}

  // 2. Ensure database table
  try {
    final DatabaseHelper db = DatabaseHelper();
    await db.getDatabase();
  } catch (_) {}

  // 3. Request audio permissions on Android 13+
  try {
    if (Platform.isAndroid) {
      final PermissionStatus status = await Permission.audio.status;
      if (!status.isGranted) {
        await Permission.audio.request();
      }
    }
  } catch (_) {}
}

class ShizukamarkApp extends StatelessWidget {
  const ShizukamarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shizukamark',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      // Localization support
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ru'),

      home: const HomeScreen(),
    );
  }
}
