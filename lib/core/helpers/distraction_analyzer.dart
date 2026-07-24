import '../../models/notification_model.dart';
import 'package:flutter/material.dart';

class DistractionMetrics {
  final int score; // 0 to 100
  final String statusLabel; // Low, Moderate, High, Severe
  final Color statusColor;
  final List<int> hourlyCounts; // Array of 24 ints (hours 0-23)
  final int peakHour;
  final int peakCount;
  final List<NoiseAppEntry> highNoiseApps;

  const DistractionMetrics({
    required this.score,
    required this.statusLabel,
    required this.statusColor,
    required this.hourlyCounts,
    required this.peakHour,
    required this.peakCount,
    required this.highNoiseApps,
  });
}

class NoiseAppEntry {
  final String packageName;
  final String appName;
  final String? iconPath;
  final int count;
  final double percentageOfTotal;

  const NoiseAppEntry({
    required this.packageName,
    required this.appName,
    this.iconPath,
    required this.count,
    required this.percentageOfTotal,
  });
}

class DistractionAnalyzer {
  DistractionAnalyzer._();

  static DistractionMetrics analyze({
    required List<NotificationModel> notifications,
    required int days,
    required Map<String, String> appNameMap,
    required Map<String, String?> appIconMap,
  }) {
    if (notifications.isEmpty) {
      return const DistractionMetrics(
        score: 0,
        statusLabel: 'Low',
        statusColor: Color(0xFF10B981),
        hourlyCounts: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        peakHour: 12,
        peakCount: 0,
        highNoiseApps: [],
      );
    }

    final totalCount = notifications.length;
    final effectiveDays = days > 0 ? days : 1;
    final avgDailyCount = totalCount / effectiveDays;

    // 1. Hourly distribution (0..23)
    final hourlyCounts = List<int>.filled(24, 0);
    final appCounts = <String, int>{};

    for (final n in notifications) {
      final hour = n.timestamp.hour;
      hourlyCounts[hour]++;
      appCounts[n.packageName] = (appCounts[n.packageName] ?? 0) + 1;
    }

    // Peak hour
    int peakHour = 0;
    int peakCount = 0;
    for (int h = 0; h < 24; h++) {
      if (hourlyCounts[h] > peakCount) {
        peakCount = hourlyCounts[h];
        peakHour = h;
      }
    }

    // 2. High noise apps
    final sortedAppEntries = appCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highNoiseApps = <NoiseAppEntry>[];
    for (final entry in sortedAppEntries.take(5)) {
      final percentage = totalCount > 0 ? (entry.value / totalCount) * 100 : 0.0;
      highNoiseApps.add(NoiseAppEntry(
        packageName: entry.key,
        appName: appNameMap[entry.key] ?? _extractAppName(entry.key),
        iconPath: appIconMap[entry.key],
        count: entry.value,
        percentageOfTotal: percentage,
      ));
    }

    // 3. Score calculation (0 to 100)
    // Factors: Average daily volume + peak hour intensity
    int score = 0;
    if (avgDailyCount < 15) {
      score = (avgDailyCount * 2).round();
    } else if (avgDailyCount < 40) {
      score = 30 + ((avgDailyCount - 15) * 1.2).round();
    } else if (avgDailyCount < 80) {
      score = 60 + ((avgDailyCount - 40) * 0.75).round();
    } else {
      score = 90 + ((avgDailyCount - 80) * 0.25).round();
    }

    if (score > 100) score = 100;
    if (score < 0) score = 0;

    String statusLabel = 'Low';
    Color statusColor = const Color(0xFF10B981); // Success Green

    if (score >= 75) {
      statusLabel = 'Severe';
      statusColor = const Color(0xFFEF4444); // Error Red
    } else if (score >= 50) {
      statusLabel = 'High';
      statusColor = const Color(0xFFF97316); // Orange Warning
    } else if (score >= 25) {
      statusLabel = 'Moderate';
      statusColor = const Color(0xFFF59E0B); // Yellow
    }

    return DistractionMetrics(
      score: score,
      statusLabel: statusLabel,
      statusColor: statusColor,
      hourlyCounts: hourlyCounts,
      peakHour: peakHour,
      peakCount: peakCount,
      highNoiseApps: highNoiseApps,
    );
  }

  static String _extractAppName(String packageName) {
    final parts = packageName.split('.');
    if (parts.length >= 2) {
      final name = parts.last;
      return name[0].toUpperCase() + name.substring(1);
    }
    return packageName;
  }
}
