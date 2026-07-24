import 'dart:ui';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';

enum TransactionType { debit, credit }

class FinancialTransaction {
  final String id;
  final String packageName;
  final String appName;
  final String? iconPath;
  final double amount;
  final String currencySymbol;
  final TransactionType type;
  final String merchant;
  final String? accountInfo;
  final DateTime timestamp;
  final String rawTitle;
  final String rawBody;

  const FinancialTransaction({
    required this.id,
    required this.packageName,
    required this.appName,
    this.iconPath,
    required this.amount,
    required this.currencySymbol,
    required this.type,
    required this.merchant,
    this.accountInfo,
    required this.timestamp,
    required this.rawTitle,
    required this.rawBody,
  });
}

class FinancialParser {
  FinancialParser._();

  static const String _currencyRegexPattern =
      r'(?:₹|rs\.?|inr|\$|usd|€|eur|£|gbp|¥|jpy|cny|rmb|₩|krw|₱|php|₫|vnd|฿|thb|₺|try|r\$|brl|zł|pln|kč|czk|ft|huf|rp|idr|rm|myr|aed|sar|qar|kwd|bhd|omr|jod|egp|aud|cad|nzd|chf|sek|nok|dkk|zar|ngn|kes|ghs|uah|rub|ils|pkr|bdt|lkr|npr)';

  /// Broad negative exclusion patterns covering 10 non-transactional domains.
  static final List<RegExp> _negativePatterns = [
    // 1. Corporate News, Stock Market & Financial Reports
    RegExp(
      r'\b(?:capital expenditure|capex|guidance|revenue|eps|quarter|q[1-4]|fy\d{2}|earnings|stock|stocks|shares|equity|nifty|sensex|nasdaq|dow|sp500|invests|investment|investor|valuation|lawsuit|securities|dividend|ipo|mutual fund|nav|asset|portfolio)\b',
      caseSensitive: false,
    ),
    RegExp(r'\b(?:billion|trillion|crore|lakh)\b', caseSensitive: false),

    // 2. Promotions, Offers, Discounts, Coupons & Rewards
    RegExp(
      r'\b(?:off|discount|discounts|coupon|coupons|voucher|vouchers|use code|promo|promocode|deal|deals|sale|flat|upto|up to|save|saving|savings|extra|bonus|cashback offer|points|reward|rewards|win|winner|chance|luck|spin|jackpot|free|gift|special offer|limited period|hurry|dont miss|unbeatable)\b',
      caseSensitive: false,
    ),
    RegExp(r'\b(?:earn|earning|claim)\b', caseSensitive: false),

    // 3. Product Catalogs & Price Advertisements
    RegExp(
      r'(?:from\s+(?:₹|\$|rs|inr)|@\s*(?:₹|\$|rs|inr)|starting\s+at|starting\s+from|\bmrp\b|\bworth\b|\bbuy\s+1\b|\bbuy\s+get\b|\bshop\s+now\b|\border\s+now\b|\bbrowse\b|\bcollection\b|\btrending\b|\bbestseller\b|\bpre-order\b|\blaunch\b)',
      caseSensitive: false,
    ),

    // 4. Loans, Credit Cards, Pre-qualifications & Financial Ads
    RegExp(
      r'\b(?:pre-approved|pre approved|pre-qualified|pre qualified|loan|loans|apply now|eligible|eligibility|credit card offer|instant loan|personal loan|home loan|car loan|emi starts|interest rate|zero interest|no cost emi)\b',
      caseSensitive: false,
    ),

    // 5. Telecom, Recharges & Subscriptions
    RegExp(
      r'\b(?:recharge|plan|pack|validity|data|unlimited|per day|gb/day|expired|expires|expiring|renew|renewal|top-up|talktime|subscriber)\b',
      caseSensitive: false,
    ),

    // 6. Bills, Reminders, Requests & Pre-authorizations
    RegExp(
      r'\b(?:due|due date|due on|overdue|bill generated|reminder|bill due|will be charged|upcoming|requesting|requested|collect request|mandate|autopay scheduled|paylater)\b',
      caseSensitive: false,
    ),

    // 7. OTP & Security Passcodes
    RegExp(
      r'\b(?:otp|verification|verify|code|secret|one time|one-time|password|passcode|do not share|dont share|auth|authentication|2fa|mfa|login|sign in)\b',
      caseSensitive: false,
    ),

    // 8. Failed & Declined Transactions
    RegExp(
      r'\b(?:failed|declined|unsuccessful|cancelled|canceled|reversed|reversal|attempted|could not process|invalid|rejected|denied)\b',
      caseSensitive: false,
    ),

    // 9. Gaming, Betting & Fantasy Apps
    RegExp(
      r'\b(?:dream11|mpl|rummy|poker|casino|bet|betting|fantasy|coins|tokens|diamonds|gems|level|score|tournament)\b',
      caseSensitive: false,
    ),

    // 10. Logistics & General Status Updates
    RegExp(
      r'\b(?:out for delivery|dispatched|shipped|arriving today|arriving by|track your order)\b',
      caseSensitive: false,
    ),
  ];

  /// Parse a notification and return a [FinancialTransaction] if valid financial transaction found.
  static FinancialTransaction? parse(NotificationModel notification) {
    final text = '${notification.title ?? ''} ${notification.displayText}'.trim();
    if (text.isEmpty) return null;

    final lowerText = text.toLowerCase();

    // Stage 1: Broad Negative Exclusions Check
    for (final pattern in _negativePatterns) {
      if (pattern.hasMatch(lowerText)) {
        return null;
      }
    }

    // Stage 2: Extract Amount & Currency
    final result = _extractAmountAndCurrency(text);
    if (result == null || result.amount <= 0) return null;

    // Stage 3: Strict Positive Structural Type Determination
    final type = _determineType(lowerText);
    if (type == null) return null;

    // Stage 4: Extract Merchant / Counterparty
    final merchant = _extractMerchant(text, notification.appName);

    // Stage 5: Extract Account/Bank Suffix
    final accountInfo = _extractAccountInfo(text);

    return FinancialTransaction(
      id: notification.id,
      packageName: notification.packageName,
      appName: notification.appName,
      iconPath: notification.iconPath,
      amount: result.amount,
      currencySymbol: result.currencySymbol,
      type: type,
      merchant: merchant,
      accountInfo: accountInfo,
      timestamp: notification.timestamp,
      rawTitle: notification.title ?? '',
      rawBody: notification.displayText,
    );
  }

  static _ParsedAmount? _extractAmountAndCurrency(String text) {
    // 1. Symbol/code preceding amount (e.g. ₹500, $45.99, EUR 50, AED 100)
    final leadingPattern = RegExp(
      '($_currencyRegexPattern)\\s*([\\d,]+(?:\\.\\d{1,2})?)',
      caseSensitive: false,
    );
    var match = leadingPattern.firstMatch(text);
    if (match != null) {
      final symbolRaw = match.group(1);
      final rawStr = match.group(2)?.replaceAll(',', '');
      if (rawStr != null) {
        final val = double.tryParse(rawStr);
        if (val != null && val > 0 && val < 10000000) {
          return _ParsedAmount(val, _normalizeCurrency(symbolRaw));
        }
      }
    }

    // 2. Symbol/code following amount (e.g. 500.00 INR, 45 USD, 100 AED)
    final trailingPattern = RegExp(
      '([\\d,]+(?:\\.\\d{1,2})?)\\s*($_currencyRegexPattern)',
      caseSensitive: false,
    );
    match = trailingPattern.firstMatch(text);
    if (match != null) {
      final rawStr = match.group(1)?.replaceAll(',', '');
      final symbolRaw = match.group(2);
      if (rawStr != null) {
        final val = double.tryParse(rawStr);
        if (val != null && val > 0 && val < 10000000) {
          return _ParsedAmount(val, _normalizeCurrency(symbolRaw));
        }
      }
    }

    // 3. Keyword pattern (e.g. spent 500, paid 1200)
    final keywordPattern = RegExp(
      '(?:spent|paid|credited|debited|sent|received|amount of)\\s+(?:($_currencyRegexPattern)\\s*)?([\\d,]+(?:\\.\\d{1,2})?)',
      caseSensitive: false,
    );
    match = keywordPattern.firstMatch(text);
    if (match != null) {
      final symbolRaw = match.group(1);
      final rawStr = match.group(2)?.replaceAll(',', '');
      if (rawStr != null) {
        final val = double.tryParse(rawStr);
        if (val != null && val > 0 && val < 10000000) {
          return _ParsedAmount(val, _normalizeCurrency(symbolRaw));
        }
      }
    }

    return null;
  }

  static String _normalizeCurrency(String? raw) {
    if (raw == null) return _defaultSystemCurrency();
    final lower = raw.trim().toLowerCase();

    // Map common currency representations to standard display symbols
    if (lower == '₹' || lower.startsWith('rs') || lower == 'inr') return '₹';
    if (lower == '\$' || lower == 'usd') return '\$';
    if (lower == '€' || lower == 'eur') return '€';
    if (lower == '£' || lower == 'gbp') return '£';
    if (lower == '¥' || lower == 'jpy' || lower == 'cny' || lower == 'rmb') return '¥';
    if (lower == '₩' || lower == 'krw') return '₩';
    if (lower == '₱' || lower == 'php') return '₱';
    if (lower == '₫' || lower == 'vnd') return '₫';
    if (lower == '฿' || lower == 'thb') return '฿';
    if (lower == '₺' || lower == 'try') return '₺';
    if (lower == 'r\$' || lower == 'brl') return 'R\$';
    if (lower == 'zł' || lower == 'pln') return 'zł';
    if (lower == 'kč' || lower == 'czk') return 'Kč';
    if (lower == 'ft' || lower == 'huf') return 'Ft';
    if (lower == 'rp' || lower == 'idr') return 'Rp';
    if (lower == 'rm' || lower == 'myr') return 'RM';

    // Standard 3-letter ISO code capitalized
    if (raw.length == 3) {
      return raw.toUpperCase();
    }

    return raw;
  }

  static String get defaultSystemCurrency => _defaultSystemCurrency();

  static String _defaultSystemCurrency() {
    try {
      final locale = PlatformDispatcher.instance.locale;
      final countryCode = locale.countryCode?.toUpperCase();

      if (countryCode != null) {
        switch (countryCode) {
          case 'IN':
            return '₹';
          case 'US':
            return '\$';
          case 'GB':
            return '£';
          case 'DE':
          case 'FR':
          case 'IT':
          case 'ES':
          case 'NL':
          case 'BE':
          case 'AT':
          case 'PT':
          case 'IE':
          case 'FI':
          case 'GR':
          case 'LU':
          case 'SK':
          case 'SI':
          case 'EE':
          case 'LV':
          case 'LT':
          case 'CY':
          case 'MT':
            return '€';
          case 'AE':
            return 'AED';
          case 'SA':
            return 'SAR';
          case 'QA':
            return 'QAR';
          case 'KW':
            return 'KWD';
          case 'BH':
            return 'BHD';
          case 'OM':
            return 'OMR';
          case 'JO':
            return 'JOD';
          case 'EG':
            return 'EGP';
          case 'CA':
            return 'CAD';
          case 'AU':
            return 'AUD';
          case 'NZ':
            return 'NZD';
          case 'CH':
            return 'CHF';
          case 'JP':
          case 'CN':
            return '¥';
          case 'KR':
            return '₩';
          case 'SG':
            return 'SGD';
          case 'HK':
            return 'HKD';
          case 'MY':
            return 'RM';
          case 'ID':
            return 'Rp';
          case 'TH':
            return '฿';
          case 'PH':
            return '₱';
          case 'VN':
            return '₫';
          case 'TR':
            return '₺';
          case 'BR':
            return 'R\$';
          case 'PL':
            return 'zł';
          case 'CZ':
            return 'Kč';
          case 'HU':
            return 'Ft';
          case 'ZA':
            return 'ZAR';
          case 'NG':
            return 'NGN';
          case 'KE':
            return 'KES';
          case 'PK':
            return 'PKR';
          case 'BD':
            return 'BDT';
          case 'LK':
            return 'LKR';
          case 'NP':
            return 'NPR';
        }
      }

      final symbol = NumberFormat.simpleCurrency(locale: locale.toString()).currencySymbol;
      if (symbol.isNotEmpty) return symbol;
    } catch (_) {}

    return '₹';
  }

  static TransactionType? _determineType(String lowerText) {
    // Explicit credit verbs/patterns
    final creditPatterns = [
      RegExp(r'\bcredited\b'),
      RegExp(r'\breceived\b'),
      RegExp(r'\badded\s+to\b'),
      RegExp(r'\brefund\b'),
      RegExp(r'\bdeposited\b'),
    ];

    for (final pattern in creditPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return TransactionType.credit;
      }
    }

    // Explicit debit verbs/patterns
    final debitPatterns = [
      RegExp(r'\bdebited\b'),
      RegExp(r'\bspent\b'),
      RegExp(r'\bpaid\b'),
      RegExp(r'\bsent\b'),
      RegExp(r'\bwithdrawn\b'),
      RegExp(r'\bcharged\b'),
      RegExp(r'\btransferred\b'),
      RegExp(r'\bpayment\b'),
      RegExp(r'\bpurchase\b'),
    ];

    for (final pattern in debitPatterns) {
      if (pattern.hasMatch(lowerText)) {
        return TransactionType.debit;
      }
    }

    // If neither explicit credit nor debit pattern matched, it's NOT a valid transaction
    return null;
  }

  static String _extractMerchant(String text, String appName) {
    final lowerText = text.toLowerCase();

    // Standardized merchant mapping
    final merchantMap = <String, String>{
      'swiggy': 'Swiggy',
      'zomato': 'Zomato',
      'amazon': 'Amazon',
      'amzn': 'Amazon',
      'flipkart': 'Flipkart',
      'myntra': 'Myntra',
      'uber': 'Uber',
      'ola': 'Ola',
      'rapido': 'Rapido',
      'blinkit': 'Blinkit',
      'zepto': 'Zepto',
      'dunzo': 'Dunzo',
      'netflix': 'Netflix',
      'spotify': 'Spotify',
      'apple': 'Apple',
      'itunes': 'Apple',
      'google': 'Google',
      'steam': 'Steam',
      'playstation': 'PlayStation',
      'xbox': 'Xbox',
      'paytm': 'Paytm',
      'phonepe': 'PhonePe',
      'gpay': 'Google Pay',
      'bookmyshow': 'BookMyShow',
      'jiomart': 'JioMart',
      'bigbasket': 'BigBasket',
      'makemytrip': 'MakeMyTrip',
      'cleartrip': 'ClearTrip',
      'irctc': 'IRCTC',
      'starbucks': 'Starbucks',
      'mcdonald': 'McDonald\'s',
      'walmart': 'Walmart',
      'target': 'Target',
      'doorDash': 'DoorDash',
      'instacart': 'Instacart',
      'grubhub': 'Grubhub',
    };

    for (final entry in merchantMap.entries) {
      if (lowerText.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Try "at <Merchant>", "to <Merchant>", "vpa <Merchant>"
    final atMatch = RegExp(r'(?:at|to|vpa|paid to|sent to|at)\s+([A-Za-z0-9\s\.]{2,20})', caseSensitive: false).firstMatch(text);
    if (atMatch != null) {
      final candidate = atMatch.group(1)?.trim();
      if (candidate != null && candidate.isNotEmpty && candidate.length > 2) {
        final firstWord = candidate.split(' ').first;
        if (!_isCommonWord(firstWord)) {
          return firstWord[0].toUpperCase() + firstWord.substring(1);
        }
      }
    }

    return appName;
  }

  static bool _isCommonWord(String word) {
    final w = word.toLowerCase();
    return ['your', 'account', 'a/c', 'bank', 'the', 'rs', 'inr', 'usd', 'payment', 'successful', 'failed', 'via', 'using', 'from', 'with'].contains(w);
  }

  static String? _extractAccountInfo(String text) {
    // Account suffix e.g., A/C XX4920, HDFC Bank, SBI
    final acMatch = RegExp(r'(?:a/c|account|card)\s*(?:no\.?|ending)?\s*([x\*]*\d{3,4})', caseSensitive: false).firstMatch(text);
    if (acMatch != null) {
      return 'A/C ${acMatch.group(1)}';
    }

    final bankNames = ['HDFC', 'SBI', 'ICICI', 'Axis', 'Kotak', 'PNB', 'BOB', 'IDFC', 'IndusInd', 'Paytm Bank', 'Jupiter', 'Fi Bank', 'Chase', 'Wells Fargo', 'BoA', 'Citi'];
    for (final b in bankNames) {
      if (text.toLowerCase().contains(b.toLowerCase())) {
        return '$b Bank';
      }
    }
    return null;
  }
}

class _ParsedAmount {
  final double amount;
  final String currencySymbol;

  const _ParsedAmount(this.amount, this.currencySymbol);
}
