import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/config/app_config.dart';

/// Theme mode provider.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(AppConfig.keyThemeMode) ?? 0;
    state = ThemeMode.values[index];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConfig.keyThemeMode, mode.index);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(next);
  }
}

/// Onboarding completion provider.
final onboardingCompleteProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConfig.keyOnboardingComplete) ?? false;
  }

  Future<void> complete() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.keyOnboardingComplete, true);
  }
}

/// Notification retention period in days.
final retentionPeriodProvider =
    NotifierProvider<RetentionPeriodNotifier, int>(RetentionPeriodNotifier.new);

class RetentionPeriodNotifier extends Notifier<int> {
  @override
  int build() {
    _load();
    return AppConfig.freeRetentionDays;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(AppConfig.keyRetentionPeriod) ??
        AppConfig.freeRetentionDays;
  }

  Future<void> setDays(int days) async {
    state = days;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConfig.keyRetentionPeriod, days);
  }
}
