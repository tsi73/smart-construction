import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/offline_banner.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';

class ConstructProApp extends ConsumerWidget {
  const ConstructProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      title: 'ConstructPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
      ],
      routerConfig: router,
      builder: (context, child) {
        // Don't wrap splash screen to avoid layout issues
        final currentRoute = router.routeInformationProvider.value.uri.path;
        final isSplash = currentRoute == '/' || currentRoute.isEmpty;

        if (isSplash) {
          return child ?? const SizedBox.shrink();
        }

        return Column(
          children: [
            if (child != null) Expanded(child: child),
            const OfflineBanner(),
          ],
        );
      },
    );
  }
}
