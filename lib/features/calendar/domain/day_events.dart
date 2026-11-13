import '../../../core/utils/date_only.dart';
import '../../masturbations/domain/masturbation.dart';
import '../../profile/domain/partner_profile.dart';

/// One month of the calendar.
typedef CalendarMonth = ({int year, int month});

/// Pure helpers of the calendar view. They never modify their inputs (B4).
abstract final class CalendarDays {
  /// Groups [items] by day. Each list keeps the order of [items].
  static Map<DateOnly, List<T>> groupByDay<T>(
    Iterable<T> items,
    DateOnly Function(T item) dateOf,
  ) {
    final days = <DateOnly, List<T>>{};
    for (final item in items) {
      (days[dateOf(item)] ??= <T>[]).add(item);
    }
    return days;
  }

  /// Months from [last] back to [first], both included, newest first.
  static List<CalendarMonth> monthsDescending(
    CalendarMonth first,
    CalendarMonth last,
  ) {
    final months = <CalendarMonth>[];
    var year = last.year;
    var month = last.month;
    while (year > first.year || (year == first.year && month >= first.month)) {
      months.add((year: year, month: month));
      month--;
      if (month == 0) {
        month = 12;
        year--;
      }
    }
    return months;
  }

  /// Month of the calendar to show for [year]: the current month for the
  /// current year, December for past years.
  static CalendarMonth focusMonthOf(int year, DateOnly today) =>
      year >= today.year
      ? (year: today.year, month: today.month)
      : (year: year, month: 12);

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  /// Empty cells before day 1 in a week starting on Monday.
  static int leadingBlanks(int year, int month) =>
      DateTime(year, month).weekday - DateTime.monday;

  /// Number of week rows of a month (4 to 6).
  static int weekRows(int year, int month) =>
      ((leadingBlanks(year, month) + daysInMonth(year, month)) / 7).ceil();
}

/// Heart of a masturbation day. [left] is the gender of the only partner (or
/// of partner A when both masturbated); [right] is set only when both
/// partners masturbated that day (two-color heart).
final class MasturbationHeart {
  const MasturbationHeart(this.left, [this.right]);

  final Gender left;
  final Gender? right;

  bool get isSplit => right != null;

  /// `null` when [items] is empty.
  static MasturbationHeart? of(
    Iterable<Masturbation> items,
    PartnerProfile profile,
  ) {
    final who = {for (final m in items) m.who};
    if (who.isEmpty) return null;
    if (who.length == 1) return MasturbationHeart(profile.of(who.first).gender);
    return MasturbationHeart(
      profile.of(Partner.a).gender,
      profile.of(Partner.b).gender,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MasturbationHeart && other.left == left && other.right == right;

  @override
  int get hashCode => Object.hash(left, right);
}

/// Masturbations of one day with the heart to draw.
typedef MasturbationDay = ({List<Masturbation> items, MasturbationHeart heart});
