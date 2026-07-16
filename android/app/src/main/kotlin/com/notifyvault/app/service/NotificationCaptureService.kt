package com.notifyvault.app.service

import android.app.Notification
import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.ApplicationInfo
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import android.speech.tts.TextToSpeech
import java.util.Locale
import java.io.File
import java.io.FileOutputStream
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.app.KeyguardManager
import com.notifyvault.app.database.DatabaseHelper

/**
 * Android NotificationListenerService that captures all device notifications
 * and forwards them to Flutter via an EventChannel broadcast.
 */
class NotificationCaptureService : NotificationListenerService(), TextToSpeech.OnInitListener {

    private var tts: TextToSpeech? = null
    private var isTtsInitialized = false
    private var pendingTtsText: String? = null
    
    private var lastSpokenText: String? = null
    private var lastSpokenTime: Long = 0

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
        tts = TextToSpeech(this, this)
        Log.d(TAG, "NotificationCaptureService created")
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val audioAttributes = android.media.AudioAttributes.Builder()
                .setUsage(android.media.AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SPEECH)
                .build()
            tts?.setAudioAttributes(audioAttributes)
            tts?.language = Locale.getDefault()
            isTtsInitialized = true
            
            pendingTtsText?.let {
                DatabaseHelper.logToFile(applicationContext, "Playing queued TTS text")
                tts?.speak(it, TextToSpeech.QUEUE_ADD, null, "NotificationTTS")
                pendingTtsText = null
            }
        } else {
            Log.e(TAG, "TTS Initialization failed!")
            DatabaseHelper.logToFile(applicationContext, "TTS Initialization failed with status: $status")
        }
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        instance = null
        super.onDestroy()
        Log.d(TAG, "NotificationCaptureService destroyed")
    }

    private fun isAppInForeground(): Boolean {
        try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as? android.app.ActivityManager ?: return false
            val appProcesses = activityManager.runningAppProcesses ?: return false
            val pkgName = packageName
            for (appProcess in appProcesses) {
                if (appProcess.processName == pkgName) {
                    val inForeground = appProcess.importance == android.app.ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
                    DatabaseHelper.logToFile(applicationContext, "isAppInForeground: $inForeground (importance: ${appProcess.importance})")
                    return inForeground
                }
            }
        } catch (e: Exception) {
            DatabaseHelper.logToFile(applicationContext, "Error checking foreground state: ${e.message}")
        }
        return false
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return
        DatabaseHelper.logToFile(applicationContext, "onNotificationPosted triggered from: ${sbn.packageName}")

        // Skip our own notifications to avoid loops
        if (sbn.packageName == packageName) {
            DatabaseHelper.logToFile(applicationContext, "Skipped own app notification")
            return
        }

        try {
            val data = extractNotificationData(sbn)
            
            // Native TTS logic
            val packageName = data["packageName"] as? String ?: ""
            if (packageName.isNotEmpty()) {
                val shouldRead = DatabaseHelper.isReadOutLoudEnabled(applicationContext, packageName)
                DatabaseHelper.logToFile(applicationContext, "TTS Check for $packageName: shouldRead=$shouldRead, isTtsInitialized=$isTtsInitialized")
                
                if (shouldRead) {
                    val appName = data["appName"] as? String ?: ""
                    val title = data["title"] as? String ?: ""
                    val body = data["body"] as? String ?: ""
                    val ttsText = "$appName says: $title. $body"
                    
                    // Deduplication: prevent repeating the exact same text within 5 seconds
                    val now = System.currentTimeMillis()
                    val isDuplicate = ttsText == lastSpokenText && (now - lastSpokenTime) < 5000
                    
                    if (isDuplicate) {
                        DatabaseHelper.logToFile(applicationContext, "TTS Deduplication: Skipped duplicate text within 5 seconds")
                    } else {
                        // Playback Mode Check
                        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                        val playbackMode = prefs.getLong("flutter.tts_playback_mode", 0L).toInt() // 0=Anytime, 1=OnlyUnlocked, 2=OnlyLocked
                        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
                        val isLocked = keyguardManager?.isKeyguardLocked ?: false
                        
                        var allowedToPlay = false
                        when (playbackMode) {
                            0 -> allowedToPlay = true
                            1 -> allowedToPlay = !isLocked
                            2 -> allowedToPlay = isLocked
                        }
                        
                        if (!allowedToPlay) {
                            DatabaseHelper.logToFile(applicationContext, "TTS Skipped by PlaybackMode: mode=$playbackMode, isLocked=$isLocked")
                        } else {
                            lastSpokenText = ttsText
                            lastSpokenTime = now
                            
                            if (isTtsInitialized) {
                                tts?.speak(ttsText, TextToSpeech.QUEUE_ADD, null, "NotificationTTS")
                                DatabaseHelper.logToFile(applicationContext, "Played native TTS for $packageName")
                            } else {
                                pendingTtsText = ttsText
                                DatabaseHelper.logToFile(applicationContext, "Queued native TTS for $packageName because engine is not initialized yet")
                            }
                        }
                    }
                }
            }

            val callback = onNotificationPostedCallback
            val inForeground = isAppInForeground()
            
            if (callback != null && inForeground) {
                callback.invoke(data)
                DatabaseHelper.logToFile(applicationContext, "Forwarded notification to active Flutter listener")
                Log.d(TAG, "Notification captured and forwarded to Flutter: ${sbn.packageName}")
            } else {
                DatabaseHelper.logToFile(applicationContext, "App in background/closed (foreground: $inForeground, callback: ${callback != null}). Writing to DB.")
                DatabaseHelper.saveNotificationDirectly(applicationContext, data)
            }
        } catch (e: Exception) {
            DatabaseHelper.logToFile(applicationContext, "ERROR in onNotificationPosted: ${e.message}")
            Log.e(TAG, "Error processing notification: ${e.message}")
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        if (sbn == null) return
        DatabaseHelper.logToFile(applicationContext, "onNotificationRemoved triggered from: ${sbn.packageName}")
        if (sbn.packageName == packageName) return

        try {
            val data = mapOf(
                "id" to sbn.key,
                "packageName" to sbn.packageName,
                "timestamp" to sbn.postTime,
                "isDismissed" to true,
                "action" to "removed"
            )
            val callback = onNotificationRemovedCallback
            val inForeground = isAppInForeground()
            
            if (callback != null && inForeground) {
                callback.invoke(data)
                DatabaseHelper.logToFile(applicationContext, "Forwarded removal event to active Flutter listener")
            } else {
                DatabaseHelper.logToFile(applicationContext, "App in background/closed (foreground: $inForeground, callback: ${callback != null}). Dismissing in DB.")
                DatabaseHelper.dismissNotificationDirectly(applicationContext, sbn.key)
            }
        } catch (e: Exception) {
            DatabaseHelper.logToFile(applicationContext, "ERROR in onNotificationRemoved: ${e.message}")
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

        // Get app category dynamically
        val appCategoryInt = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val appInfo = packageManager.getApplicationInfo(sbn.packageName, 0)
                appInfo.category
            } catch (e: Exception) {
                -1
            }
        } else {
            -1
        }

        val appCategory = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            when (appCategoryInt) {
                ApplicationInfo.CATEGORY_GAME -> "game"
                ApplicationInfo.CATEGORY_AUDIO -> "audio"
                ApplicationInfo.CATEGORY_VIDEO -> "video"
                ApplicationInfo.CATEGORY_IMAGE -> "image"
                ApplicationInfo.CATEGORY_SOCIAL -> "social"
                ApplicationInfo.CATEGORY_NEWS -> "news"
                ApplicationInfo.CATEGORY_MAPS -> "maps"
                ApplicationInfo.CATEGORY_PRODUCTIVITY -> "productivity"
                else -> "undefined"
            }
        } else {
            "undefined"
        }

        val isMessagingStyle = extras.containsKey(Notification.EXTRA_MESSAGES) || 
                               extras.containsKey("android.messagingStyleUser") || 
                               (senderName != null && senderName.isNotEmpty())

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
            "appCategory" to appCategory,
            "isMessagingStyle" to isMessagingStyle,
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
