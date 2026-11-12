import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/storage/preferences_provider.dart';
import 'core/utils/formatters.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge (mandatory with targetSdk >= 35): content draws behind the
  // transparent system bars; layouts use SafeArea / MediaQuery.padding.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  Intl.defaultLocale = Formatters.locale;
  await initializeDateFormatting(Formatters.locale);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Errors are shown with a "Riprova" button: no automatic retries.
      retry: (retryCount, error) => null,
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TemperinoApp(),
    ),
  );
}
