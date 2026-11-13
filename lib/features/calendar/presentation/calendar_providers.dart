import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_only.dart';
import '../../activities/domain/sexual_activity.dart';
import '../../activities/presentation/activities_providers.dart';
import '../../masturbations/domain/masturbation.dart';
import '../../masturbations/presentation/masturbations_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../settings/data/year_preference.dart';
import '../domain/day_events.dart';

/// Months shown by the calendar: from January of `AppConfig.startYear` to the
/// current month, newest first.
List<CalendarMonth> calendarMonths(DateOnly today) {
  final years = selectableYears();
  return CalendarDays.monthsDescending(
    (year: years.last, month: 1),
    (year: today.year, month: today.month),
  );
}

/// Activities of every selectable year grouped by day. Reuses the per-year
/// providers, so mutations made in the forms show up here too.
final activityDaysProvider =
    Provider<AsyncValue<Map<DateOnly, List<SexualActivity>>>>((ref) {
      final years = [
        for (final y in selectableYears()) ref.watch(activitiesProvider(y)),
      ];
      return _combine(years)
          .whenData((all) => CalendarDays.groupByDay(all, (x) => x.date));
    });

/// Masturbations of every selectable year grouped by day, with the heart of
/// each day (colors follow the gender in the local profile).
final masturbationDaysProvider =
    Provider<AsyncValue<Map<DateOnly, MasturbationDay>>>((ref) {
      final profile = ref.watch(requireProfileProvider);
      final years = [
        for (final y in selectableYears()) ref.watch(masturbationsProvider(y)),
      ];
      return _combine(years).whenData((all) {
        final days = CalendarDays.groupByDay<Masturbation>(all, (m) => m.date);
        return {
          for (final e in days.entries)
            e.key: (
              items: e.value,
              heart: MasturbationHeart.of(e.value, profile)!,
            ),
        };
      });
    });

/// One value for several years: error if any year failed, loading until every
/// year has data, otherwise all the items together.
AsyncValue<List<T>> _combine<T>(List<AsyncValue<List<T>>> years) {
  for (final y in years) {
    if (y.hasError) {
      return AsyncValue.error(y.error!, y.stackTrace ?? StackTrace.empty);
    }
  }
  if (years.any((y) => !y.hasValue)) return const AsyncValue.loading();
  return AsyncValue.data([for (final y in years) ...y.requireValue]);
}
