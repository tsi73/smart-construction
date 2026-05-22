import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

enum AuthMessageType { error, success, info }

class AuthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final String? message;
  final AuthMessageType messageType;

  const AuthCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.message,
    this.messageType = AuthMessageType.error,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Small logo mark
          Center(
            child: _buildLogo(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            AuthMessage(message: message!, type: messageType),
          ],
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Image.asset(
        'assets/branding/constructpro_logo.jpg',
        fit: BoxFit.contain,
      ),
    );
  }
}

class AuthMessage extends StatelessWidget {
  final String message;
  final AuthMessageType type;

  const AuthMessage({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final color = switch (type) {
      AuthMessageType.error => AppColors.error,
      AuthMessageType.success => AppColors.success,
      AuthMessageType.info => AppColors.accentBlue,
    };
    final icon = switch (type) {
      AuthMessageType.error => Icons.error_outline_rounded,
      AuthMessageType.success => Icons.check_circle_outline_rounded,
      AuthMessageType.info => Icons.info_outline_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.medium,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMd.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
