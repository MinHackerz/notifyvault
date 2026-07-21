# Flutter R8 / ProGuard rules
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Preserve native method names (JNI / FFI plugins)
-keepclasseswithmembernames class * {
    native <methods>;
}

# App Entry Points & Services
-keep class com.notifyvault.app.MainActivity
-keep class com.notifyvault.app.service.NotificationCaptureService

# Flutter Secure Storage
-dontwarn android.security.keystore.**

# Suppress Play Store Deferred Components warning
-dontwarn com.google.android.play.core.**

# AndroidX WorkManager / Room / Lifecycle
-dontwarn androidx.work.**
-dontwarn androidx.room.**
-dontwarn androidx.lifecycle.**

# SQLite / Drift
-dontwarn org.sqlite.**
-dontwarn sqlite3.**
-dontwarn com.sqlite3.**
