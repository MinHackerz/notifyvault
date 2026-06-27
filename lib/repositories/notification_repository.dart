import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/notification_model.dart';
import '../core/services/category_service.dart';
import '../core/services/notification_channel_service.dart';

/// Repository that bridges the notification data layer — platform channel,
/// local database, and category service.
class NotificationRepository {
  final AppDatabase _db;
  final CategoryService _categoryService;
  final NotificationChannelService _channelService;

  StreamSubscription? _notificationSubscription;

  NotificationRepository({
    AppDatabase? database,
    CategoryService? categoryService,
    NotificationChannelService? channelService,
  })  : _db = database ?? AppDatabase.instance,
        _categoryService = categoryService ?? CategoryService.instance,
        _channelService = channelService ?? NotificationChannelService.instance;

  /// Start listening for incoming notifications from the native platform.
  void startListening() {
    _notificationSubscription?.cancel();
    _notificationSubscription = _channelService.notificationStream.listen(
      _handleIncomingNotification,
      onError: (error) {
        // Log error, don't crash
      },
    );
  }

  /// Stop listening for notifications.
  void stopListening() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }

  /// Handle a notification arriving from the native side.
  Future<void> _handleIncomingNotification(Map<String, dynamic> data) async {
    // Skip group summaries
    if (data['isGroupSummary'] == true) return;

    // Handle removal events — don't create new entries, just mark as dismissed
    final action = data['action'] as String?;
    if (action == 'removed' || data['isDismissed'] == true) {
      final id = data['id'] as String?;
      if (id != null) {
        try {
          await _db.notificationDao.markAsDismissed(id);
        } catch (_) {
          // Entry may not exist, that's fine
        }
      }
      return;
    }

    // Build the model from platform data
    final model = NotificationModel.fromPlatformData(data);

    // Skip notifications with no meaningful content
    if ((model.title == null || model.title!.isEmpty) &&
        (model.body == null || model.body!.isEmpty) &&
        (model.bigText == null || model.bigText!.isEmpty)) {
      return;
    }

    // Auto-categorize
    final category = _categoryService.categorize(
      packageName: model.packageName,
      title: model.title,
      body: model.body,
      bigText: model.bigText,
    );

    final categorizedModel = model.copyWith(category: category);

    // Save to database
    await saveNotification(categorizedModel);
  }

  /// Save a notification to the local database.
  Future<void> saveNotification(NotificationModel notification) async {
    final companion = NotificationsCompanion(
      id: Value(notification.id),
      packageName: Value(notification.packageName),
      appName: Value(notification.appName),
      title: Value(notification.title),
      body: Value(notification.body),
      bigText: Value(notification.bigText),
      timestamp: Value(notification.timestamp),
      category: Value(notification.category),
      importance: Value(notification.importance),
      isRead: Value(notification.isRead),
      isDismissed: Value(notification.isDismissed),
      senderName: Value(notification.senderName),
      conversationId: Value(notification.conversationId),
      imagePath: Value(notification.imagePath),
      iconPath: Value(notification.iconPath),
      extras: Value(
        notification.extras != null ? jsonEncode(notification.extras) : null,
      ),
      deviceId: Value(notification.deviceId),
      isFavorite: Value(notification.isFavorite),
      isSynced: Value(notification.isSynced),
    );

    await _db.notificationDao.insertNotification(companion);

    // Also update the app tracker
    await _db.appDao.incrementCount(
      notification.packageName,
      notification.appName,
    );
  }

  /// Get paginated notifications.
  Future<List<NotificationModel>> getNotifications({
    int limit = 30,
    int offset = 0,
  }) async {
    final results = await _db.notificationDao.getNotifications(
      limit: limit,
      offset: offset,
    );
    return results.map(_toModel).toList();
  }

  /// Watch notifications as a reactive stream.
  Stream<List<NotificationModel>> watchNotifications({int limit = 100}) {
    return _db.notificationDao
        .watchNotifications(limit: limit)
        .map((list) => list.map(_toModel).toList());
  }

  /// Get a single notification by ID.
  Future<NotificationModel?> getNotificationById(String id) async {
    final result = await _db.notificationDao.getNotificationById(id);
    return result != null ? _toModel(result) : null;
  }

  /// Search notifications.
  Future<List<NotificationModel>> searchNotifications(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final results = await _db.notificationDao.searchNotifications(
      query,
      limit: limit,
      offset: offset,
    );
    return results.map(_toModel).toList();
  }

  /// Get notifications by category.
  Future<List<NotificationModel>> getByCategory(
    String category, {
    int limit = 30,
    int offset = 0,
  }) async {
    final results = await _db.notificationDao.getByCategory(
      category,
      limit: limit,
      offset: offset,
    );
    return results.map(_toModel).toList();
  }

  /// Get favorite notifications.
  Future<List<NotificationModel>> getFavorites({
    int limit = 30,
    int offset = 0,
  }) async {
    final results = await _db.notificationDao.getFavorites(
      limit: limit,
      offset: offset,
    );
    return results.map(_toModel).toList();
  }

  /// Watch favorites.
  Stream<List<NotificationModel>> watchFavorites() {
    return _db.notificationDao
        .watchFavorites()
        .map((list) => list.map(_toModel).toList());
  }

  /// Today's notifications.
  Future<List<NotificationModel>> getTodayNotifications() async {
    final results = await _db.notificationDao.getTodayNotifications();
    return results.map(_toModel).toList();
  }

  /// Today's count.
  Future<int> getTodayCount() => _db.notificationDao.getTodayCount();

  /// Unread count.
  Future<int> getUnreadCount() => _db.notificationDao.getUnreadCount();

  /// Total count.
  Future<int> getTotalCount() => _db.notificationDao.getTotalCount();

  /// Active apps today.
  Future<int> getActiveAppsToday() => _db.notificationDao.getActiveAppsToday();

  /// Toggle favorite.
  Future<void> toggleFavorite(String id) =>
      _db.notificationDao.toggleFavorite(id);

  /// Mark as read.
  Future<void> markAsRead(String id) => _db.notificationDao.markAsRead(id);

  /// Delete a notification.
  Future<void> deleteNotification(String id) =>
      _db.notificationDao.deleteNotification(id);

  /// Delete old notifications (retention policy).
  Future<int> deleteOlderThan(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _db.notificationDao.deleteOlderThan(cutoff);
  }

  /// Clear all data.
  Future<void> clearAll() async {
    await _db.notificationDao.deleteAll();
    await _db.appDao.deleteAll();
  }

  /// Seeds a list of diverse mock notifications into the database.
  Future<void> seedTestNotifications() async {
    final now = DateTime.now();
    final testData = [
      {
        'packageName': 'com.google.android.apps.authenticator2',
        'appName': 'Google Authenticator',
        'title': 'Google Verification Code',
        'body': 'Your OTP code is 482910. It is valid for 10 minutes.',
        'timestamp': now.subtract(const Duration(minutes: 2)),
      },
      {
        'packageName': 'com.whatsapp',
        'appName': 'WhatsApp',
        'title': 'Alex Rivera',
        'body': 'Hey, are we still meeting today at 5 PM for the project review?',
        'senderName': 'Alex Rivera',
        'timestamp': now.subtract(const Duration(minutes: 15)),
      },
      {
        'packageName': 'com.chase.sig.android',
        'appName': 'Chase Bank',
        'title': 'Transaction Alert',
        'body': 'A purchase of \$400.00 at Apple Store was authorized on your card ending in 4920.',
        'timestamp': now.subtract(const Duration(hours: 1)),
      },
      {
        'packageName': 'com.amazon.mShop.android.shopping',
        'appName': 'Amazon',
        'title': 'Delivered',
        'body': 'Your package with tracking ID USPS-839210 was delivered at the front door.',
        'timestamp': now.subtract(const Duration(hours: 3)),
      },
      {
        'packageName': 'com.venmo',
        'appName': 'Venmo',
        'title': 'Venmo Payment',
        'body': 'Alex Rivera paid you \$25.00 for Dinner & Drinks 🍕',
        'timestamp': now.subtract(const Duration(hours: 4)),
      },
      {
        'packageName': 'com.slack',
        'appName': 'Slack',
        'title': '#product-design',
        'body': 'Zaid Mukaddam: Let\'s ensure the Latch-inspired design changes are fully pushed.',
        'timestamp': now.subtract(const Duration(hours: 6)),
      },
      {
        'packageName': 'com.netflix.mediaclient',
        'appName': 'Netflix',
        'title': 'New Release',
        'body': 'A new season of Dark is now streaming. Watch now!',
        'timestamp': now.subtract(const Duration(hours: 12)),
      },
      {
        'packageName': 'com.google.android.apps.fitness',
        'appName': 'Google Fit',
        'title': 'Goal Achieved!',
        'body': 'Congratulations! You reached your daily step goal of 10,000 steps.',
        'timestamp': now.subtract(const Duration(hours: 18)),
      },
      {
        'packageName': 'com.zomato.android',
        'appName': 'Zomato',
        'title': 'Order Dispatched',
        'body': 'Your delivery partner is on the way with your food order from Pizzeria.',
        'timestamp': now.subtract(const Duration(days: 1)),
      },
      {
        'packageName': 'com.instagram.android',
        'appName': 'Instagram',
        'title': 'Instagram Alert',
        'body': 'Sarah Jenkins liked your recent photo.',
        'timestamp': now.subtract(const Duration(days: 1, hours: 2)),
      },
      {
        'packageName': 'com.google.android.gm',
        'appName': 'Gmail',
        'title': 'NotifyVault Support',
        'body': 'Welcome to NotifyVault! Confirm your registration and explore premium features.',
        'timestamp': now.subtract(const Duration(days: 2)),
      },
      {
        'packageName': 'com.sec.android.app.myfiles',
        'appName': 'System Backup',
        'title': 'Spam Alert',
        'body': 'CONGRATULATIONS! You won a \$1000 Walmart Gift Card! Click here to claim: http://megaoffers.com',
        'timestamp': now.subtract(const Duration(days: 2, hours: 4)),
      },
    ];

    for (var i = 0; i < testData.length; i++) {
      final data = testData[i];
      final id = 'test_${now.millisecondsSinceEpoch}_$i';
      
      final packageName = data['packageName'] as String;
      final appName = data['appName'] as String;
      final title = data['title'] as String;
      final body = data['body'] as String;
      final timestamp = data['timestamp'] as DateTime;
      final senderName = data['senderName'] as String?;

      // Auto-categorize
      final category = _categoryService.categorize(
        packageName: packageName,
        title: title,
        body: body,
      );

      final model = NotificationModel(
        id: id,
        packageName: packageName,
        appName: appName,
        title: title,
        body: body,
        timestamp: timestamp,
        category: category,
        senderName: senderName,
        isRead: false,
        isDismissed: false,
      );

      await saveNotification(model);
    }
  }

  /// Get category counts.
  Future<Map<String, int>> getCategoryCounts() =>
      _db.notificationDao.getCategoryCounts();

  /// Check notification permission.
  Future<bool> isPermissionGranted() =>
      _channelService.isPermissionGranted();

  /// Open permission settings.
  Future<void> openPermissionSettings() =>
      _channelService.openPermissionSettings();

  /// Convert a Drift Notification row to NotificationModel.
  NotificationModel _toModel(Notification row) {
    Map<String, dynamic>? extras;
    if (row.extras != null) {
      try {
        extras = jsonDecode(row.extras!) as Map<String, dynamic>;
      } catch (_) {}
    }

    return NotificationModel(
      id: row.id,
      packageName: row.packageName,
      appName: row.appName,
      title: row.title,
      body: row.body,
      bigText: row.bigText,
      timestamp: row.timestamp,
      category: row.category,
      importance: row.importance,
      isRead: row.isRead,
      isDismissed: row.isDismissed,
      senderName: row.senderName,
      conversationId: row.conversationId,
      imagePath: row.imagePath,
      iconPath: row.iconPath,
      extras: extras,
      deviceId: row.deviceId,
      isFavorite: row.isFavorite,
      isSynced: row.isSynced,
    );
  }
}
