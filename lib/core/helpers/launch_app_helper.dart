import 'package:url_launcher/url_launcher.dart';
import '../services/notification_channel_service.dart';

/// Helper to launch an app by package name.
/// Tries the platform channel first, falls back to Play Store.
class LaunchAppHelper {
  LaunchAppHelper._();

  /// Attempt to launch the app by its package name.
  /// Returns true if successfully launched.
  static Future<bool> launchApp(String packageName) async {
    // Try native launch via platform channel
    final launched =
        await NotificationChannelService.instance.launchApp(packageName);
    if (launched) return true;

    // Fallback: open Play Store listing
    final playStoreUrl =
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
    try {
      return await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
