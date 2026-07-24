import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/helpers/financial_parser.dart';
import 'notification_providers.dart';
import 'statistics_providers.dart';

class FinancialSummary {
  final double totalSpent;
  final double totalReceived;
  final double netBalance;
  final String currencySymbol;
  final int transactionCount;
  final List<FinancialTransaction> transactions;
  final Map<String, double> spendByMerchant;

  const FinancialSummary({
    required this.totalSpent,
    required this.totalReceived,
    required this.netBalance,
    required this.currencySymbol,
    required this.transactionCount,
    required this.transactions,
    required this.spendByMerchant,
  });
}

/// Provider for parsed financial transactions based on notifications.
final financialTransactionsProvider = Provider<AsyncValue<List<FinancialTransaction>>>((ref) {
  final notificationsAsync = ref.watch(notificationStreamProvider);
  final days = ref.watch(statsTimeRangeProvider);
  final since = DateTime.now().subtract(Duration(days: days));

  return notificationsAsync.whenData((notifications) {
    final transactions = <FinancialTransaction>[];

    for (final notification in notifications) {
      if (notification.timestamp.isBefore(since)) continue;

      // Check category or content indicators
      final isFinancialCategory = notification.category == 'banking' ||
          notification.category == 'payments' ||
          notification.category == 'shopping';

      final content = '${notification.title ?? ''} ${notification.displayText}'.toLowerCase();

      final hasCurrencyIndicator = content.contains('₹') ||
          content.contains('rs') ||
          content.contains('inr') ||
          content.contains('\$') ||
          content.contains('usd') ||
          content.contains('€') ||
          content.contains('eur') ||
          content.contains('£') ||
          content.contains('gbp') ||
          content.contains('credited') ||
          content.contains('debited') ||
          content.contains('spent') ||
          content.contains('paid');

      if (isFinancialCategory || hasCurrencyIndicator) {
        final tx = FinancialParser.parse(notification);
        if (tx != null) {
          transactions.add(tx);
        }
      }
    }

    // Sort newest first
    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return transactions;
  });
});

/// Financial summary calculations.
final financialSummaryProvider = Provider<AsyncValue<FinancialSummary>>((ref) {
  final txAsync = ref.watch(financialTransactionsProvider);

  return txAsync.whenData((transactions) {
    double totalSpent = 0.0;
    double totalReceived = 0.0;
    final spendByMerchant = <String, double>{};
    final currencyCounts = <String, int>{};

    for (final tx in transactions) {
      currencyCounts[tx.currencySymbol] = (currencyCounts[tx.currencySymbol] ?? 0) + 1;
      if (tx.type == TransactionType.debit) {
        totalSpent += tx.amount;
        spendByMerchant[tx.merchant] = (spendByMerchant[tx.merchant] ?? 0.0) + tx.amount;
      } else {
        totalReceived += tx.amount;
      }
    }

    // Determine dominant currency symbol from received notifications, or fall back to system country currency
    String dominantCurrency = FinancialParser.defaultSystemCurrency;
    int maxCount = 0;
    for (final entry in currencyCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        dominantCurrency = entry.key;
      }
    }

    return FinancialSummary(
      totalSpent: totalSpent,
      totalReceived: totalReceived,
      netBalance: totalReceived - totalSpent,
      currencySymbol: dominantCurrency,
      transactionCount: transactions.length,
      transactions: transactions,
      spendByMerchant: spendByMerchant,
    );
  });
});
