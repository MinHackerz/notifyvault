package com.notifyvault.app

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import com.notifyvault.app.channel.NotificationMethodChannel
import com.notifyvault.app.channel.ReminderAudioChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var notificationChannel: NotificationMethodChannel
    private lateinit var reminderAudioChannel: ReminderAudioChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        showWhenLockedAndTurnScreenOn()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        showWhenLockedAndTurnScreenOn()
    }

    private fun showWhenLockedAndTurnScreenOn() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        @Suppress("DEPRECATION")
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the notification platform channels
        notificationChannel = NotificationMethodChannel(flutterEngine)
        notificationChannel.setup(this)

        reminderAudioChannel = ReminderAudioChannel(flutterEngine)
        reminderAudioChannel.setup(this)
    }
}
