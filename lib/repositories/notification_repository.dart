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
      appCategory: data['appCategory'] as String?,
      notificationCategory: data['category'] as String?,
      isMessagingStyle: data['isMessagingStyle'] as bool? ?? false,
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
