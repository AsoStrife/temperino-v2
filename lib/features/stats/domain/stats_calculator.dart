import '../../../core/utils/date_only.dart';
import '../../activities/domain/sexual_activity.dart';
import '../../masturbations/domain/masturbation.dart';
import '../../profile/domain/partner_profile.dart';
import 'stats_models.dart';

/// Pure statistics functions (no Flutter imports). A = partner 1,
/// B = partner 2. Inputs are never modified.
abstract final class StatsCalculator {
  static PartnerPair _orgasms(Iterable<SexualActivity> items) => items.fold(
    PartnerPair.zero,
    (sum, x) => sum + PartnerPair(x.orgasmA, x.orgasmB),
  );

  static PartnerPair masturbationOrgasms(Iterable<Masturbation> items) {
    var a = 0, b = 0;
    for (final m in items) {
      if (m.who == Partner.a) {
        a += m.orgasms;
      } else {
        b += m.orgasms;
      }
    }
    return PartnerPair(a, b);
  }

  /// B / A, or `null` when A is zero (fix B1).
  static double? ratio(PartnerPair p) => p.a == 0 ? null : p.b / p.a;

  static ActivitySummary activitySummary(
    List<SexualActivity> activities,
    List<Masturbation> masturbations,
  ) {
    final sex = activities.where((x) => x.isSex).toList();
    final sexWhenBComes = sex.where((x) => x.orgasmB > 0);

    final inActivities = _orgasms(activities);
    final duringSex = _orgasms(sex);
    final duringSexWhenBComes = _orgasms(sexWhenBComes);

    return ActivitySummary(
      activityCount: activities.length,
      sexCount: sex.length,
      orgasmsInActivities: inActivities,
      orgasmsDuringSex: duringSex,
      orgasmsDuringSexWhenBComes: duringSexWhenBComes,
      totalOrgasms: inActivities + masturbationOrgasms(masturbations),
      ratio: ratio(duringSex),
      ratioWhenBComes: ratio(duringSexWhenBComes),
      practiceCounts: practiceCounts(activities),
    );
  }

  /// Number of activities per practice, in [Practice.statsPractices] order.
  static Map<Practice, int> practiceCounts(List<SexualActivity> activities) => {
    for (final p in Practice.statsPractices)
      p: activities.where((x) => x.has(p)).length,
  };

  /// All 12 zones (including `none`), most frequent first (fix B2).
  static List<MapEntry<CumshotZone, int>> cumshotCounts(
    List<SexualActivity> activities,
  ) {
    final counts = {for (final z in CumshotZone.values) z: 0};
    for (final x in activities) {
      counts[x.cumshot] = counts[x.cumshot]! + 1;
    }
    final entries = counts.entries.toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    return entries;
  }

  /// 12 values: orgasms per month per partner (activities + masturbations).
  static List<PartnerPair> monthlyOrgasms(
    List<SexualActivity> activities,
    List<Masturbation> masturbations,
  ) {
    final a = List.filled(12, 0);
    final b = List.filled(12, 0);
    for (final x in activities) {
      a[x.date.month - 1] += x.orgasmA;
      b[x.date.month - 1] += x.orgasmB;
    }
    for (final m in masturbations) {
      if (m.who == Partner.a) {
        a[m.date.month - 1] += m.orgasms;
      } else {
        b[m.date.month - 1] += m.orgasms;
      }
    }
    return List.generate(12, (i) => PartnerPair(a[i], b[i]));
  }

  /// 12 values: D/A ratio during sex per month, `null` when undefined.
  static List<double?> monthlyRatio(List<SexualActivity> activities) {
    final sums = List.filled(12, PartnerPair.zero);
    for (final x in activities.where((x) => x.isSex)) {
      final i = x.date.month - 1;
      sums[i] = sums[i] + PartnerPair(x.orgasmA, x.orgasmB);
    }
    return sums.map(ratio).toList();
  }

  /// 12 values: number of activities with sex per month.
  static List<int> monthlySex(List<SexualActivity> activities) {
    final counts = List.filled(12, 0);
    for (final x in activities.where((x) => x.isSex)) {
      counts[x.date.month - 1]++;
    }
    return counts;
  }

  static MasturbationSummary masturbationSummary(
    List<Masturbation> masturbations,
  ) {
    PartnerMasturbationStats forPartner(Partner p) {
      final items = masturbations.where((m) => m.who == p);
      return PartnerMasturbationStats(
        count: items.length,
        withToys: items.where((m) => m.toys).length,
        orgasms: items.fold(0, (s, m) => s + m.orgasms),
      );
    }

    return MasturbationSummary(
      a: forPartner(Partner.a),
      b: forPartner(Partner.b),
    );
  }

  static CalendarData calendar(
    int year,
    List<SexualActivity> activities,
    List<Masturbation> masturbations,
  ) {
    final days = <DateOnly, DayCount>{};
    for (final x in activities) {
      if (x.date.year != year) continue;
      final d = days[x.date] ?? const DayCount();
      days[x.date] = DayCount(
        activities: d.activities + 1,
        masturbations: d.masturbations,
      );
    }
    for (final m in masturbations) {
      if (m.date.year != year) continue;
      final d = days[m.date] ?? const DayCount();
      days[m.date] = DayCount(
        activities: d.activities,
        masturbations: d.masturbations + 1,
      );
    }
    return CalendarData(year: year, days: Map.unmodifiable(days));
  }

  static YearStats yearStats(
    int year,
    List<SexualActivity> activities,
    List<Masturbation> masturbations,
  ) => YearStats(
    year: year,
    monthlySex: monthlySex(activities),
    monthlyOrgasms: monthlyOrgasms(
      activities,
      masturbations,
    ).map((p) => p.total).toList(),
  );
}
