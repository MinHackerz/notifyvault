import 'package:flutter/material.dart';

/// NotifyVault color system — professional solid color palette (no gradients).
class AppColors {
  AppColors._();

  // ─── Brand Colors ───
  static const Color primary = Color(0xFF3F51B5);       // Professional Indigo
  static const Color primaryLight = Color(0xFF757DE8);
  static const Color primaryDark = Color(0xFF002984);

  static const Color secondary = Color(0xFF263238);      // Professional Blue Grey (Slate)
  static const Color secondaryLight = Color(0xFF4F5B62);
  static const Color secondaryDark = Color(0xFF000A12);

  static const Color accent = Color(0xFF00897B);         // Teal

  // ─── Semantic Colors ───
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color success = Color(0xFF388E3C);
  static const Color info = Color(0xFF1976D2);

  // ─── Light Theme ───
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFECEFF1);
  static const Color onBackgroundLight = Color(0xFF1C2731);
  static const Color onSurfaceLight = Color(0xFF1C2731);
  static const Color onSurfaceVariantLight = Color(0xFF546E7A);
  static const Color outlineLight = Color(0x0F000000); // Softer Latch-style outline
  static const Color dividerLight = Color(0xFFECEFF1);

  // ─── Dark Theme ───
  static const Color backgroundDark = Color(0xFF12181B);
  static const Color surfaceDark = Color(0xFF1E262C);
  static const Color surfaceVariantDark = Color(0xFF2B363F);
  static const Color onBackgroundDark = Color(0xFFECEFF1);
  static const Color onSurfaceDark = Color(0xFFECEFF1);
  static const Color onSurfaceVariantDark = Color(0xFF90A4AE);
  static const Color outlineDark = Color(0x14FFFFFF); // Softer Latch-style outline
  static const Color dividerDark = Color(0xFF263238);

  // ─── Category Colors ───
  static const Color categoryOtp = Color(0xFFE65100);
  static const Color categoryBanking = Color(0xFF00695C);
  static const Color categoryPayments = Color(0xFF4A148C);
  static const Color categoryShopping = Color(0xFF880E4F);
  static const Color categoryDelivery = Color(0xFFBF360C);
  static const Color categorySocial = Color(0xFF0D47A1);
  static const Color categoryMessages = Color(0xFF006064);
  static const Color categoryEmail = Color(0xFF1A237E);
  static const Color categoryWork = Color(0xFF004D40);
  static const Color categoryGovernment = Color(0xFF01579B);
  static const Color categoryEducation = Color(0xFF311B92);
  static const Color categoryHealth = Color(0xFFB71C1C);
  static const Color categoryEntertainment = Color(0xFF880E4F);
  static const Color categoryPromotions = Color(0xFF33691E);
  static const Color categorySpam = Color(0xFF37474F);
  static const Color categoryOther = Color(0xFF455A64);
}
