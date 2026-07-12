package com.notifyvault.app.service

import android.app.Notification
import android.content.pm.PackageManager
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable

/**
 * Android NotificationListenerService that captures all device notifications
 * and forwards them to Flutter via an EventChannel broadcast.
 */
class NotificationCaptureService : NotificationListenerService() {

    companion object {
        private const val TAG = "NotifyVault"

        // Singleton reference so Flutter can access the service
        var instance: NotificationCaptureService? = null
            private set

        // Callback for streaming notifications to Flutter
        var onNotificationPostedCallback: ((Map<String, Any?>) -> Unit)? = null
        var onNotificationRemovedCallback: ((Map<String, Any?>) -> Unit)? = null
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.d(TAG, "NotificationCaptureService created")
    }

    override fun onDestroy() {
        instance = null
        super.onDestroy()
        Log.d(TAG, "NotificationCaptureService destroyed")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return

        // Skip our own notifications to avoid loops
        if (sbn.packageName == packageName) return

        try {
            val data = extractNotificationData(sbn)
            onNotificationPostedCallback?.invoke(data)
            Log.d(TAG, "Notification captured from: ${sbn.packageName}")
        } catch (e: Exception) {
            Log.e(TAG, "Error processing notification: ${e.message}")
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        if (sbn == null) return
        if (sbn.packageName == packageName) return

        try {
            val data = mapOf(
                "id" to sbn.key,
                "packageName" to sbn.packageName,
                "timestamp" to sbn.postTime,
                "isDismissed" to true,
                "action" to "removed"
            )
            onNotificationRemovedCallback?.invoke(data)
        } catch (e: Exception) {
            Log.e(TAG, "Error processing notification removal: ${e.message}")
        }
    }

    /**
     * Extract all relevant data from a StatusBarNotification.
     */
    private fun extractNotificationData(sbn: StatusBarNotification): Map<String, Any?> {
        val notification = sbn.notification
        val extras = notification.extras

        // Get app name
        val appName = try {
            val appInfo = packageManager.getApplicationInfo(sbn.packageName, 0)
            packageManager.getApplicationLabel(appInfo).toString()
        } catch (e: PackageManager.NameNotFoundException) {
            sbn.packageName
        }

        // Extract title and body
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()
        val body = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
        val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()
        val summaryText = extras.getCharSequence(Notification.EXTRA_SUMMARY_TEXT)?.toString()

        // Extract sender for messaging-style notifications
        val senderName = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val messages = Notification.MessagingStyle.Message.getMessagesFromBundleArray(
                extras.getParcelableArray(Notification.EXTRA_MESSAGES)?.mapNotNull { it as? android.os.Bundle }?.toTypedArray()
                    ?: emptyArray()
            )
            messages.lastOrNull()?.senderPerson?.name?.toString()
        } else {
            extras.getCharSequence(Notification.EXTRA_INFO_TEXT)?.toString()
        }

        // Extract conversation title
        val conversationTitle = extras.getCharSequence(Notification.EXTRA_CONVERSATION_TITLE)?.toString()

        // Get importance / priority
        val importance = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Map channel importance to our 1-5 scale
            notification.channelId?.let { channelId ->
                try {
                    val channel = (getSystemService(NOTIFICATION_SERVICE) as android.app.NotificationManager)
                        .getNotificationChannel(channelId)
                    channel?.importance ?: 3
                } catch (e: Exception) {
                    3
                }
            } ?: 3
        } else {
            @Suppress("DEPRECATION")
            when (notification.priority) {
                Notification.PRIORITY_MIN -> 1
                Notification.PRIORITY_LOW -> 2
                Notification.PRIORITY_DEFAULT -> 3
                Notification.PRIORITY_HIGH -> 4
                Notification.PRIORITY_MAX -> 5
                else -> 3
            }
        }

        val iconPath = saveAppIcon(sbn.packageName)

        // Build the data map
        return mapOf(
            "id" to sbn.key,
            "packageName" to sbn.packageName,
            "appName" to appName,
            "title" to title,
            "body" to body,
            "bigText" to bigText,
            "subText" to subText,
            "summaryText" to summaryText,
            "timestamp" to sbn.postTime,
            "importance" to importance,
            "isRead" to false,
            "isDismissed" to false,
            "senderName" to (senderName ?: conversationTitle),
            "conversationId" to conversationTitle,
            "isGroupSummary" to (sbn.notification.flags.and(Notification.FLAG_GROUP_SUMMARY) != 0),
            "groupKey" to sbn.groupKey,
            "category" to notification.category,
            "iconPath" to iconPath,
            "action" to "posted"
        )
    }

    private fun saveAppIcon(packageName: String): String? {
        try {
            val iconDir = File(filesDir, "icons")
            if (!iconDir.exists()) {
                iconDir.mkdirs()
            }
            val iconFile = File(iconDir, "$packageName.png")

            // If already cached, just return the path
            if (iconFile.exists()) {
                return iconFile.absolutePath
            }

            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            val drawable = try {
                packageManager.getApplicationIcon(appInfo)
            } catch (e: Exception) {
                null
            }
            if (drawable == null) return null

            // Convert drawable to Bitmap
            val bitmap = if (drawable is BitmapDrawable) {
                drawable.bitmap
            } else {
                val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 96
                val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 96
                val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bmp)
                drawable.setBounds(0, 0, canvas.width, canvas.height)
                drawable.draw(canvas)
                bmp
            }

            // Save to disk
            FileOutputStream(iconFile).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }
            return iconFile.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "Error saving app icon: ${e.message}")
            return null
        }
    }

    /**
     * Get all currently active notifications (called from Flutter).
     */
    fun getActiveNotificationsList(): List<Map<String, Any?>> {
        return try {
            activeNotifications
                ?.filter { it.packageName != packageName }
                ?.map { extractNotificationData(it) }
                ?: emptyList()
        } catch (e: Exception) {
            Log.e(TAG, "Error getting active notifications: ${e.message}")
            emptyList()
        }
    }

    /**
     * Cancel/dismiss a notification by key.
     */
    fun dismissNotificationByKey(key: String) {
        try {
            cancelNotification(key)
        } catch (e: Exception) {
            Log.e(TAG, "Error dismissing notification: ${e.message}")
        }
    }
}
