import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../features/settings/data/theme_preference.dart';
import 'router.dart';
import 'theme.dart';

class TemperinoApp extends ConsumerWidget {
  const TemperinoApp({super.key});

  static const _locale = Locale('it', 'IT');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: _locale,
      supportedLocales: const [_locale],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        // Status/navigation bar icons follow the effective theme brightness.
        final style = systemOverlayFor(Theme.of(context).brightness);
        SystemChrome.setSystemUIOverlayStyle(style);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: style,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
