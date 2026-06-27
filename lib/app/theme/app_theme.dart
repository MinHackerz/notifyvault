import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// NotifyVault Material 3 theme configuration — flat professional edition.
class AppTheme {
  AppTheme._();

  // ─── Light Theme ───
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      surfaceContainerHighest: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
      outline: AppColors.outlineLight,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ─── Dark Theme ───
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.secondaryDark,
      secondary: AppColors.onSurfaceVariantDark,
      onSecondary: AppColors.secondaryDark,
      tertiary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      surfaceContainerHighest: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      outline: AppColors.outlineDark,
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ─── Shared Theme Builder ───
  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final textTheme = GoogleFonts.interTextTheme(baseTextTheme).copyWith(
      displayLarge: GoogleFonts.instrumentSerif(
        textStyle: baseTextTheme.displayLarge?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          height: 1.1,
          color: colorScheme.onSurface,
        ),
      ),
      displayMedium: GoogleFonts.instrumentSerif(
        textStyle: baseTextTheme.displayMedium?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          height: 1.1,
          color: colorScheme.onSurface,
        ),
      ),
      displaySmall: GoogleFonts.instrumentSerif(
        textStyle: baseTextTheme.displaySmall?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          height: 1.1,
          color: colorScheme.onSurface,
        ),
      ),
      headlineLarge: GoogleFonts.instrumentSerif(
        textStyle: baseTextTheme.headlineLarge?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          height: 1.15,
          color: colorScheme.onSurface,
        ),
      ),
      headlineMedium: GoogleFonts.instrumentSerif(
        textStyle: baseTextTheme.headlineMedium?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          height: 1.15,
          color: colorScheme.onSurface,
        ),
      ),
      headlineSmall: GoogleFonts.instrumentSerif(
        textStyle: baseTextTheme.headlineSmall?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          height: 1.2,
          color: colorScheme.onSurface,
        ),
      ),
      titleLarge: GoogleFonts.instrumentSerif(
        textStyle: baseTextTheme.titleLarge?.copyWith(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          fontSize: 22,
          color: colorScheme.onSurface,
        ),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      dividerColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        foregroundColor:
            isDark ? AppColors.onBackgroundDark : AppColors.onBackgroundLight,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.instrumentSerif(
          fontSize: 22,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.normal,
          color: isDark
              ? AppColors.onBackgroundDark
              : AppColors.onBackgroundLight,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 1.0,
          ),
        ),
        color: colorScheme.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Chips
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(
          color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          width: 1.0,
        ),
        backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 1.0,
          ),
        ),
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 1.0,
          ),
        ),
        elevation: 0,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
            width: 1.0,
          ),
        ),
      ),

      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
