import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'blueprint_background.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool showBlueprint;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.showBlueprint = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final scaffoldBg = backgroundColor ??
        (brightness == Brightness.dark
            ? AppColors.darkBackground
            : AppColors.lightBackground);

    final scaffoldBody = showBlueprint
        ? BlueprintBackground(
            child: body,
          )
        : body;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: appBar,
      drawer: drawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: scaffoldBody,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
