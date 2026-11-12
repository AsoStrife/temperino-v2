import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stats/presentation/stats_providers.dart';
import '../data/activities_repository.dart';
import '../domain/sexual_activity.dart';

/// Activities of one year, newest first. Mutations reload the list (B5) and
/// invalidate every other provider that depends on the touched years.
class ActivitiesNotifier extends AsyncNotifier<List<SexualActivity>> {
  ActivitiesNotifier(this.year);

  final int year;

  ActivitiesRepository get _repo => ref.read(activitiesRepositoryProvider);

  @override
  Future<List<SexualActivity>> build() =>
      ref.watch(activitiesRepositoryProvider).listForYear(year);

  Future<void> add(SexualActivity activity) async {
    await _repo.create(activity);
    await _reload({activity.date.year});
  }

  /// [previousYear] is the year of the record before the edit (the date may
  /// have moved to another year).
  Future<void> edit(SexualActivity activity, {int? previousYear}) async {
    await _repo.update(activity);
    await _reload({activity.date.year, ?previousYear});
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    await _reload(const {});
  }

  Future<void> _reload(Set<int> touchedYears) async {
    for (final y in touchedYears) {
      if (y != year) ref.invalidate(activitiesProvider(y));
    }
    ref.invalidate(yearlyProvider);
    state = await AsyncValue.guard(() => _repo.listForYear(year));
  }

  /// Record from the already loaded list, or `null`.
  SexualActivity? findById(int id) {
    for (final x in state.value ?? const <SexualActivity>[]) {
      if (x.id == id) return x;
    }
    return null;
  }
}

final activitiesProvider =
    AsyncNotifierProvider.family<ActivitiesNotifier, List<SexualActivity>, int>(
      ActivitiesNotifier.new,
    );
