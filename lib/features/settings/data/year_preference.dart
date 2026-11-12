import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/preferences_provider.dart';

/// Years selectable in the app: from [AppConfig.startYear] to the current one.
List<int> selectableYears() {
  final current = DateTime.now().year;
  final first = AppConfig.startYear <= current ? AppConfig.startYear : current;
  return [for (var y = current; y >= first; y--) y];
}

/// Selected year, persisted in shared_preferences (fix B6). Every list
/// provider is keyed by year, so changing it reloads the data (fix B5).
class YearNotifier extends Notifier<int> {
  @override
  int build() {
    final stored = ref
        .watch(sharedPreferencesProvider)
        .getInt(AppConfig.prefSelectedYear);
    return _clamp(stored ?? DateTime.now().year);
  }

  int _clamp(int year) {
    final years = selectableYears();
    if (year > years.first) return years.first;
    if (year < years.last) return years.last;
    return year;
  }

  Future<void> select(int year) async {
    final value = _clamp(year);
    state = value;
    await ref
        .read(sharedPreferencesProvider)
        .setInt(AppConfig.prefSelectedYear, value);
  }
}

final yearProvider = NotifierProvider<YearNotifier, int>(YearNotifier.new);
