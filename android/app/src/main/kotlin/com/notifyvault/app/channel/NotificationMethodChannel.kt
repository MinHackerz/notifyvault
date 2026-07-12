package com.notifyvault.app.channel

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import com.notifyvault.app.service.NotificationCaptureService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Sets up Flutter MethodChannel and EventChannel for notification communication.
 */
class NotificationMethodChannel(private val flutterEngine: FlutterEngine) {

    companion object {
        private const val METHOD_CHANNEL = "com.notifyvault.app/notifications"
        private const val EVENT_CHANNEL = "com.notifyvault.app/notification_stream"
    }

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    fun setup(activity: android.app.Activity) {
        setupMethodChannel(activity)
        setupEventChannel()
    }

    private fun setupMethodChannel(activity: android.app.Activity) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPermissionGranted" -> {
                    val enabled = isNotificationListenerEnabled(activity)
                    if (enabled && NotificationCaptureService.instance == null) {
                        rebindService(activity)
                    }
                    result.success(enabled)
                }

                "openPermissionSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    activity.startActivity(intent)
                    result.success(null)
                }

                "getActiveNotifications" -> {
                    val enabled = isNotificationListenerEnabled(activity)
                    if (enabled && NotificationCaptureService.instance == null) {
                        rebindService(activity)
                    }
                    val service = NotificationCaptureService.instance
                    if (service != null) {
                        val notifications = service.getActiveNotificationsList()
                        result.success(notifications)
                    } else {
                        result.success(emptyList<Map<String, Any?>>())
                    }
                }

                "dismissNotification" -> {
                    val key = call.argument<String>("key")
                    if (key != null) {
                        NotificationCaptureService.instance?.dismissNotificationByKey(key)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Key is required", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun setupEventChannel() {
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events

                // Register the callback so the service forwards notifications
                NotificationCaptureService.onNotificationPostedCallback = { data ->
                    mainHandler.post {
                        eventSink?.success(data)
                    }
                }

                NotificationCaptureService.onNotificationRemovedCallback = { data ->
                    mainHandler.post {
                        eventSink?.success(data)
                    }
                }
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                NotificationCaptureService.onNotificationPostedCallback = null
                NotificationCaptureService.onNotificationRemovedCallback = null
            }
        })
    }

    /**
     * Check if the notification listener permission is granted for this app.
     */
    private fun isNotificationListenerEnabled(activity: android.app.Activity): Boolean {
        val cn = ComponentName(activity, NotificationCaptureService::class.java)
        val flat = Settings.Secure.getString(
            activity.contentResolver,
            "enabled_notification_listeners"
        )
        return flat != null && flat.contains(cn.flattenToString())
    }

    /**
     * Force-rebinds the notification listener service by toggling its component enabled state.
     * This is useful during development or updates when the Android system fails to bind to the service.
     */
    private fun rebindService(activity: android.app.Activity) {
        try {
            val pm = activity.packageManager
            val cn = ComponentName(activity, NotificationCaptureService::class.java)
            pm.setComponentEnabledSetting(
                cn,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
            pm.setComponentEnabledSetting(
                cn,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
            Log.d("NotifyVault", "Forced NotificationCaptureService rebind via PackageManager")
        } catch (e: Exception) {
            Log.e("NotifyVault", "Failed to force rebind: ${e.message}")
        }
    }
}
