package com.notifyvault.app.channel

import android.content.Context
import android.media.RingtoneManager
import android.net.Uri
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Resolves a *playable* alert tone for the reminder alarm channel.
 *
 * Dart cannot verify that a `content://` sound actually resolves on the current
 * ROM, and an unresolvable channel sound does not fall back to a default —
 * NotificationManager simply posts the notification silently. Vivo/Funtouch,
 * Xiaomi/MIUI and some Samsung builds are the usual offenders, either omitting
 * the `alarm_alert` Settings key or leaving it unset. So the choice is made
 * natively, where the URI can be opened and tested before it is committed to a
 * notification channel.
 */
class ReminderAudioChannel(private val flutterEngine: FlutterEngine) {

    companion object {
        private const val METHOD_CHANNEL = "com.notifyvault.app/reminder_audio"
        private const val TAG = "ReminderAudioChannel"
    }

    fun setup(context: Context) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "resolveAlertTone" -> result.success(resolveAlertTone(context))
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Returns `{"uri": String, "type": "alarm"|"notification"}`, or an empty map
     * when nothing playable exists so Dart can fall back to the system default.
     *
     * The `type` matters as much as the URI: routing a notification-stream tone
     * through `AudioAttributesUsage.ALARM` is another way to end up inaudible, so
     * Dart pairs the usage to whichever tone was actually found.
     */
    private fun resolveAlertTone(context: Context): Map<String, String> {
        // Settings.System.DEFAULT_ALARM_ALERT_URI is preferred over a concrete
        // file URI because it dereferences to whatever tone the user currently
        // has selected — a channel pinned to a concrete URI would freeze the
        // tone at first creation.
        val candidates = listOf(
            Settings.System.DEFAULT_ALARM_ALERT_URI to "alarm",
            RingtoneManager.getActualDefaultRingtoneUri(
                context, RingtoneManager.TYPE_ALARM
            ) to "alarm",
            Settings.System.DEFAULT_NOTIFICATION_URI to "notification",
            RingtoneManager.getActualDefaultRingtoneUri(
                context, RingtoneManager.TYPE_NOTIFICATION
            ) to "notification",
        )

        for ((uri, type) in candidates) {
            if (isPlayable(context, uri)) {
                Log.i(TAG, "Resolved $type tone: $uri")
                return mapOf("uri" to uri.toString(), "type" to type)
            }
        }

        Log.w(TAG, "No playable alert tone found; falling back to channel default")
        return emptyMap()
    }

    /** Opens the URI to prove the ROM can actually hand back audio for it. */
    private fun isPlayable(context: Context, uri: Uri?): Boolean {
        if (uri == null) return false
        return try {
            context.contentResolver.openAssetFileDescriptor(uri, "r")
                ?.use { true } ?: false
        } catch (e: Exception) {
            Log.w(TAG, "Tone not playable: $uri (${e.javaClass.simpleName})")
            false
        }
    }
}
