import 'dart:io';

/// Helper class to supply Ad Unit IDs.
class AdHelper {
  AdHelper._();

  /// Returns the appropriate Banner Ad Unit ID based on platform.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Standard Android Test Banner ID
      return 'ca-app-pub-6501509019152141/6856469801';
    } else if (Platform.isIOS) {
      // Standard iOS Test Banner ID
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }
}
