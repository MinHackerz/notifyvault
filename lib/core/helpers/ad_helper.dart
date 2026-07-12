import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Helper class to supply Ad Unit IDs and load full-screen ads.
class AdHelper {
  AdHelper._();

  /// Returns the appropriate Banner Ad Unit ID based on platform.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        // Official Google Android Test Banner ID
        return 'ca-app-pub-3940256099942544/6300978111';
      }
      // Production Android Banner ID
      return 'ca-app-pub-6501509019152141/6856469801';
    } else if (Platform.isIOS) {
      // Standard iOS Test Banner ID
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Returns the appropriate Rewarded Ad Unit ID based on platform.
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        // Official Google Android Test Rewarded ID
        return 'ca-app-pub-3940256099942544/5224354917';
      }
      // Production Android Rewarded ID
      return 'ca-app-pub-6501509019152141/5529457224';
    } else if (Platform.isIOS) {
      // Standard iOS Test Rewarded ID
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  /// Returns true if a rewarded ad is loaded and ready to be shown.
  static bool get isRewardedAdLoaded => _rewardedAd != null;

  /// Preload the rewarded ad so it is ready to be shown.
  static void preloadRewardedAd() {
    if (_rewardedAd != null || _isLoading) return;
    _isLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          debugPrint('RewardedAd successfully loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// Show the preloaded rewarded ad. If not loaded, calls [onAdClosed] immediately.
  static void showRewardedAd({
    required VoidCallback onAdClosed,
    required VoidCallback onRewardEarned,
  }) {
    if (_rewardedAd == null) {
      debugPrint('Rewarded ad is not loaded yet. Preloading next one.');
      preloadRewardedAd();
      onAdClosed();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        preloadRewardedAd(); // Load the next one
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        preloadRewardedAd();
        onAdClosed();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewardEarned();
      },
    );
  }
}
