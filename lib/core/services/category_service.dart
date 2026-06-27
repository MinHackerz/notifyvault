/// Keyword-based automatic categorization engine for notifications.
///
/// Uses package name matching and content keyword analysis to assign
/// a category to each notification.
class CategoryService {
  CategoryService._();

  static final CategoryService instance = CategoryService._();

  // ─── Package Name → Category mappings ───
  static const Map<String, String> _packageCategories = {
    // Banking
    'com.sbi': 'banking',
    'com.icici': 'banking',
    'com.hdfc': 'banking',
    'com.axis': 'banking',
    'com.kotak': 'banking',
    'com.pnb': 'banking',
    'com.bob': 'banking',
    'com.canara': 'banking',
    'com.union': 'banking',
    'com.idbi': 'banking',
    'com.rbl': 'banking',
    'com.yes': 'banking',
    'com.indus': 'banking',

    // Payments / UPI
    'com.google.android.apps.nbu.paisa.user': 'payments', // GPay
    'net.one97.paytm': 'payments',
    'com.phonepe.app': 'payments',
    'in.amazon.mShop.android.shopping': 'shopping',
    'com.whatsapp': 'messages',
    'com.whatsapp.w4b': 'messages',
    'org.telegram.messenger': 'messages',
    'com.discord': 'messages',
    'com.Slack': 'work',

    // Social
    'com.instagram.android': 'social',
    'com.facebook.katana': 'social',
    'com.facebook.orca': 'social', // Messenger
    'com.twitter.android': 'social',
    'com.snapchat.android': 'social',
    'com.linkedin.android': 'social',
    'com.reddit.frontpage': 'social',
    'com.pinterest': 'social',

    // Email
    'com.google.android.gm': 'email',
    'com.microsoft.office.outlook': 'email',
    'com.yahoo.mobile.client.android.mail': 'email',

    // Shopping
    'com.flipkart.android': 'shopping',
    'com.myntra.android': 'shopping',
    'com.snapdeal.main': 'shopping',
    'club.cred': 'payments',

    // Delivery
    'in.swiggy.android': 'delivery',
    'com.application.zomato': 'delivery',
    'com.ubercab.eats': 'delivery',
    'com.dunzo.user': 'delivery',
    'com.blinkit.user': 'delivery',
    'in.zepto.user': 'delivery',
    'com.delhivery.riderApp': 'delivery',

    // Entertainment
    'com.netflix.mediaclient': 'entertainment',
    'com.spotify.music': 'entertainment',
    'com.google.android.youtube': 'entertainment',
    'in.startv.hotstar': 'entertainment',
    'com.jio.media.jiobeats': 'entertainment',

    // Government
    'nic.goi.aarogyasetu': 'government',
    'in.org.npci.upiapp': 'government',
    'com.csc.digilocker': 'government',

    // Education
    'com.byjus': 'education',
    'com.unacademy.unacademyapp': 'education',
    'com.duolingo': 'education',
  };

  // ─── Content keyword patterns ───
  static const Map<String, List<String>> _keywordCategories = {
    'otp': [
      'otp',
      'verification code',
      'verify',
      'one-time password',
      'one time password',
      'security code',
      'login code',
      'authentication code',
      '2fa',
      'two-factor',
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
      'don\'t miss',
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

  /// Categorize a notification based on package name and content.
  String categorize({
    required String packageName,
    String? title,
    String? body,
    String? bigText,
  }) {
    // 1. Try exact package match first
    for (final entry in _packageCategories.entries) {
      if (packageName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // 2. Analyze content keywords
    final content =
        '${title ?? ''} ${body ?? ''} ${bigText ?? ''}'.toLowerCase();

    if (content.isEmpty) return 'other';

    // Check OTP first (highest priority)
    if (_containsOtp(content)) return 'otp';

    // Check other categories by keyword matching
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
