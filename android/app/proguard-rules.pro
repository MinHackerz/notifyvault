# Flutter Engine & Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# App Entry Points, Native Services, Channels & Database Helpers
-keep class com.notifyvault.app.MainActivity { *; }
-keep class com.notifyvault.app.service.** { *; }
-keep class com.notifyvault.app.channel.** { *; }
-keep class com.notifyvault.app.database.** { *; }
-keep class * extends android.app.Activity { *; }
-keep class * extends android.app.Service { *; }

# Preserve native method names (JNI / FFI plugins like sqlite3)
-keepclasseswithmembernames class * {
    native <methods>;
}

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# SQLite / Drift
-keep class org.sqlite.** { *; }
-keep class sqlite3.** { *; }
-keep class com.sqlite3.** { *; }
-dontwarn org.sqlite.**
-dontwarn sqlite3.**
-dontwarn com.sqlite3.**

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

# AndroidX WorkManager / Room / Lifecycle
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keep @androidx.room.Entity class * { *; }
-keep @androidx.room.Dao interface * { *; }
-dontwarn androidx.work.**
-dontwarn androidx.room.**
-dontwarn androidx.lifecycle.**

# AndroidX Startup
-keep class androidx.startup.** { *; }
-keep class * implements androidx.startup.Initializer { *; }

# General Annotations & Enums
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

