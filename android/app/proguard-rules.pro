# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# NotificationListenerService
-keep class com.notifyvault.app.service.** { *; }
-keep class com.notifyvault.app.channel.** { *; }

# SQLite / Drift
-keep class org.sqlite.** { *; }
-keep class sqlite3.** { *; }

# Suppress Play Store Deferred Components warning
-dontwarn com.google.android.play.core.**
