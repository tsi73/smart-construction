import 'package:flutter/material.dart';

class AppColors {
  // Foresite brand
  static const Color constructProBlue = Color(0xFF347DBB);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentBlueStrong = Color(0xFF2563EB);
  static const Color navySidebar = Color(0xFF173866);

  // Dark mode
  static const Color darkBackground = Color(0xFF0A0F1A);
  static const Color darkSurface = Color(0xFF0F1623);
  static const Color darkCard = Color(0xFF141D2B);
  static const Color darkElevatedCard = Color(0xFF1A2536);
  static const Color darkBorder = Color(0xFF1F2D3A);
  static const Color darkMutedBorder = Color(0xFF162330);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // Light mode
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFDDE5EE);
  static const Color lightMutedSurface = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF64748B);

  // Blueprint background colors
  static const Color blueprintLineLight = Color(0xFF94A3B8);
  static const Color blueprintLineDark = Color(0xFF1E3A5F);

  // Legacy brand aliases
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color secondaryNavy = navySidebar;
  static const Color brightBlue = accentBlue;
  static const Color softBlue = Color(0xFFDBEAFE);
  static const Color slateBackground = lightBackground;
  static const Color cardWhite = lightCard;
  static const Color mutedSurface = lightMutedSurface;

  // Text aliases
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;

  // Status
  static const Color statusDraft = Color(0xFF64748B);
  static const Color statusSubmitted = Color(0xFFF59E0B);
  static const Color statusConsultantApproved = Color(0xFF4F46E5);
  static const Color statusApproved = Color(0xFF16A34A);
  static const Color statusRejected = Color(0xFFDC2626);
  static const Color statusPendingSync = Color(0xFF0EA5E9);
  static const Color statusSyncFailed = Color(0xFFDC2626);
  static const Color statusOffline = Color(0xFFF59E0B);
  static const Color statusTaskPending = Color(0xFF64748B);
  static const Color statusTaskInProgress = Color(0xFF2563EB);
  static const Color statusTaskCompleted = Color(0xFF16A34A);

  static const Color success = statusApproved;
  static const Color warning = statusSubmitted;
  static const Color error = statusRejected;
  static const Color info = accentBlueStrong;

  // Premium brand palette
  static const Color brandBlue = Color(0xFF1E40AF);
  static const Color brandBlueDark = Color(0xFF1E3A8A);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color surfaceCard = Color(0xFF0F172A);
  static const Color glowBlue = Color(0x264A90D9);

  // Focus glow
  static const Color focusGlowLight = Color(0x1A2563EB);
  static const Color focusGlowDark = Color(0x1A3B82F6);

  // Destructive tint
  static const Color destructiveLight = Color(0xFFFEE2E2);
  static const Color destructiveDark = Color(0xFF1C0F0F);

  // Legacy Mapping (keeping for compatibility during transition)
  static const Color primary = primaryNavy;
  static const Color secondary = mutedSurface;
  static const Color accent = accentBlueStrong;
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = textPrimary;
  static const Color onBackground = textPrimary;
  static const Color onSurface = textPrimary;

  static Color surfaceFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurface : lightSurface;
  }

  static Color cardFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkCard : lightCard;
  }

  static Color elevatedCardFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkElevatedCard : lightCard;
  }

  static Color borderFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkBorder : lightBorder;
  }

  static Color mutedTextFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextMuted : lightTextMuted;
  }

  static Color secondaryTextFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  static Color focusGlowFor(Brightness brightness) {
    return brightness == Brightness.dark ? focusGlowDark : focusGlowLight;
  }

  static Color primaryTextFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  }
}
