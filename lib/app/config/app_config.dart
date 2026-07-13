/// App-wide configuration constants.
class AppConfig {
  AppConfig._();

  // ─── App Info ───
  static const String appName = 'NotifyVault';
  static const String appTagline = 'Never Lose a Notification Again';
  static const String appVersion = '1.0.1';

  // ─── Platform Channels ───
  static const String notificationMethodChannel =
      'com.notifyvault.app/notifications';
  static const String notificationEventChannel =
      'com.notifyvault.app/notification_stream';

  // ─── Database ───
  static const String databaseName = 'notify_vault.db';
  static const int databaseVersion = 1;

  // ─── Pagination ───
  static const int pageSize = 30;
  static const int searchPageSize = 20;

  // ─── Search ───
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const int maxRecentSearches = 10;

  // ─── Retention ───
  static const int freeRetentionDays = 7;
  static const int premiumRetentionDays = -1; // unlimited

  // ─── Shared Preferences Keys ───
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationPermission = 'notification_permission';
  static const String keyRetentionPeriod = 'retention_period';
  static const String keyAppManagementUnlocked = 'app_mgmt_unlocked_session';

  // ─── Animation Durations ───
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(milliseconds: 2000);
}
