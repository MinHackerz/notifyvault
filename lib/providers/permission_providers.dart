import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/notification_channel_service.dart';

/// Notification listener permission state.
final notificationPermissionProvider =
    NotifierProvider<PermissionNotifier, AsyncValue<bool>>(
        PermissionNotifier.new);

class PermissionNotifier extends Notifier<AsyncValue<bool>> {
  final _service = NotificationChannelService.instance;

  @override
  AsyncValue<bool> build() {
    checkPermission();
    return const AsyncValue.loading();
  }

  Future<void> checkPermission() async {
    state = const AsyncValue.loading();
    try {
      final granted = await _service.isPermissionGranted();
      state = AsyncValue.data(granted);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> openSettings() async {
    await _service.openPermissionSettings();
  }
}
