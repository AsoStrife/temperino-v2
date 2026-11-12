import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/app_page.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/month_grouped_list.dart';
import '../../../shared/widgets/tiles.dart';
import '../../../shared/widgets/year_selector.dart';
import '../../profile/domain/partner_profile.dart';
import '../../profile/presentation/profile_providers.dart';
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

  @override
  Widget build(BuildContext context) {
    final year = ref.watch(yearProvider);
    final activities = ref.watch(activitiesProvider(year));
    final c = context.appColors;

    Future<void> refresh() => ref.refresh(activitiesProvider(year).future);

    return AppPage(
      title: 'Attività',
      actions: const [YearSelector()],
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
                if (id != null) context.push(Routes.activity(id));
              },
              onDelete: (x) => _delete(year, x),
              rowBuilder: (context, x) => _ActivityRow(activity: x),
            ),
          ];
        },
      ),
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
