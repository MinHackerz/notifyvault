# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep MainActivity and all other Android Activities
-keep class com.notifyvault.app.MainActivity { *; }
-keep class * extends android.app.Activity { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# NotificationListenerService
-keep class com.notifyvault.app.service.** { *; }
-keep class com.notifyvault.app.channel.** { *; }

# SQLite / Drift
-keep class org.sqlite.** { *; }
-keep class sqlite3.** { *; }
-keep class com.sqlite3.** { *; }
-dontwarn org.sqlite.**
-dontwarn sqlite3.**
-dontwarn com.sqlite3.**

# Preserve native method names and their calling classes (crucial for JNI / FFI plugins)
-keepclasseswithmembernames class * {
    native <methods>;
}

# Flutter Secure Storage
-keep class android.security.keystore.** { *; }
-dontwarn android.security.keystore.**

# Suppress Play Store Deferred Components warning
-dontwarn com.google.android.play.core.**

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-dontwarn com.google.android.gms.internal.ads.**
