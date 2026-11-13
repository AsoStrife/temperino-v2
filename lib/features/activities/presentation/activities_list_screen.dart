import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/date_only.dart';
import '../../../shared/widgets/adaptive.dart';
import '../../../shared/widgets/app_page.dart';
import '../../../shared/widgets/day_events_sheet.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/event_calendar.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/heart_mark.dart';
import '../../../shared/widgets/layout_toggle.dart';
import '../../../shared/widgets/month_grouped_list.dart';
import '../../../shared/widgets/tiles.dart';
import '../../../shared/widgets/year_selector.dart';
import '../../calendar/domain/day_events.dart';
import '../../calendar/presentation/calendar_providers.dart';
import '../../profile/domain/partner_profile.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../settings/data/layout_preference.dart';
import '../../settings/data/year_preference.dart';
import '../domain/sexual_activity.dart';
import 'activities_providers.dart';
import 'practice_icons.dart';

class ActivitiesListScreen extends ConsumerStatefulWidget {
  const ActivitiesListScreen({super.key});

  @override
  ConsumerState<ActivitiesListScreen> createState() =>
      _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends ConsumerState<ActivitiesListScreen> {
  /// Ids swiped away while the delete request is running: hidden so the
  /// dismissed row leaves the tree immediately.
  final _hidden = <int>{};

  final _calendarKey = GlobalKey<SliverEventCalendarState>();

  Future<void> _delete(int year, SexualActivity item) async {
    final id = item.id;
    if (id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _hidden.add(id));
    try {
      await ref.read(activitiesProvider(year).notifier).remove(id);
      showInfoSnack(messenger, 'Attività cancellata');
    } catch (e) {
      showErrorSnack(messenger, 'Cancellazione non riuscita', e);
    } finally {
      if (mounted) setState(() => _hidden.remove(id));
    }
  }

  Future<void> _refreshAllYears() async {
    await Future.wait([
      for (final y in selectableYears())
        ref.refresh(activitiesProvider(y).future),
    ]);
  }

  Future<void> _openDay(DateOnly day, List<SexualActivity> items) async {
    if (items.isEmpty) return;
    final SexualActivity? picked;
    if (items.length == 1) {
      picked = items.first;
    } else {
      picked = await showDayEventsSheet<SexualActivity>(
        context,
        date: day,
        subtitle: '${items.length} attività',
        items: items,
        rowBuilder: (context, x) => _ActivityRow(activity: x),
      );
    }
    final id = picked?.id;
    if (id == null || !mounted) return;
    await context.push(Routes.activity(id, year: day.year));
  }

  Future<void> _showToday() async {
    final today = DateOnly.today();
    _calendarKey.currentState?.showMonth(
      CalendarDays.focusMonthOf(today.year, today),
    );
    await ref.read(yearProvider.notifier).select(today.year);
  }

  @override
  Widget build(BuildContext context) {
    final year = ref.watch(yearProvider);
    final layout = ref.watch(listLayoutProvider);

    // In the calendar the year pill moves to that year instead of filtering.
    ref.listen<int>(yearProvider, (previous, next) {
      if (previous == next) return;
      _calendarKey.currentState?.showMonth(
        CalendarDays.focusMonthOf(next, DateOnly.today()),
      );
    });

    if (layout == ListLayout.calendar) {
      // The pinned weekday row only fits a single column of months; in the
      // tablet grid every month has its own.
      return LayoutBuilder(
        builder: (context, box) => AppPage(
          actions: [
            IconButton(
              tooltip: 'Vai a oggi',
              icon: const Icon(Icons.today_rounded),
              onPressed: _showToday,
            ),
            const ListLayoutToggle(),
            const SizedBox(width: 8),
            const YearSelector(),
          ],
          bottom:
              SliverEventCalendar.columnsFor(
                    box.maxWidth,
                    textScale: textScaleOf(context),
                  ) ==
                  1
              ? const CalendarWeekdayHeader()
              : null,
          onRefresh: _refreshAllYears,
          slivers: _calendarSlivers(context, year),
        ),
      );
    }

    final activities = ref.watch(activitiesProvider(year));
    final c = context.appColors;

    Future<void> refresh() => ref.refresh(activitiesProvider(year).future);

    return AppPage(
      actions: const [ListLayoutToggle(), SizedBox(width: 8), YearSelector()],
      onRefresh: refresh,
      slivers: asyncSlivers<List<SexualActivity>>(
        activities,
        onRetry: refresh,
        data: (all) {
          final items = all
              .where((x) => x.id == null || !_hidden.contains(x.id))
              .toList();
          if (items.isEmpty) {
            return [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.favorite_border_rounded,
                  title: 'Ancora niente',
                  message: 'Non sono presenti attività sessuali',
                  actionLabel: 'Aggiungi attività',
                  onAction: () => context.push(Routes.newActivity),
                ),
              ),
            ];
          }
          final sex = items.where((x) => x.isSex).length;
          final anal = items.where((x) => x.has(Practice.anal)).length;
          return [
            SummaryPills(
              pills: [
                Pill(label: '${items.length} attività'),
                Pill(
                  label: '$sex scopate',
                  icon: Icons.favorite_rounded,
                  color: c.accentInk,
                ),
                if (anal > 0) Pill(label: '$anal anal'),
              ],
            ),
            SliverMonthGroups<SexualActivity>(
              groups: groupByMonth(items, (x) => x.date),
              keyOf: (x) => x.id ?? x.hashCode,
              deleteTitle: 'Cancellare l\'attività?',
              onTap: (x) {
                final id = x.id;
                if (id != null) context.push(Routes.activity(id, year: year));
              },
              onDelete: (x) => _delete(year, x),
              rowBuilder: (context, x) => _ActivityRow(activity: x),
            ),
          ];
        },
      ),
    );
  }

  List<Widget> _calendarSlivers(BuildContext context, int year) {
    final c = context.appColors;
    final today = DateOnly.today();
    return asyncSlivers<Map<DateOnly, List<SexualActivity>>>(
      ref.watch(activityDaysProvider),
      onRetry: _refreshAllYears,
      data: (days) => [
        if (days.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.favorite_border_rounded,
              message: 'Non sono presenti attività sessuali',
              actionLabel: 'Aggiungi attività',
              onAction: () => context.push(Routes.newActivity),
            ),
          ),
        SliverEventCalendar(
          key: _calendarKey,
          months: calendarMonths(today),
          today: today,
          initialMonth: CalendarDays.focusMonthOf(year, today),
          dayOf: (d) {
            final items = days[d];
            if (items == null) return null;
            final sex = items.where((x) => x.isSex).length;
            return CalendarDay(
              count: items.length,
              marker: HeartMark(left: c.accent),
              description: [
                items.length == 1 ? '1 attività' : '${items.length} attività',
                if (sex > 0) sex == 1 ? '1 scopata' : '$sex scopate',
              ].join(', '),
            );
          },
          onDayTap: (d) => _openDay(d, days[d] ?? const []),
        ),
      ],
    );
  }
}

class _ActivityRow extends ConsumerWidget {
  const _ActivityRow({required this.activity});

  final SexualActivity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(requireProfileProvider);
    final theme = Theme.of(context);
    final c = context.appColors;
    final others = Practice.values
        .where(
          (p) => p != Practice.sex && p != Practice.anal && activity.has(p),
        )
        .map((p) => p.label)
        .toList();
    final noCumshot = activity.cumshot == CumshotZone.none;

    return Semantics(
      button: true,
      label: [
        activity.isSex ? 'Scopata' : 'Attività',
        if (activity.has(Practice.anal)) 'anal',
        ...others,
        'sborrata: ${activity.cumshot.label}',
        for (final p in Partner.values)
          '${profile.nameOf(p)} ${activity.orgasmsOf(p)} orgasmi',
      ].join(', '),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
        child: Row(
          children: [
            DayBadge(date: activity.date),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (activity.isSex)
                        Pill(
                          label: 'Scopata',
                          icon: Icons.favorite_rounded,
                          color: c.accentInk,
                        ),
                      if (activity.has(Practice.anal))
                        Pill(
                          label: Practice.anal.label,
                          icon: practiceIcon(Practice.anal),
                        ),
                      if (!activity.isSex && !activity.has(Practice.anal))
                        Text(
                          others.isEmpty ? 'Attività' : others.join(' · '),
                          style: theme.textTheme.titleSmall,
                        ),
                    ],
                  ),
                  if ((activity.isSex || activity.has(Practice.anal)) &&
                      others.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      others.join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: c.muted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        size: 14,
                        color: noCumshot ? c.muted : c.accentInk,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          noCumshot
                              ? 'Nessuna sborrata'
                              : activity.cumshot.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: c.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                for (final p in Partner.values) ...[
                  if (p == Partner.b) const SizedBox(height: 4),
                  CountBubble(
                    value: activity.orgasmsOf(p),
                    color: c.partner(p),
                    textColor: c.partnerInk(p),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
