import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/date_only.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_page.dart';
import '../../../shared/widgets/day_events_sheet.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/event_calendar.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/heart_mark.dart';
import '../../../shared/widgets/layout_toggle.dart';
import '../../../shared/widgets/month_grouped_list.dart';
import '../../../shared/widgets/partner_avatar.dart';
import '../../../shared/widgets/tiles.dart';
import '../../../shared/widgets/year_selector.dart';
import '../../calendar/domain/day_events.dart';
import '../../calendar/presentation/calendar_providers.dart';
import '../../profile/domain/partner_profile.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../settings/data/layout_preference.dart';
import '../../settings/data/year_preference.dart';
import '../domain/masturbation.dart';
import 'masturbations_providers.dart';

class MasturbationsListScreen extends ConsumerStatefulWidget {
  const MasturbationsListScreen({super.key});

  @override
  ConsumerState<MasturbationsListScreen> createState() =>
      _MasturbationsListScreenState();
}

class _MasturbationsListScreenState
    extends ConsumerState<MasturbationsListScreen> {
  final _hidden = <int>{};

  final _calendarKey = GlobalKey<SliverEventCalendarState>();

  Future<void> _delete(int year, Masturbation item) async {
    final id = item.id;
    if (id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _hidden.add(id));
    try {
      await ref.read(masturbationsProvider(year).notifier).remove(id);
      showInfoSnack(messenger, 'Masturbazione cancellata');
    } catch (e) {
      showErrorSnack(messenger, 'Cancellazione non riuscita', e);
    } finally {
      if (mounted) setState(() => _hidden.remove(id));
    }
  }

  Future<void> _refreshAllYears() async {
    await Future.wait([
      for (final y in selectableYears())
        ref.refresh(masturbationsProvider(y).future),
    ]);
  }

  Future<void> _openDay(DateOnly day, List<Masturbation> items) async {
    if (items.isEmpty) return;
    final Masturbation? picked;
    if (items.length == 1) {
      picked = items.first;
    } else {
      picked = await showDayEventsSheet<Masturbation>(
        context,
        date: day,
        subtitle: '${items.length} masturbazioni',
        items: items,
        rowBuilder: (context, m) => _MasturbationRow(item: m),
      );
    }
    final id = picked?.id;
    if (id == null || !mounted) return;
    await context.push(Routes.masturbation(id, year: day.year));
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
      return AppPage(
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
        bottom: const CalendarWeekdayHeader(),
        onRefresh: _refreshAllYears,
        slivers: _calendarSlivers(context, year),
      );
    }

    final list = ref.watch(masturbationsProvider(year));
    final profile = ref.watch(requireProfileProvider);
    final c = context.appColors;

    Future<void> refresh() => ref.refresh(masturbationsProvider(year).future);

    return AppPage(
      actions: const [ListLayoutToggle(), SizedBox(width: 8), YearSelector()],
      onRefresh: refresh,
      slivers: asyncSlivers<List<Masturbation>>(
        list,
        onRetry: refresh,
        data: (all) {
          final items = all
              .where((m) => m.id == null || !_hidden.contains(m.id))
              .toList();
          if (items.isEmpty) {
            return [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.back_hand_outlined,
                  title: 'Ancora niente',
                  message: 'Non sono presenti masturbazioni',
                  actionLabel: 'Aggiungi masturbazione',
                  onAction: () => context.push(Routes.newMasturbation),
                ),
              ),
            ];
          }
          return [
            SummaryPills(
              pills: [
                Pill(label: '${items.length} totali'),
                for (final p in Partner.values)
                  Pill(
                    label:
                        '${profile.nameOf(p)} '
                        '${items.where((m) => m.who == p).length}',
                    color: c.partnerInk(p),
                  ),
              ],
            ),
            SliverMonthGroups<Masturbation>(
              groups: groupByMonth(items, (m) => m.date),
              keyOf: (m) => m.id ?? m.hashCode,
              deleteTitle: 'Cancellare la masturbazione?',
              onTap: (m) {
                final id = m.id;
                if (id != null) {
                  context.push(Routes.masturbation(id, year: year));
                }
              },
              onDelete: (m) => _delete(year, m),
              rowBuilder: (context, m) => _MasturbationRow(item: m),
            ),
          ];
        },
      ),
    );
  }

  List<Widget> _calendarSlivers(BuildContext context, int year) {
    final profile = ref.watch(requireProfileProvider);
    final c = context.appColors;
    final today = DateOnly.today();
    return asyncSlivers<Map<DateOnly, MasturbationDay>>(
      ref.watch(masturbationDaysProvider),
      onRetry: _refreshAllYears,
      data: (days) => [
        _HeartLegend(profile: profile),
        if (days.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.back_hand_outlined,
              message: 'Non sono presenti masturbazioni',
              actionLabel: 'Aggiungi masturbazione',
              onAction: () => context.push(Routes.newMasturbation),
            ),
          ),
        SliverEventCalendar(
          key: _calendarKey,
          months: calendarMonths(today),
          today: today,
          initialMonth: CalendarDays.focusMonthOf(year, today),
          dayOf: (d) {
            final day = days[d];
            if (day == null) return null;
            final heart = day.heart;
            final right = heart.right;
            final names = {for (final m in day.items) profile.nameOf(m.who)}
                .join(' e ');
            final n = day.items.length;
            return CalendarDay(
              count: n,
              marker: HeartMark(
                left: c.gender(heart.left),
                right: right == null ? null : c.gender(right),
              ),
              description: n == 1
                  ? '1 masturbazione: $names'
                  : '$n masturbazioni: $names',
            );
          },
          onDayTap: (d) => _openDay(d, days[d]?.items ?? const []),
        ),
      ],
    );
  }
}

/// Legend of the heart colors: one heart per partner in the color of their
/// gender, plus the two-color heart.
class _HeartLegend extends StatelessWidget {
  const _HeartLegend({required this.profile});

  final PartnerProfile profile;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    final style = theme.textTheme.labelLarge?.copyWith(color: c.muted);
    Widget item(Widget heart, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        heart,
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );
    final nameA = profile.nameOf(Partner.a);
    final nameB = profile.nameOf(Partner.b);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Semantics(
          container: true,
          label:
              'Legenda: un cuore per $nameA, uno per $nameB, '
              'a due colori se entrambi',
          excludeSemantics: true,
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final p in Partner.values)
                item(
                  HeartMark(left: c.gender(profile.of(p).gender)),
                  profile.nameOf(p),
                ),
              item(
                HeartMark(
                  left: c.gender(profile.of(Partner.a).gender),
                  right: c.gender(profile.of(Partner.b).gender),
                ),
                'Entrambi',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasturbationRow extends ConsumerWidget {
  const _MasturbationRow({required this.item});

  final Masturbation item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(requireProfileProvider);
    final theme = Theme.of(context);
    final c = context.appColors;
    final name = profile.nameOf(item.who);

    return Semantics(
      button: true,
      label:
          '$name, ${Formatters.date(item.date)}'
          '${item.toys ? ', con giocattoli' : ''}, ${item.orgasms} orgasmi',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
        child: Row(
          children: [
            DayBadge(date: item.date),
            const SizedBox(width: 12),
            PartnerAvatar(partner: item.who, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: c.partnerInk(item.who),
                    ),
                  ),
                  if (item.toys) ...[
                    const SizedBox(height: 4),
                    const Pill(
                      label: 'Giocattoli',
                      icon: Icons.vibration_rounded,
                    ),
                  ],
                ],
              ),
            ),
            CountBubble(
              value: item.orgasms,
              color: c.partner(item.who),
              textColor: c.partnerInk(item.who),
            ),
          ],
        ),
      ),
    );
  }
}
