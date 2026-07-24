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

  /// Parse a notification and return a [FinancialTransaction] if valid financial transaction found.
  static FinancialTransaction? parse(NotificationModel notification) {
    final text = '${notification.title ?? ''} ${notification.displayText}'.trim();
    if (text.isEmpty) return null;

    final lowerText = text.toLowerCase();

    // Check financial indicators
    final hasFinancialKeywords = lowerText.contains('credited') ||
        lowerText.contains('debited') ||
        lowerText.contains('spent') ||
        lowerText.contains('paid') ||
        lowerText.contains('sent to') ||
        lowerText.contains('received from') ||
        lowerText.contains('withdrawn') ||
        lowerText.contains('deposited') ||
        lowerText.contains('transaction') ||
        lowerText.contains('payment');

    final hasCurrencySymbol = RegExp(_currencyRegexPattern, caseSensitive: false).hasMatch(lowerText);

    if (!hasFinancialKeywords && !hasCurrencySymbol) return null;

    // Extract amount and currency symbol
    final result = _extractAmountAndCurrency(text);
    if (result == null || result.amount <= 0) return null;

    // Determine type: debit vs credit
    final type = _determineType(lowerText);

    // Extract merchant or counterparty
    final merchant = _extractMerchant(text, notification.appName);

    // Extract account/bank suffix
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

  static TransactionType _determineType(String lowerText) {
    final creditKeywords = [
      'credited',
      'received',
      'added to',
      'refund',
      'cashback',
      'deposit',
      'got',
      'received from',
    ];

    for (final kw in creditKeywords) {
      if (lowerText.contains(kw)) {
        return TransactionType.credit;
      }
    }
    return TransactionType.debit;
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
