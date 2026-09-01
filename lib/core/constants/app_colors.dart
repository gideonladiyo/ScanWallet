import 'package:flutter/material.dart';

/// Preset accent colors offered in account/category forms.
class ColorPresets {
  const ColorPresets._();

  static const List<String> hex = [
    '#2ECC71',
    '#F5A623',
    '#7C5CFC',
    '#4F7CFF',
    '#FF5C5C',
    '#9AA0AC',
  ];
}

/// Semantic color tokens (DESIGN.md §2.2) exposed as a ThemeExtension so
/// every screen reads theme-aware colors via
/// `Theme.of(context).extension<AppColors>()!`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.primary,
    required this.secondary,
    required this.success,
    required this.error,
    required this.warning,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color primary;
  final Color secondary;
  final Color success;
  final Color error;
  final Color warning;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  static const AppColors dark = AppColors(
    background: Color(0xFF0F1115),
    surface: Color(0xFF1A1D23),
    surfaceElevated: Color(0xFF242830),
    primary: Color(0xFF4F7CFF),
    secondary: Color(0xFF7C5CFC),
    success: Color(0xFF2ECC71),
    error: Color(0xFFFF5C5C),
    warning: Color(0xFFF5A623),
    textPrimary: Color(0xFFF5F6FA),
    textSecondary: Color(0xFF9AA0AC),
    border: Color(0xFF2C303A),
  );

  static const AppColors light = AppColors(
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0F1F5),
    primary: Color(0xFF3D63E0),
    secondary: Color(0xFF6A4CE0),
    success: Color(0xFF1EA85C),
    error: Color(0xFFE4483C),
    warning: Color(0xFFD98A1B),
    textPrimary: Color(0xFF1A1D23),
    textSecondary: Color(0xFF5C616B),
    border: Color(0xFFE1E3E8),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? primary,
    Color? secondary,
    Color? success,
    Color? error,
    Color? warning,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}
