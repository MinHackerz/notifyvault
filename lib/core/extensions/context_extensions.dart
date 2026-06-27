import 'package:flutter/material.dart';

/// Extension methods for BuildContext.
extension ContextExtensions on BuildContext {
  /// Get the current ThemeData.
  ThemeData get theme => Theme.of(this);

  /// Get the current ColorScheme.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get the current TextTheme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Get screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Get screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Get safe area padding.
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  /// Check if the current theme is dark.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Show a snackbar with a message.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
