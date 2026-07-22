# Release & AAB Pre-Flight Safety Verification Rules

Before generating any Flutter Android App Bundle (`flutter build appbundle`) or APK for release/closed testing, perform the following mandatory checks:

1. **R8 / Proguard Rules Inspection**:
   - If `isMinifyEnabled = true` or `isShrinkResources = true` in `android/app/build.gradle.kts` (or `build.gradle`), ensure `proguard-rules.pro` contains explicit keep rules for:
     - JNI / FFI Native Methods: `-keepclasseswithmembernames class * { native <methods>; }`
     - Database & SQLite (Drift / sqlite3): `-keep class org.sqlite.** { *; }`, `-keep class sqlite3.** { *; }`
     - App Services / Receivers: keep custom native services declared in `AndroidManifest.xml`
     - Third-party SDKs: Firebase, FlutterSecureStorage, Google Mobile Ads, WorkManager, etc.
2. **Startup Crash Prevention in `main()`**:
   - Wrap non-critical startup SDK initializations (`Firebase.initializeApp()`, `MobileAds.initialize()`, etc.) in `try-catch` blocks so missing credentials or offline state on launch will not cause instant startup crashes.
3. **Core Library Desugaring**:
   - Verify `isCoreLibraryDesugaringEnabled = true` and `desugar_jdk_libs` dependency exist if Java 8+ / Java 17 features are consumed by packages.
4. **Code Quality Verification**:
   - Run `flutter analyze` prior to building the bundle to ensure zero static errors.
