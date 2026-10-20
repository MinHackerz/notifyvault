import 'dart:io';
import 'package:flutter/foundation.dart';

/// Ad formats the app uses.
enum AdFormat { banner, native, interstitial, rewarded, appOpen }

/// Supplies AdMob ad unit IDs per format and platform.
///
/// Debug builds always use Google's official test units. A release unit left
/// empty disables that format instead of falling back to a test ID.
class AdHelper {
  AdHelper._();

  /// Master kill switch. Set to true to hide every ad in the app.
  static const bool hideAds = false;

  // ─── Production Android unit IDs (AdMob console → Apps → Ad units) ───
  static const String _androidBanner = 'ca-app-pub-6501509019152141/6856469801';
  static const String _androidNative = 'ca-app-pub-6501509019152141/8865176078';
  static const String _androidInterstitial =
      'ca-app-pub-6501509019152141/8074838587';
  static const String _androidAppOpen = 'ca-app-pub-6501509019152141/8703937707';
  static const String _androidRewarded =
      'ca-app-pub-6501509019152141/1693088057';

  // ─── Google test unit IDs ───
  static const Map<AdFormat, String> _androidTest = {
    AdFormat.banner: 'ca-app-pub-3940256099942544/9214589741',
    AdFormat.native: 'ca-app-pub-3940256099942544/2247696110',
    AdFormat.interstitial: 'ca-app-pub-3940256099942544/1033173712',
    AdFormat.rewarded: 'ca-app-pub-3940256099942544/5224354917',
    AdFormat.appOpen: 'ca-app-pub-3940256099942544/9257395921',
  };
  static const Map<AdFormat, String> _iosTest = {
    AdFormat.banner: 'ca-app-pub-3940256099942544/2435281174',
    AdFormat.native: 'ca-app-pub-3940256099942544/3986624511',
    AdFormat.interstitial: 'ca-app-pub-3940256099942544/4411468910',
    AdFormat.rewarded: 'ca-app-pub-3940256099942544/1712485313',
    AdFormat.appOpen: 'ca-app-pub-3940256099942544/5575463023',
  };

  /// Returns the unit ID for [format], or null when it isn't configured.
  static String? unitId(AdFormat format) {
    if (hideAds) return null;
    if (Platform.isAndroid) {
      if (kDebugMode) return _androidTest[format];
      final id = switch (format) {
        AdFormat.banner => _androidBanner,
        AdFormat.native => _androidNative,
        AdFormat.interstitial => _androidInterstitial,
        AdFormat.rewarded => _androidRewarded,
        AdFormat.appOpen => _androidAppOpen,
      };
      return id.isEmpty ? null : id;
    }
    if (Platform.isIOS) return _iosTest[format];
    return null;
  }
}
