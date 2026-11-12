import '../../../core/utils/date_only.dart';
import '../../activities/domain/sexual_activity.dart';
import '../../profile/domain/partner_profile.dart';

/// Two integers, one per partner.
class PartnerPair {
  const PartnerPair(this.a, this.b);

  static const zero = PartnerPair(0, 0);

  final int a;
  final int b;

  int of(Partner partner) => partner == Partner.a ? a : b;

  int get total => a + b;

  PartnerPair operator +(PartnerPair other) =>
      PartnerPair(a + other.a, b + other.b);
}

/// Everything the Home and the "Attività" stats tab need.
class ActivitySummary {
  const ActivitySummary({
    required this.sexCount,
    required this.orgasmsInActivities,
    required this.orgasmsDuringSex,
    required this.orgasmsDuringSexWhenBComes,
    required this.totalOrgasms,
    required this.ratio,
    required this.ratioWhenBComes,
    required this.practiceCounts,
    required this.activityCount,
  });

  final int activityCount;
  final int sexCount;
  final PartnerPair orgasmsInActivities;
  final PartnerPair orgasmsDuringSex;
  final PartnerPair orgasmsDuringSexWhenBComes;

  /// Activities + masturbations.
  final PartnerPair totalOrgasms;

  /// B during sex / A during sex. `null` when A is 0 (fix B1).
  final double? ratio;
  final double? ratioWhenBComes;

  final Map<Practice, int> practiceCounts;
}

class PartnerMasturbationStats {
  const PartnerMasturbationStats({
    required this.count,
    required this.withToys,
    required this.orgasms,
  });

  static const zero = PartnerMasturbationStats(
    count: 0,
    withToys: 0,
    orgasms: 0,
  );

  final int count;
  final int withToys;
  final int orgasms;

  int get withoutToys => count - withToys;
}

class MasturbationSummary {
  const MasturbationSummary({required this.a, required this.b});

  final PartnerMasturbationStats a;
  final PartnerMasturbationStats b;

  PartnerMasturbationStats of(Partner partner) => partner == Partner.a ? a : b;

  int get total => a.count + b.count;
  int get totalWithToys => a.withToys + b.withToys;
}

/// Per-day counters for the calendar heatmap.
class DayCount {
  const DayCount({this.activities = 0, this.masturbations = 0});

  final int activities;
  final int masturbations;

  int get total => activities + masturbations;
}

class CalendarData {
  const CalendarData({required this.year, required this.days});

  final int year;
  final Map<DateOnly, DayCount> days;

  DayCount of(DateOnly date) => days[date] ?? const DayCount();

  int get maxTotal => days.values.fold(0, (m, d) => d.total > m ? d.total : m);
}

/// Monthly series of one year, used by the year comparison chart.
class YearStats {
  const YearStats({
    required this.year,
    required this.monthlySex,
    required this.monthlyOrgasms,
  });

  final int year;

  /// 12 values: number of activities with sex per month.
  final List<int> monthlySex;

  /// 12 values: total orgasms (both partners, activities + masturbations).
  final List<int> monthlyOrgasms;

  int get totalSex => monthlySex.fold(0, (s, v) => s + v);
  int get totalOrgasms => monthlyOrgasms.fold(0, (s, v) => s + v);
}
