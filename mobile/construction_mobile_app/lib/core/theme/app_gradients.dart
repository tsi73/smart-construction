import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.darkBackground, AppColors.navySidebar],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.constructProBlue, AppColors.accentBlueStrong],
  );

  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.darkBackground,
      AppColors.darkSurface,
      AppColors.navySidebar,
      AppColors.constructProBlue,
    ],
    stops: [0, 0.42, 0.78, 1],
  );

  static const LinearGradient brandPanel = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.navySidebar, AppColors.constructProBlue],
  );

  static LinearGradient soft = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.lightBackground, Colors.white],
  );
}
