import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/concurrency.dart';
import '../../activities/data/activities_repository.dart';
import '../../activities/domain/sexual_activity.dart';
import '../../activities/presentation/activities_providers.dart';
import '../../masturbations/data/masturbations_repository.dart';
import '../../masturbations/domain/masturbation.dart';
import '../../masturbations/presentation/masturbations_providers.dart';
import '../../settings/data/year_preference.dart';
import '../domain/stats_calculator.dart';
import '../domain/stats_models.dart';

/// Both lists of one year.
class YearData {
  const YearData(this.activities, this.masturbations);

  final List<SexualActivity> activities;
  final List<Masturbation> masturbations;
}

final yearDataProvider = FutureProvider.family<YearData, int>((
  ref,
  year,
) async {
  final activities = ref.watch(activitiesProvider(year).future);
  final masturbations = ref.watch(masturbationsProvider(year).future);
  return YearData(await activities, await masturbations);
});

final summaryProvider = FutureProvider.family<ActivitySummary, int>((
  ref,
  year,
) async {
  final d = await ref.watch(yearDataProvider(year).future);
  return StatsCalculator.activitySummary(d.activities, d.masturbations);
});

final masturbationSummaryProvider =
    FutureProvider.family<MasturbationSummary, int>((ref, year) async {
      final list = await ref.watch(masturbationsProvider(year).future);
      return StatsCalculator.masturbationSummary(list);
    });

final monthlyProvider = FutureProvider.family<List<PartnerPair>, int>((
  ref,
  year,
) async {
  final d = await ref.watch(yearDataProvider(year).future);
  return StatsCalculator.monthlyOrgasms(d.activities, d.masturbations);
});

final monthlyRatioProvider = FutureProvider.family<List<double?>, int>((
  ref,
  year,
) async {
  final list = await ref.watch(activitiesProvider(year).future);
  return StatsCalculator.monthlyRatio(list);
});

final cumshotProvider =
    FutureProvider.family<List<MapEntry<CumshotZone, int>>, int>((
      ref,
      year,
    ) async {
      final list = await ref.watch(activitiesProvider(year).future);
      return StatsCalculator.cumshotCounts(list);
    });

final calendarProvider = FutureProvider.family<CalendarData, int>((
  ref,
  year,
) async {
  final d = await ref.watch(yearDataProvider(year).future);
  return StatsCalculator.calendar(year, d.activities, d.masturbations);
});

/// Monthly series for every year from `startYear` to the current one, oldest
/// first. The current year reuses the cached lists; the other years are
/// fetched directly with at most [AppConfig.maxParallelRequests] requests in
/// flight. Invalidated by every mutation.
final yearlyProvider = FutureProvider<List<YearStats>>((ref) async {
  final currentYear = DateTime.now().year;
  final current = ref.watch(yearDataProvider(currentYear).future);
  final activitiesRepo = ref.watch(activitiesRepositoryProvider);
  final masturbationsRepo = ref.watch(masturbationsRepositoryProvider);

  final otherYears = selectableYears().where((y) => y != currentYear).toList();
  final tasks = [
    for (final y in otherYears) ...[(y, true), (y, false)],
  ];
  final results = await mapWithConcurrency<(int, bool), Object>(
    tasks,
    AppConfig.maxParallelRequests,
    (t) => t.$2
        ? activitiesRepo.listForYear(t.$1)
        : masturbationsRepo.listForYear(t.$1),
  );

  final stats = <YearStats>[];
  for (var i = 0; i < otherYears.length; i++) {
    stats.add(
      StatsCalculator.yearStats(
        otherYears[i],
        results[i * 2] as List<SexualActivity>,
        results[i * 2 + 1] as List<Masturbation>,
      ),
    );
  }
  final c = await current;
  stats.add(
    StatsCalculator.yearStats(currentYear, c.activities, c.masturbations),
  );
  stats.sort((x, y) => x.year.compareTo(y.year));
  return stats;
});
