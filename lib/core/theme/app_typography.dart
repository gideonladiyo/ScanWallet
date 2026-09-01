import 'package:flutter/material.dart';

/// Text theme per DESIGN.md §3. Inter with tabular figures for numerals.
class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Inter';

  static TextTheme textTheme({
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        fontFamily: fontFamily,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: fontFamily,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: fontFamily,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        fontFamily: fontFamily,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        fontFamily: fontFamily,
      ),
    );
  }

  /// 28px bold with tabular figures for money amounts (DESIGN.md §3).
  static const TextStyle numericLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
