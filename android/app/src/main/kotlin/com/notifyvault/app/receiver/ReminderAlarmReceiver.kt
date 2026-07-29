package com.notifyvault.app.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Vibrator
import android.util.Log
import com.notifyvault.app.MainActivity

class ReminderAlarmReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "ReminderAlarmReceiver"
        var activeMediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("reminder_title") ?: "Reminder Alert"
        val body = intent.getStringExtra("reminder_body") ?: ""
        val reminderId = intent.getIntExtra("reminder_id", 0)

        Log.d(TAG, "Native Alarm Triggered for #$reminderId: $title")

        // 1. Play native system alarm sound out loud on STREAM_ALARM
        try {
            activeMediaPlayer?.stop()
            activeMediaPlayer?.release()

            val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

            val mediaPlayer = MediaPlayer().apply {
                setDataSource(context, alarmUri)
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                isLooping = false
                prepare()
                start()
            }
            activeMediaPlayer = mediaPlayer
        } catch (e: Exception) {
            Log.e(TAG, "Error playing alarm sound: ${e.message}")
        }

        // 2. Vibrate phone
        try {
            val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator?.vibrate(
                    android.os.VibrationEffect.createWaveform(
                        longArrayOf(0, 1000, 500, 1000), -1
                    )
                )
            } else {
                @Suppress("DEPRECATION")
                vibrator?.vibrate(longArrayOf(0, 1000, 500, 1000), -1)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Vibration failed: ${e.message}")
        }

        // 3. Launch MainActivity over lockscreen & closed app state
        try {
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra("triggered_reminder_id", reminderId)
                putExtra("triggered_reminder_title", title)
            }
            context.startActivity(launchIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch activity: ${e.message}")
        }
    }
}
