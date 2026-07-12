/// Keyword-based automatic categorization engine for notifications.
///
/// Uses dynamic Android app categories, native notification metadata,
/// and content keyword analysis to assign a category to each notification.
class CategoryService {
  CategoryService._();

  static final CategoryService instance = CategoryService._();

  // ─── Content keyword patterns ───
  static const Map<String, List<String>> _keywordCategories = {
    'messages': [
      'message',
      'messages',
      'chat',
      'text',
      'sms',
      'pinged',
      'sent a photo',
      'sent a video',
      'sticker',
    ],
    'banking': [
      'account',
      'balance',
      'credited',
      'debited',
      'transaction',
      'transfer',
      'neft',
      'rtgs',
      'imps',
      'bank',
      'atm',
      'withdrawal',
      'deposit',
      'statement',
      'ifsc',
    ],
    'payments': [
      'payment',
      'paid',
      'received',
      'upi',
      'rupee',
      'inr',
      '₹',
      'wallet',
      'cashback',
      'refund',
      'invoice',
    ],
    'shopping': [
      'order',
      'placed',
      'shipped',
      'dispatch',
      'cart',
      'wishlist',
      'deal',
      'offer',
      'discount',
      'coupon',
      'sale',
      'buy',
      'purchase',
    ],
    'delivery': [
      'delivered',
      'delivery',
      'out for delivery',
      'arriving',
      'tracking',
      'shipment',
      'courier',
      'parcel',
      'package',
      'eta',
    ],
    'health': [
      'appointment',
      'doctor',
      'hospital',
      'medicine',
      'prescription',
      'health',
      'medical',
      'vaccine',
      'lab report',
      'test result',
    ],
    'promotions': [
      'exclusive',
      'limited time',
      'special offer',
      'promo',
      'flash sale',
      'hurry',
      "don't miss",
      'subscribe',
      'free trial',
      'upgrade',
    ],
    'work': [
      'meeting',
      'calendar',
      'schedule',
      'deadline',
      'project',
      'task',
      'assigned',
      'jira',
      'sprint',
      'standup',
    ],
    'government': [
      'aadhaar',
      'pan card',
      'passport',
      'digilocker',
      'income tax',
      'gst',
      'government',
      'customs',
      'ministry',
    ],
    'education': [
      'class',
      'lecture',
      'exam',
      'assignment',
      'course',
      'grade',
      'study',
      'lesson',
      'quiz',
      'tutorial',
    ],
  };

  /// Categorize a notification dynamically.
  String categorize({
    required String packageName,
    String? title,
    String? body,
    String? bigText,
    String? appCategory,
    String? notificationCategory,
    bool isMessagingStyle = false,
  }) {
    final content =
        '${title ?? ''} ${body ?? ''} ${bigText ?? ''}'.toLowerCase();

    if (content.isEmpty) return 'other';

    // 1. Check OTP first (highest priority)
    if (_containsOtp(content)) return 'otp';

    // 2. Check native notification category metadata
    if (notificationCategory != null) {
      switch (notificationCategory.toLowerCase()) {
        case 'msg':
        case 'call':
          return 'messages';
        case 'email':
          return 'email';
        case 'promo':
        case 'recommendation':
          return 'promotions';
        case 'social':
          return isMessagingStyle ? 'messages' : 'social';
        case 'transport':
          return 'delivery';
        case 'event':
        case 'reminder':
          return 'work';
      }
    }

    // 3. Check Android system app category
    if (appCategory != null) {
      switch (appCategory.toLowerCase()) {
        case 'game':
        case 'audio':
        case 'video':
          return 'entertainment';
        case 'social':
          return isMessagingStyle ? 'messages' : 'social';
        case 'productivity':
          return 'work';
        case 'maps':
          return 'delivery';
      }
    }

    // 4. Check other categories by keyword matching
    int bestScore = 0;
    String bestCategory = 'other';

    for (final entry in _keywordCategories.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        if (content.contains(keyword)) {
          score++;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestCategory = entry.key;
      }
    }

    return bestCategory;
  }

  /// Dedicated OTP detection with regex patterns.
  bool _containsOtp(String content) {
    // Check for common OTP patterns
    final otpPatterns = [
      RegExp(r'\b\d{4,8}\b.*(?:otp|code|verify)', caseSensitive: false),
      RegExp(r'(?:otp|code|verify).*\b\d{4,8}\b', caseSensitive: false),
      RegExp(r'one.?time.?password', caseSensitive: false),
      RegExp(r'verification\s*code', caseSensitive: false),
      RegExp(r'security\s*code', caseSensitive: false),
      RegExp(r'your\s+\w*\s*code\s+is', caseSensitive: false),
    ];

    return otpPatterns.any((pattern) => pattern.hasMatch(content));
  }
}
