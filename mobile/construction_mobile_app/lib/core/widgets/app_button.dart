import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radius.dart';

enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutline;
  final bool isDanger;
  final IconData? icon;
  final AppButtonSize size;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutline = false,
    this.isDanger = false,
    this.icon,
    this.size = AppButtonSize.large,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color baseColor =
        widget.isDanger ? AppColors.error : AppColors.accentBlueStrong;
    if (isDark && !widget.isDanger) baseColor = AppColors.accentBlue;
    final disabledTextColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    final double height = widget.size == AppButtonSize.large
        ? 54
        : (widget.size == AppButtonSize.medium ? 48 : 40);
    final double padding = widget.size == AppButtonSize.large ? 24 : 16;
    final TextStyle style = widget.size == AppButtonSize.large
        ? AppTextStyles.button
        : AppTextStyles.label;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: widget.isOutline
            ? OutlinedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, height),
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  foregroundColor: baseColor,
                  side: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button)),
                ),
                child: _buildContent(
                    widget.onPressed == null ? disabledTextColor : baseColor,
                    style),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  boxShadow: (widget.onPressed == null || widget.isLoading)
                      ? []
                      : AppShadows.buttonPrimary(baseColor),
                ),
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, height),
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    backgroundColor: widget.isDanger
                        ? (isDark
                            ? AppColors.destructiveDark
                            : AppColors.destructiveLight)
                        : baseColor,
                    foregroundColor:
                        widget.isDanger ? AppColors.error : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button)),
                    elevation: 0,
                  ),
                  child: _buildContent(
                      widget.onPressed == null
                          ? disabledTextColor
                          : (widget.isDanger ? AppColors.error : Colors.white),
                      style),
                ),
              ),
      ),
    );
  }

  Widget _buildContent(Color color, TextStyle style) {
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: color),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: style.copyWith(color: color),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
