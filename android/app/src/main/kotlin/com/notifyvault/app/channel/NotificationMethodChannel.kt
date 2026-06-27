package com.notifyvault.app.channel

import android.content.ComponentName
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Settings
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
                    result.success(isNotificationListenerEnabled(activity))
                }

                "openPermissionSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    activity.startActivity(intent)
                    result.success(null)
                }

                "getActiveNotifications" -> {
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
}
