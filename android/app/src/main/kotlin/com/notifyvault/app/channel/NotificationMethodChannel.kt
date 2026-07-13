package com.notifyvault.app.channel

import android.app.AppOpsManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import com.notifyvault.app.service.NotificationCaptureService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

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

                "launchApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        try {
                            val intent = activity.packageManager.getLaunchIntentForPackage(packageName)
                            if (intent != null) {
                                activity.startActivity(intent)
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }

                "getInstalledApps" -> {
                    Thread {
                        try {
                            val pm = activity.packageManager
                            val packages = pm.getInstalledPackages(PackageManager.GET_META_DATA)
                            val appsList = ArrayList<Map<String, Any?>>()
                            
                            val appOps = activity.getSystemService(Context.APP_OPS_SERVICE) as? android.app.AppOpsManager

                            for (pkgInfo in packages) {
                                val appInfo = pkgInfo.applicationInfo ?: continue
                                val packageName = pkgInfo.packageName ?: continue
                                
                                // Filter: skip our own package
                                if (packageName == activity.packageName) continue
                                
                                // User-facing filter: has launch intent OR not a system app
                                val isSystem = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                                val hasLaunchIntent = pm.getLaunchIntentForPackage(packageName) != null
                                
                                if (!hasLaunchIntent && isSystem) {
                                    continue
                                }
                                
                                // Check if notifications are enabled
                                val enabled = isNotificationEnabled(activity, appOps, packageName, appInfo.uid)
                                if (!enabled) {
                                    continue
                                }
                                
                                val appName = pm.getApplicationLabel(appInfo).toString()
                                val iconPath = saveAppIcon(activity, packageName)
                                
                                val appMap = mapOf(
                                    "packageName" to packageName,
                                    "appName" to appName,
                                    "iconPath" to iconPath,
                                    "isNotificationsEnabled" to true
                                )
                                appsList.add(appMap)
                            }
                            
                            mainHandler.post {
                                result.success(appsList)
                            }
                        } catch (e: Exception) {
                            Log.e("NotifyVault", "Error in getInstalledApps: ${e.message}")
                            mainHandler.post {
                                result.success(emptyList<Map<String, Any?>>())
                            }
                        }
                    }.start()
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

    private fun isNotificationEnabled(
        context: Context,
        appOps: AppOpsManager?,
        packageName: String,
        uid: Int
    ): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return context.packageManager.checkPermission(
                android.Manifest.permission.POST_NOTIFICATIONS,
                packageName
            ) == PackageManager.PERMISSION_GRANTED
        }
        
        if (appOps != null) {
            try {
                val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    appOps.unsafeCheckOpNoThrow("android:post_notification", uid, packageName)
                } else {
                    @Suppress("DEPRECATION")
                    appOps.checkOpNoThrow("android:post_notification", uid, packageName)
                }
                return mode == AppOpsManager.MODE_ALLOWED
            } catch (e: Exception) {
                // Ignore/fallback
            }
        }
        return true
    }

    private fun saveAppIcon(context: Context, packageName: String): String? {
        try {
            val iconDir = File(context.filesDir, "icons")
            if (!iconDir.exists()) {
                iconDir.mkdirs()
            }
            val iconFile = File(iconDir, "$packageName.png")

            // If already cached, just return the path
            if (iconFile.exists()) {
                return iconFile.absolutePath
            }

            val pm = context.packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            val drawable = try {
                pm.getApplicationIcon(appInfo)
            } catch (e: Exception) {
                null
            } ?: return null

            // Convert drawable to Bitmap
            val bitmap = if (drawable is android.graphics.drawable.BitmapDrawable) {
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
            Log.e("NotifyVault", "Error saving app icon for $packageName: ${e.message}")
            return null
        }
    }
}

