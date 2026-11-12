import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/app_page.dart';
import '../../../shared/widgets/partner_split.dart';
import '../../../shared/widgets/tiles.dart';
import '../../../shared/widgets/year_selector.dart';
import '../../activities/presentation/activities_providers.dart';
import '../../masturbations/presentation/masturbations_providers.dart';
import '../../profile/domain/partner_profile.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../settings/data/year_preference.dart';
import '../../stats/domain/stats_models.dart';
import '../../stats/presentation/stats_providers.dart';

/// Year summary: "scopate", total orgasms per partner, quick actions.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static Future<void> refreshYear(WidgetRef ref, int year) async {
    await Future.wait([
      ref.refresh(activitiesProvider(year).future),
      ref.refresh(masturbationsProvider(year).future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = ref.watch(yearProvider);
    final summary = ref.watch(summaryProvider(year));
    final masturbations = ref.watch(masturbationSummaryProvider(year));
    final profile = ref.watch(requireProfileProvider);

    return AppPage(
      actions: const [YearSelector()],
      onRefresh: () => refreshYear(ref, year),
      slivers: asyncSlivers<ActivitySummary>(
        summary,
        onRetry: () => refreshYear(ref, year),
        data: (s) => [
          PageSection(
            children: [
              Text(
                'Ciao ${profile.nameOf(Partner.a)} e ${profile.nameOf(Partner.b)}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              HeroTile(
                label: 'Scopate',
                value: '${s.sexCount}',
                caption: 'su ${s.activityCount} attività nel $year',
              ),
              const SizedBox(height: 12),
              PartnerSplitTile(
                title: 'Orgasmi totali',
                caption: 'Attività + masturbazioni',
                profile: profile,
                a: s.totalOrgasms.a,
                b: s.totalOrgasms.b,
              ),
              const SizedBox(height: 12),
              ResponsivePair(
                first: MetricTile(
                  icon: Icons.balance_rounded,
                  color: context.appColors.accentInk,
                  label: 'Rapporto D/A',
                  value: Formatters.ratio(s.ratio),
                  caption: 'durante il sesso',
                ),
                second: MetricTile(
                  icon: Icons.back_hand_rounded,
                  color: context.appColors.partnerAInk,
                  label: 'Masturbazioni',
                  value: '${masturbations.value?.total ?? '–'}',
                  caption: 'nel $year',
                  onTap: () => context.go(Routes.masturbations),
                ),
              ),
              const SectionTitle('Aggiungi'),
              ResponsivePair(
                first: _QuickAdd(
                  icon: Icons.favorite_rounded,
                  label: 'Nuova attività',
                  onTap: () => context.push(Routes.newActivity),
                ),
                second: _QuickAdd(
                  icon: Icons.back_hand_rounded,
                  label: 'Nuova masturbazione',
                  onTap: () => context.push(Routes.newMasturbation),
                ),
              ),
              const SizedBox(height: 12),
              Tile(
                onTap: () => context.go(Routes.stats),
                semanticsLabel: 'Vedi tutte le statistiche',
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconBadge(
                      icon: Icons.insights_rounded,
                      color: context.appColors.accentInk,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Vedi tutte le statistiche',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: context.appColors.muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final theme = Theme.of(context);
    return Tile(
      onTap: onTap,
      semanticsLabel: label,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: c.heroGradient,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
              const Spacer(),
              Icon(icon, size: 20, color: c.muted),
            ],
          ),
          const SizedBox(height: 14),
          Text(label, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
