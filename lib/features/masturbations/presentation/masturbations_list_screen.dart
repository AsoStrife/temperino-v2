import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_page.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/month_grouped_list.dart';
import '../../../shared/widgets/partner_avatar.dart';
import '../../../shared/widgets/tiles.dart';
import '../../../shared/widgets/year_selector.dart';
import '../../profile/domain/partner_profile.dart';
import '../../profile/presentation/profile_providers.dart';
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

  @override
  Widget build(BuildContext context) {
    final year = ref.watch(yearProvider);
    final list = ref.watch(masturbationsProvider(year));
    final profile = ref.watch(requireProfileProvider);
    final c = context.appColors;

    Future<void> refresh() => ref.refresh(masturbationsProvider(year).future);

    return AppPage(
      title: 'Masturbazioni',
      actions: const [YearSelector()],
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
                if (id != null) context.push(Routes.masturbation(id));
              },
              onDelete: (m) => _delete(year, m),
              rowBuilder: (context, m) => _MasturbationRow(item: m),
            ),
          ];
        },
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
