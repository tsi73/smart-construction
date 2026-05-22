import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static bool get _isDark => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  static const List<String> fontFallback = [
    'Noto Sans Ethiopic',
    'Noto Sans',
    'Arial',
  ];

  static TextStyle _withFallback(TextStyle style) {
    return style.copyWith(fontFamilyFallback: fontFallback);
  }

  // Headings
  static TextStyle get brandTitle => _withFallback(GoogleFonts.outfit(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
        height: 1.2,
        color: (_isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ));

  static TextStyle get heroTitle => _withFallback(GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.2,
        color: (_isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ));

  static TextStyle get screenTitle => _withFallback(GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.25,
        color: (_isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ));

  static TextStyle get sectionTitle => _withFallback(GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.3,
        color: (_isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ));

  static TextStyle get cardTitle => _withFallback(GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: (_isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ));

  // Body
  static TextStyle get body => bodyMd;

  static TextStyle get bodyLg => _withFallback(GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: (_isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        height: 1.55,
        letterSpacing: 0,
      ));

  static TextStyle get bodyMd => _withFallback(GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: (_isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        height: 1.55,
        letterSpacing: 0,
      ));

  static TextStyle get bodyMuted => _withFallback(GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: (_isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
        height: 1.55,
        letterSpacing: 0,
      ));

  static TextStyle get bodySm => _withFallback(GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: (_isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        height: 1.5,
        letterSpacing: 0,
      ));

  // Small text
  static TextStyle get caption => _withFallback(GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: (_isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
        height: 1.4,
        letterSpacing: 0,
      ));

  static TextStyle get label => _withFallback(GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: (_isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ));

  // UI Components
  static TextStyle get button => _withFallback(GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
      ));

  static TextStyle get badge => _withFallback(GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        height: 1.2,
      ));

  // Metric / stat value
  static TextStyle get metricValue => _withFallback(GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: (_isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ));

  // Legacy Mapping
  static TextStyle get h1 => heroTitle;
  static TextStyle get h2 => screenTitle;
  static TextStyle get h3 => sectionTitle;
}
