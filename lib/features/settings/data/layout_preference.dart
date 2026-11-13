import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/preferences_provider.dart';

/// Layout of the activities and masturbations tabs.
enum ListLayout { list, calendar }

/// Layout shared by both tabs, persisted in shared_preferences.
class ListLayoutNotifier extends Notifier<ListLayout> {
  @override
  ListLayout build() {
    final stored = ref
        .watch(sharedPreferencesProvider)
        .getString(AppConfig.prefListLayout);
    return ListLayout.values.firstWhere(
      (l) => l.name == stored,
      orElse: () => ListLayout.list,
    );
  }

  Future<void> select(ListLayout layout) async {
    state = layout;
    await ref
        .read(sharedPreferencesProvider)
        .setString(AppConfig.prefListLayout, layout.name);
  }
}

final listLayoutProvider = NotifierProvider<ListLayoutNotifier, ListLayout>(
  ListLayoutNotifier.new,
);
