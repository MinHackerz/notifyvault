import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../helpers/ad_helper.dart';
import '../services/ads_service.dart';
import '../../app/theme/app_colors.dart';

/// An inline native ad styled like the app's own cards.
///
/// Takes no space until an ad has loaded, so a failed or slow request never
/// leaves an empty gap in a list.
class NativeAdCard extends StatefulWidget {
  /// [TemplateType.small] for feeds, [TemplateType.medium] for roomier pages.
  final TemplateType templateType;

  /// Outer margin; defaults to the notification tile's margin.
  final EdgeInsetsGeometry margin;

  const NativeAdCard({
    super.key,
    this.templateType = TemplateType.small,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
  });

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard>
    with AutomaticKeepAliveClientMixin {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  final _ads = AdsService.instance;

  /// Keeps a loaded ad alive while it scrolls off screen, so scrolling back
  /// doesn't trigger a new request.
  @override
  bool get wantKeepAlive => _isLoaded;

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

  void _loadAd() {
    final unitId = AdHelper.unitId(AdFormat.native);
    if (unitId == null || !_ads.canShowAds || _nativeAd != null) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;

    _nativeAd = NativeAd(
      adUnitId: unitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _isLoaded = true);
          updateKeepAlive();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('NativeAd failed to load: $error');
          ad.dispose();
          _nativeAd = null;
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
        mainBackgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        cornerRadius: 16,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: theme.colorScheme.primary,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: onSurface,
          style: NativeTemplateFontStyle.bold,
          size: 15,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: muted,
          size: 13,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: muted,
          size: 13,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ads.ready.removeListener(_onAdsStateChanged);
    _ads.adFree.removeListener(_onAdsStateChanged);
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ad = _nativeAd;
    if (!_ads.canShowAds || !_isLoaded || ad == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSmall = widget.templateType == TemplateType.small;

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(
              'SPONSORED',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isSmall ? 90 : 320,
              maxHeight: isSmall ? 120 : 360,
            ),
            child: AdWidget(ad: ad),
          ),
        ],
      ),
    );
  }
}
