import 'package:flutter/material.dart';

class AppShadows {
  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardLight = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.22),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> floatingNav = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> darkCard = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.18),
      blurRadius: 16,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> dark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  // Elevated card shadow for premium feel
  static List<BoxShadow> elevatedLight = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.28),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Button shadow
  static List<BoxShadow> buttonPrimary(Color baseColor) => [
        BoxShadow(
          color: baseColor.withValues(alpha: 0.24),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // Bottom sheet shadow
  static List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 32,
      offset: const Offset(0, -8),
    ),
  ];

  // Context-aware helper
  static List<BoxShadow> cardFor(Brightness brightness) {
    return brightness == Brightness.dark ? cardDark : cardLight;
  }

  static List<BoxShadow> elevatedFor(Brightness brightness) {
    return brightness == Brightness.dark ? elevatedDark : elevatedLight;
  }
}
