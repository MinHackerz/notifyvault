import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/ad_helper.dart';

/// Owns consent, SDK start-up, the ad-free reward window and the full-screen
/// formats (interstitial + rewarded), with pacing rules so ads stay unobtrusive.
class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();

  static const _keyAdFreeUntil = 'ads_ad_free_until';

  /// How long a watched rewarded ad keeps the app ad-free.
  static const adFreeDuration = Duration(hours: 24);

  // ─── Interstitial pacing ───
  /// No interstitial during the first minutes of a session.
  static const _interstitialGracePeriod = Duration(minutes: 2);

  /// Minimum gap between two interstitials.
  static const _interstitialCooldown = Duration(minutes: 4);

  /// Closed detail screens needed before an interstitial is considered.
  static const _screensPerInterstitial = 4;

  // ─── App open pacing ───
  /// The app must have been in the background at least this long.
  static const _appOpenMinBackground = Duration(minutes: 2);

  /// Minimum gap between two app open ads.
  static const _appOpenCooldown = Duration(hours: 4);

  /// App open ads expire after four hours on AdMob's side.
  static const _appOpenMaxAge = Duration(hours: 4);

  /// Delay after resume so an alarm dialog gets the chance to appear first.
  static const _appOpenResumeDelay = Duration(milliseconds: 1500);

  /// True once consent allows ad requests and the SDK has started.
  final ValueNotifier<bool> ready = ValueNotifier(false);

  /// True while a rewarded ad's ad-free window is active.
  final ValueNotifier<bool> adFree = ValueNotifier(false);

  /// True when the user must be offered a way to change their consent.
  final ValueNotifier<bool> privacyOptionsRequired = ValueNotifier(false);

  /// True when a rewarded ad is loaded and can be offered.
  final ValueNotifier<bool> rewardedAvailable = ValueNotifier(false);

  final DateTime _sessionStart = DateTime.now();
  DateTime? _lastInterstitialAt;
  int _closedScreens = 0;
  bool _fullScreenAdShowing = false;
  bool _started = false;

  InterstitialAd? _interstitial;
  bool _interstitialLoading = false;
  RewardedAd? _rewarded;
  bool _rewardedLoading = false;
  Timer? _adFreeTimer;

  AppOpenAd? _appOpen;
  DateTime? _appOpenLoadedAt;
  bool _appOpenLoading = false;
  DateTime? _lastAppOpenAt;
  DateTime? _backgroundedAt;
  DateTime? _lastFullScreenDismissedAt;

  /// Screens that must never be covered by a full-screen ad (alarm dialog,
  /// permission flow) register here while visible.
  int _fullScreenHolds = 0;

  /// Mounted main tab shells. Counted rather than a flag so a rebuilt shell's
  /// late dispose can't hide the new one.
  int _mainShells = 0;

  /// Call from the main tab shell's initState / dispose.
  void mainShellMounted() => _mainShells++;
  void mainShellUnmounted() {
    if (_mainShells > 0) _mainShells--;
  }

  void holdFullScreenAds() => _fullScreenHolds++;
  void releaseFullScreenAds() {
    if (_fullScreenHolds > 0) _fullScreenHolds--;
  }

  /// Whether banner/native/interstitial ads may be shown right now.
  bool get canShowAds => ready.value && !adFree.value;

  /// Gathers consent (UMP), then starts the Mobile Ads SDK. Safe to call once
  /// after `runApp`; the consent form, if required, is shown by the SDK.
  Future<void> initialize() async {
    if (_started || AdHelper.hideAds) return;
    _started = true;

    await _restoreAdFree();

    final completer = Completer<bool>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) debugPrint('Consent form error: ${error.message}');
          if (!completer.isCompleted) completer.complete(true);
        });
      },
      (error) {
        debugPrint('Consent info update failed: ${error.message}');
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    final consentChecked = await completer.future;

    // Only hold ads back when UMP answered and says consent is still missing.
    // If the check itself failed (offline, or no consent message configured
    // in AdMob yet), start anyway; Google limits serving where consent is
    // required.
    if (consentChecked && !await ConsentInformation.instance.canRequestAds()) {
      return;
    }

    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('Google Mobile Ads initialization failed: $e');
      return;
    }

    privacyOptionsRequired.value =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
            PrivacyOptionsRequirementStatus.required;
    ready.value = true;

    _loadInterstitial();
    _loadRewarded();
    _loadAppOpen();

    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.listen(_onAppState);
  }

  /// Re-opens the consent form so the user can change their choice.
  Future<void> showPrivacyOptions() async {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((error) {
      if (error != null) debugPrint('Privacy options error: ${error.message}');
      completer.complete();
    });
    await completer.future;
    // The user may have withdrawn consent.
    ready.value = await ConsentInformation.instance.canRequestAds();
  }

  // ─── Ad-free window ───

  Future<void> _restoreAdFree() async {
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_keyAdFreeUntil);
    if (until == null) return;
    _scheduleAdFreeEnd(DateTime.fromMillisecondsSinceEpoch(until));
  }

  void _scheduleAdFreeEnd(DateTime until) {
    _adFreeTimer?.cancel();
    final remaining = until.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      adFree.value = false;
      return;
    }
    adFree.value = true;
    _adFreeTimer = Timer(remaining, () => adFree.value = false);
  }

  /// When the current ad-free window ends, or null if none is active.
  Future<DateTime?> adFreeUntil() async {
    if (!adFree.value) return null;
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_keyAdFreeUntil);
    return until == null ? null : DateTime.fromMillisecondsSinceEpoch(until);
  }

  // ─── Interstitial ───

  void _loadInterstitial() {
    final unitId = AdHelper.unitId(AdFormat.interstitial);
    if (unitId == null || _interstitial != null || _interstitialLoading) return;
    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  /// Called when the user leaves a detail screen. Shows an interstitial only
  /// at that natural break, and only when every pacing rule allows it.
  void onDetailScreenClosed() {
    if (!canShowAds) return;
    _closedScreens++;

    final now = DateTime.now();
    if (now.difference(_sessionStart) < _interstitialGracePeriod) return;
    if (_closedScreens < _screensPerInterstitial) return;
    final last = _lastInterstitialAt;
    if (last != null && now.difference(last) < _interstitialCooldown) return;
    if (_fullScreenAdShowing || _fullScreenHolds > 0) return;

    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }

    _interstitial = null;
    _closedScreens = 0;
    _lastInterstitialAt = now;
    _fullScreenAdShowing = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _onFullScreenClosed();
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _onFullScreenClosed();
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
  }

  // ─── App open ───

  void _loadAppOpen() {
    final unitId = AdHelper.unitId(AdFormat.appOpen);
    if (unitId == null || _appOpen != null || _appOpenLoading) return;
    _appOpenLoading = true;
    AppOpenAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoading = false;
          _appOpen = ad;
          _appOpenLoadedAt = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _appOpenLoading = false;
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  void _onAppState(AppState state) {
    if (state == AppState.background) {
      // Full-screen ads move the app to the background too; ignore those.
      if (!_fullScreenAdShowing) _backgroundedAt = DateTime.now();
      return;
    }
    final awayFrom = _backgroundedAt;
    _backgroundedAt = null;
    if (awayFrom == null) return;
    if (DateTime.now().difference(awayFrom) < _appOpenMinBackground) return;
    Future.delayed(_appOpenResumeDelay, _maybeShowAppOpen);
  }

  /// Shows an app open ad on a warm return to the app, never on a cold
  /// start, over an alarm, during onboarding/permissions, or right after
  /// another full-screen ad.
  void _maybeShowAppOpen() {
    if (!canShowAds || _mainShells == 0 || _fullScreenHolds > 0) return;
    if (_fullScreenAdShowing) return;

    final now = DateTime.now();
    final lastDismissed = _lastFullScreenDismissedAt;
    if (lastDismissed != null &&
        now.difference(lastDismissed) < const Duration(seconds: 30)) {
      return;
    }
    final last = _lastAppOpenAt;
    if (last != null && now.difference(last) < _appOpenCooldown) return;

    final ad = _appOpen;
    final loadedAt = _appOpenLoadedAt;
    if (ad == null || loadedAt == null) {
      _loadAppOpen();
      return;
    }
    if (now.difference(loadedAt) > _appOpenMaxAge) {
      ad.dispose();
      _appOpen = null;
      _loadAppOpen();
      return;
    }

    _appOpen = null;
    _lastAppOpenAt = now;
    _fullScreenAdShowing = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _onFullScreenClosed();
        ad.dispose();
        _loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _onFullScreenClosed();
        ad.dispose();
        _loadAppOpen();
      },
    );
    ad.show();
  }

  void _onFullScreenClosed() {
    _fullScreenAdShowing = false;
    _lastFullScreenDismissedAt = DateTime.now();
  }

  // ─── Rewarded ───

  void _loadRewarded() {
    final unitId = AdHelper.unitId(AdFormat.rewarded);
    if (unitId == null || _rewarded != null || _rewardedLoading) return;
    _rewardedLoading = true;
    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedLoading = false;
          _rewarded = ad;
          rewardedAvailable.value = true;
        },
        onAdFailedToLoad: (error) {
          _rewardedLoading = false;
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  /// Shows the rewarded ad. Resolves to true if the user earned the
  /// ad-free window.
  Future<bool> showRewardedForAdFree() async {
    final ad = _rewarded;
    if (ad == null || _fullScreenAdShowing) {
      _loadRewarded();
      return false;
    }
    _rewarded = null;
    rewardedAvailable.value = false;
    _fullScreenAdShowing = true;

    final completer = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _onFullScreenClosed();
        ad.dispose();
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _onFullScreenClosed();
        ad.dispose();
        _loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    await ad.show(onUserEarnedReward: (ad, reward) async {
      earned = true;
      final until = DateTime.now().add(adFreeDuration);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyAdFreeUntil, until.millisecondsSinceEpoch);
      _scheduleAdFreeEnd(until);
    });
    return completer.future;
  }
}

/// Counts closed detail pages (pushed on top of the tab shell) and lets
/// [AdsService] decide whether this break is a good moment for an
/// interstitial. Dialogs, sheets and tab switches are ignored.
class AdNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is! PageRoute) return;
    // Defer until the pop transition has started so the ad never covers a
    // half-closed page.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => AdsService.instance.onDetailScreenClosed(),
    );
  }
}
