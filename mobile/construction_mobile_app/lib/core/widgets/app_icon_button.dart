import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        color: color ??
            (isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor ??
              (isDark ? AppColors.darkElevatedCard : AppColors.lightSurface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
            side: BorderSide(
              color: backgroundColor != null
                  ? Colors.transparent
                  : AppColors.borderFor(brightness),
            ),
          ),
          minimumSize: const Size(44, 44),
        ),
      ),
    );
  }
}
