import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_page.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/partner_avatar.dart';
import '../../../shared/widgets/partner_split.dart';
import '../../../shared/widgets/tiles.dart';
import '../../../shared/widgets/year_selector.dart';
import '../../activities/domain/sexual_activity.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/domain/partner_profile.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../settings/data/year_preference.dart';
import '../domain/stats_models.dart';
import 'stats_providers.dart';
import 'widgets/calendar_heatmap.dart';
import 'widgets/chart_card.dart';
import 'widgets/horizontal_bars.dart';
import 'widgets/monthly_orgasms_chart.dart';
import 'widgets/ratio_chart.dart';
import 'widgets/toys_donut.dart';
import 'widgets/year_comparison_chart.dart';

enum _StatsTab { activities, masturbations }

/// Statistics with two sections ("Attività" / "Masturbazioni") switched by a
/// pill segmented control pinned under the title.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  var _tab = _StatsTab.activities;

  @override
  Widget build(BuildContext context) {
    final year = ref.watch(yearProvider);
    return AppPage(
      actions: const [YearSelector()],
      onRefresh: () => HomeScreen.refreshYear(ref, year),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<_StatsTab>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: _StatsTab.activities,
                  icon: Icon(Icons.favorite_rounded),
                  label: Text('Attività'),
                ),
                ButtonSegment(
                  value: _StatsTab.masturbations,
                  icon: Icon(Icons.back_hand_rounded),
                  label: Text('Masturbazioni'),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
            ),
          ),
        ),
      ),
      slivers: _tab == _StatsTab.activities
          ? _activitySlivers(context, year)
          : _masturbationSlivers(context, year),
    );
  }

  List<Widget> _activitySlivers(BuildContext context, int year) {
    final profile = ref.watch(requireProfileProvider);
    final c = context.appColors;
    final nameB = profile.nameOf(Partner.b);

    return asyncSlivers<ActivitySummary>(
      ref.watch(summaryProvider(year)),
      onRetry: () => HomeScreen.refreshYear(ref, year),
      data: (s) {
        final practices = s.practiceCounts.entries.toList()
          ..sort((x, y) => y.value.compareTo(x.value));
        return [
          PageSection(
            children: [
              ResponsivePair(
                first: MetricTile(
                  icon: Icons.favorite_rounded,
                  color: c.accentInk,
                  label: 'Scopate',
                  value: '${s.sexCount}',
                  caption: 'su ${s.activityCount} attività',
                ),
                second: MetricTile(
                  icon: Icons.all_inclusive_rounded,
                  color: c.positive,
                  label: 'Orgasmi totali',
                  value: '${s.totalOrgasms.total}',
                  caption: 'attività + masturbazioni',
                ),
              ),
              const SizedBox(height: 12),
              PartnerSplitTile(
                title: 'Orgasmi nelle attività',
                profile: profile,
                a: s.orgasmsInActivities.a,
                b: s.orgasmsInActivities.b,
              ),
              const SizedBox(height: 12),
              PartnerSplitTile(
                title: 'Orgasmi durante il sesso',
                profile: profile,
                a: s.orgasmsDuringSex.a,
                b: s.orgasmsDuringSex.b,
              ),
              const SizedBox(height: 12),
              ResponsivePair(
                first: MetricTile(
                  icon: Icons.balance_rounded,
                  color: c.accentInk,
                  label: 'Rapporto D/A',
                  value: Formatters.ratio(s.ratio),
                  caption: 'durante il sesso',
                ),
                second: MetricTile(
                  icon: Icons.balance_rounded,
                  color: c.partnerBInk,
                  label: 'Rapporto D/A',
                  value: Formatters.ratio(s.ratioWhenBComes),
                  caption: 'quando $nameB viene',
                ),
              ),
              const SectionTitle('Andamento'),
              _Section<List<PartnerPair>>(
                value: ref.watch(monthlyProvider(year)),
                builder: (m) => MonthlyOrgasmsChart(
                  year: year,
                  months: m,
                  profile: profile,
                ),
              ),
              const SizedBox(height: 12),
              _Section<List<double?>>(
                value: ref.watch(monthlyRatioProvider(year)),
                builder: (r) =>
                    RatioChart(ratios: r, title: 'Rapporto D/A per mese'),
              ),
              const SectionTitle('Dettagli'),
              _Section<List<MapEntry<CumshotZone, int>>>(
                value: ref.watch(cumshotProvider(year)),
                builder: (zones) {
                  final top = zones.isNotEmpty && zones.first.value > 0
                      ? zones.first
                      : null;
                  return ChartCard(
                    title: 'Sborrate per zona',
                    subtitle: 'Tutte le 12 zone, dalla più frequente',
                    semanticsLabel: top == null
                        ? 'Sborrate per zona: nessun dato.'
                        : 'Sborrate per zona. La più frequente è '
                              '${top.key.label} con ${top.value}.',
                    child: HorizontalBars(
                      color: c.neutral,
                      entries: [
                        for (final z in zones)
                          BarEntry(
                            z.key.label,
                            z.value,
                            color: identical(z, top) ? c.accent : null,
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ChartCard(
                title: 'Pratiche',
                subtitle: 'Numero di attività per pratica',
                semanticsLabel:
                    'Pratiche: ${practices.map((e) => '${e.key.label} ${e.value}').join(', ')}.',
                child: HorizontalBars(
                  color: c.partnerA,
                  entries: [
                    for (final e in practices) BarEntry(e.key.label, e.value),
                  ],
                ),
              ),
              const SectionTitle('Calendario'),
              _Section<CalendarData>(
                value: ref.watch(calendarProvider(year)),
                builder: (cal) => CalendarHeatmap(data: cal),
              ),
              const SectionTitle('Negli anni'),
              _Section<List<YearStats>>(
                value: ref.watch(yearlyProvider),
                height: 260,
                builder: (y) => YearComparisonChart(years: y),
              ),
            ],
          ),
        ];
      },
    );
  }

  List<Widget> _masturbationSlivers(BuildContext context, int year) {
    final profile = ref.watch(requireProfileProvider);
    return asyncSlivers<MasturbationSummary>(
      ref.watch(masturbationSummaryProvider(year)),
      onRetry: () => HomeScreen.refreshYear(ref, year),
      data: (s) => [
        PageSection(
          children: [
            for (final p in Partner.values) ...[
              _PartnerMasturbationTile(
                partner: p,
                info: profile.of(p),
                stats: s.of(p),
              ),
              const SizedBox(height: 12),
            ],
            PartnerSplitTile(
              title: 'Chi si tocca di più',
              caption: 'Numero di masturbazioni',
              profile: profile,
              a: s.a.count,
              b: s.b.count,
            ),
            const SizedBox(height: 12),
            ToysDonut(summary: s, profile: profile),
          ],
        ),
      ],
    );
  }
}

/// Renders a block that depends on its own provider.
class _Section<T> extends StatelessWidget {
  const _Section({
    required this.value,
    required this.builder,
    this.height = 160,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final double height;

  @override
  Widget build(BuildContext context) => value.when(
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: builder,
    loading: () => Tile(child: InlineLoader(height: height)),
    error: (e, _) => Tile(child: Text(AppException.from(e).message)),
  );
}

class _PartnerMasturbationTile extends StatelessWidget {
  const _PartnerMasturbationTile({
    required this.partner,
    required this.info,
    required this.stats,
  });

  final Partner partner;
  final PartnerInfo info;
  final PartnerMasturbationStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final ink = c.partnerInk(partner);
    final label = info.gender.masturbationLabel;

    Widget metric(String value, String caption) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFeatures: tabularFigures,
            ),
          ),
          Text(
            caption,
            style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
          ),
        ],
      ),
    );

    return Tile(
      semanticsLabel:
          '${info.name}: $label ${stats.count}, con giocattoli '
          '${stats.withToys}, orgasmi ${stats.orgasms}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PartnerAvatar(partner: partner, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  info.name,
                  style: theme.textTheme.titleLarge?.copyWith(color: ink),
                ),
              ),
              Pill(label: label, color: ink),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              metric('${stats.count}', label),
              metric('${stats.withToys}', 'con giocattoli'),
              metric('${stats.orgasms}', 'orgasmi'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stats.count == 0 ? 0 : stats.withToys / stats.count,
              minHeight: 8,
              color: c.partner(partner),
              backgroundColor: c.tileHigh,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stats.count == 0
                ? 'Nessuna masturbazione'
                : '${(stats.withToys * 100 / stats.count).round()}% con giocattoli',
            style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}
