import 'package:flutter/material.dart';

/// NotifyVault color system — modern premium color palette with gradients.
class AppColors {
  AppColors._();

  // ─── Brand Colors ───
  static const Color primary = Color(0xFF6366F1);       // Electric Indigo
  static const Color primaryLight = Color(0xFFA5B4FC);
  static const Color primaryDark = Color(0xFF4338CA);

  static const Color secondary = Color(0xFF0F172A);      // Slate Obsidian
  static const Color secondaryLight = Color(0xFF1E293B);
  static const Color secondaryDark = Color(0xFF020617);

  static const Color accent = Color(0xFF10B981);         // Emerald Teal

  // ─── Semantic Colors ───
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // ─── Light Theme ───
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color onBackgroundLight = Color(0xFF0F172A);
  static const Color onSurfaceLight = Color(0xFF0F172A);
  static const Color onSurfaceVariantLight = Color(0xFF64748B);
  static const Color outlineLight = Color(0x0F000000); 
  static const Color dividerLight = Color(0xFFE2E8F0);

  // ─── Dark Theme ───
  static const Color backgroundDark = Color(0xFF0B0F19);   // Deep Obsidian
  static const Color surfaceDark = Color(0xFF151D30);      // Slate 800 Card
  static const Color surfaceVariantDark = Color(0xFF1E293B);
  static const Color onBackgroundDark = Color(0xFFF8FAFC);
  static const Color onSurfaceDark = Color(0xFFF8FAFC);
  static const Color onSurfaceVariantDark = Color(0xFF94A3B8);
  static const Color outlineDark = Color(0x14FFFFFF); 
  static const Color dividerDark = Color(0xFF1E293B);

  // ─── Category Colors ───
  static const Color categoryOtp = Color(0xFFF59E0B);
  static const Color categoryBanking = Color(0xFF10B981);
  static const Color categoryPayments = Color(0xFF8B5CF6);
  static const Color categoryShopping = Color(0xFFEC4899);
  static const Color categoryDelivery = Color(0xFFF97316);
  static const Color categorySocial = Color(0xFF3B82F6);
  static const Color categoryMessages = Color(0xFF06B6D4);
  static const Color categoryEmail = Color(0xFF6366F1);
  static const Color categoryWork = Color(0xFF14B8A6);
  static const Color categoryGovernment = Color(0xFF475569);
  static const Color categoryEducation = Color(0xFF6D28D9);
  static const Color categoryHealth = Color(0xFFEF4444);
  static const Color categoryEntertainment = Color(0xFFD946EF);
  static const Color categoryPromotions = Color(0xFF84CC16);
  static const Color categorySpam = Color(0xFF64748B);
  static const Color categoryOther = Color(0xFF94A3B8);

  // ─── Brand Gradients ───
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient premiumGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient bgDarkGradient = LinearGradient(
    colors: [Color(0xFF0B0F19), Color(0xFF020617)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
