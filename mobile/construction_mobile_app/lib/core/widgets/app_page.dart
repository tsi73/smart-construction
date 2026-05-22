import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import 'responsive_content.dart';

class AppPage extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;

  const AppPage({
    super.key,
    required this.child,
    this.maxWidth = 1180,
    this.padding,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = ResponsiveContent(
      maxWidth: maxWidth,
      mobilePadding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      widePadding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      child: child,
    );

    return safeArea ? SafeArea(child: content) : content;
  }
}
