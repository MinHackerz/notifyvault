package com.notifyvault.app

import com.notifyvault.app.channel.NotificationMethodChannel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var notificationChannel: NotificationMethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the notification platform channels
        notificationChannel = NotificationMethodChannel(flutterEngine)
        notificationChannel.setup(this)
    }
}
