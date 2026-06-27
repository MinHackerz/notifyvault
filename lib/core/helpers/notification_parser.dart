/// Utility for extracting structured data from notification content.
class NotificationParser {
  NotificationParser._();

  /// Extract OTP code from notification text.
  static String? extractOtp(String text) {
    // Match 4-8 digit codes that appear near OTP-related keywords
    final patterns = [
      RegExp(r'(?:otp|code|password)\s*(?:is|:)?\s*(\d{4,8})',
          caseSensitive: false),
      RegExp(r'(\d{4,8})\s*(?:is your|is the)\s*(?:otp|code)',
          caseSensitive: false),
      RegExp(r'(?:use|enter)\s*(\d{4,8})', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Extract monetary amount from notification text.
  static String? extractAmount(String text) {
    final patterns = [
      RegExp(r'(?:Rs\.?|₹|INR)\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'([\d,]+\.?\d*)\s*(?:Rs\.?|₹|INR)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        return '₹${match.group(1)}';
      }
    }

    return null;
  }

  /// Extract UPI ID from notification text.
  static String? extractUpiId(String text) {
    final pattern = RegExp(r'[\w.-]+@[\w]+', caseSensitive: false);
    final match = pattern.firstMatch(text);
    return match?.group(0);
  }

  /// Extract tracking number from notification text.
  static String? extractTrackingNumber(String text) {
    final patterns = [
      RegExp(r'tracking\s*(?:id|number|#|no\.?)\s*:?\s*([A-Z0-9]{8,25})',
          caseSensitive: false),
      RegExp(r'AWB\s*(?:no\.?|#)?\s*:?\s*([A-Z0-9]{8,25})',
          caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Extract email addresses from notification text.
  static List<String> extractEmails(String text) {
    final pattern = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );
    return pattern.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// Extract phone numbers from notification text.
  static List<String> extractPhoneNumbers(String text) {
    final pattern = RegExp(
      r'(?:\+91[\s-]?)?(?:\d[\s-]?){10}',
    );
    return pattern
        .allMatches(text)
        .map((m) => m.group(0)!.replaceAll(RegExp(r'[\s-]'), ''))
        .toList();
  }
}
