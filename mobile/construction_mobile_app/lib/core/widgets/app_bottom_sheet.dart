import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Shows a premium bottom sheet with dim/blur backdrop and spring slide-up.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? barrierColor,
}) {
  final brightness = Theme.of(context).brightness;
  final barrier = barrierColor ??
      (brightness == Brightness.dark
          ? Colors.black.withValues(alpha: 0.55)
          : Colors.black.withValues(alpha: 0.35));

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    barrierColor: barrier,
    backgroundColor: Colors.transparent,
    builder: (context) => _AppBottomSheetContainer(child: builder(context)),
  );
}

class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return _AppBottomSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || trailing != null)
            _BottomSheetHeader(title: title, trailing: trailing),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  final String? title;
  final Widget? trailing;

  const _BottomSheetHeader({this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: AppTextStyles.cardTitle.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _AppBottomSheetContainer extends StatefulWidget {
  final Widget child;

  const _AppBottomSheetContainer({required this.child});

  @override
  State<_AppBottomSheetContainer> createState() =>
      _AppBottomSheetContainerState();
}

class _AppBottomSheetContainerState extends State<_AppBottomSheetContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkElevatedCard : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
          boxShadow: AppShadows.bottomSheet,
          border: Border.all(color: AppColors.borderFor(brightness), width: 1),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkTextMuted.withValues(alpha: 0.3)
                        : AppColors.lightTextMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Flexible(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}
