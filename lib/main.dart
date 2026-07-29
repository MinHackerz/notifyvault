import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app/app.dart';
import 'core/services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Google Mobile Ads SDK
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('Google Mobile Ads initialization failed: $e');
  }

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Create the alarm channel and initialize the plugin before any UI can
  // schedule, so cold starts and notification taps are handled.
  try {
    await ReminderService.instance.init();
  } catch (e) {
    debugPrint('ReminderService initialization failed: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase may fail during development if google-services.json is a placeholder.
    // The app will still work in offline/local-only mode.
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Running in offline-only mode.');
  }

  runApp(
    const ProviderScope(
      child: NotifyVaultApp(),
    ),
  );
}
