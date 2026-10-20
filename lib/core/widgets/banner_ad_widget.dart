import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../helpers/ad_helper.dart';
import '../services/ads_service.dart';
import '../../app/theme/app_colors.dart';

/// Anchored adaptive banner shown above the bottom navigation bar.
///
/// Sizes itself to the screen width, takes no space until an ad has loaded,
/// and disappears while the user has an ad-free reward active.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  final _ads = AdsService.instance;

  @override
  void initState() {
    super.initState();
    _ads.ready.addListener(_onAdsStateChanged);
    _ads.adFree.addListener(_onAdsStateChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  void _onAdsStateChanged() {
    if (!mounted) return;
    if (_ads.canShowAds) {
      _loadAd();
    } else {
      setState(() {});
    }
  }

  Future<void> _loadAd() async {
    final unitId = AdHelper.unitId(AdFormat.banner);
    if (unitId == null || !_ads.canShowAds || _bannerAd != null || _isLoading) {
      return;
    }
    _isLoading = true;

    final width = MediaQuery.sizeOf(context).width.truncate();
    // The standard anchored size (~50-60dp) on purpose: the "large" variant
    // that replaces it is far taller and crowds the bottom navigation.
    // ignore: deprecated_member_use
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (!mounted || size == null) {
      _isLoading = false;
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: unitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoading = false;
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          _bannerAd = null;
          _isLoading = false;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ads.ready.removeListener(_onAdsStateChanged);
    _ads.adFree.removeListener(_onAdsStateChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ad = _bannerAd;

    if (!_ads.canShowAds || !_isLoaded || ad == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtle label showing it is an advertisement
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              'SPONSORED AD',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
          SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ],
      ),
    );
  }
}
