import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? widePadding;
  final Alignment alignment;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1180,
    this.mobilePadding,
    this.widePadding,
    this.alignment = Alignment.topCenter,
  });

  static bool isWide(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 840;
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    final padding = wide
        ? (widePadding ?? const EdgeInsets.all(AppSpacing.xl))
        : (mobilePadding ?? const EdgeInsets.all(AppSpacing.lg));

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
