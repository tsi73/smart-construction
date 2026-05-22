import 'package:flutter/material.dart';

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;

  // Card radius (16-22px range per spec)
  static const double card = 18.0;

  // Button radius (14-18px range per spec)
  static const double button = 16.0;

  // Input radius
  static const double input = 12.0;

  // Chip / badge radius
  static const double chip = 20.0;

  // Bottom sheet radius
  static const double bottomSheet = 24.0;

  static const double s = 8.0;
  static const double m = 12.0;
  static const double l = 16.0;

  static BorderRadius small = BorderRadius.circular(sm);
  static BorderRadius medium = BorderRadius.circular(md);
  static BorderRadius large = BorderRadius.circular(lg);
  static BorderRadius extraLarge = BorderRadius.circular(xl);
  static BorderRadius doubleExtraLarge = BorderRadius.circular(xxl);
}
