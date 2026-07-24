import 'package:shared_preferences/shared_preferences.dart';

/// Helper to track deletion timestamps and counts for accurate statistics reporting.
class DeletedTracker {
  static const String _key = 'deleted_notifications_log';

  /// Record deleted notifications count with current timestamp.
  static Future<void> recordDeletions(int count) async {
    if (count <= 0) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final logRaw = prefs.getStringList(_key) ?? [];
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      logRaw.add('$nowMs:$count');
      await prefs.setStringList(_key, logRaw);
    } catch (_) {}
  }

  /// Get total count of notifications deleted since [since].
  static Future<int> getDeletedCountSince(DateTime since) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logRaw = prefs.getStringList(_key) ?? [];
      final sinceMs = since.millisecondsSinceEpoch;
      int total = 0;
      for (final item in logRaw) {
        final parts = item.split(':');
        if (parts.length == 2) {
          final ts = int.tryParse(parts[0]) ?? 0;
          final count = int.tryParse(parts[1]) ?? 0;
          if (ts >= sinceMs) {
            total += count;
          }
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// Clear all recorded deletion logs.
  static Future<void> clearLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
