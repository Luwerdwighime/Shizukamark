import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockManager {
  static Future<void> enable() async {
    try {
      await WakelockPlus.enable();
    } catch (_) {
      // Ignored if wakelock not available on current environment
    }
  }

  static Future<void> disable() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {
      // Ignored if wakelock not available on current environment
    }
  }
}
