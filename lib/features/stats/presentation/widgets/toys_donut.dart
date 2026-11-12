import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../profile/domain/partner_profile.dart';
import '../../domain/stats_models.dart';
import 'chart_card.dart';
import 'chart_style.dart';

/// Donut: share of masturbations with toys, per partner. The center shows
/// the total with toys over the total.
class ToysDonut extends StatelessWidget {
  const ToysDonut({super.key, required this.summary, required this.profile});

  final MasturbationSummary summary;
  final PartnerProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final total = summary.total;
    final withToys = summary.totalWithToys;
    final nameA = profile.nameOf(Partner.a);
    final nameB = profile.nameOf(Partner.b);

    PieChartSectionData section(int value, Color color) => PieChartSectionData(
      value: value.toDouble(),
      color: color,
      radius: 28,
      showTitle: false,
    );

    final sections = [
      if (summary.a.withToys > 0) section(summary.a.withToys, colors.partnerA),
      if (summary.a.withoutToys > 0)
        section(summary.a.withoutToys, colors.partnerA.withValues(alpha: 0.35)),
      if (summary.b.withToys > 0) section(summary.b.withToys, colors.partnerB),
      if (summary.b.withoutToys > 0)
        section(summary.b.withoutToys, colors.partnerB.withValues(alpha: 0.35)),
    ];

    return ChartCard(
      title: 'Masturbazioni con giocattoli',
      subtitle: 'Colore pieno: con giocattoli. Chiaro: senza.',
      semanticsLabel:
          'Masturbazioni con giocattoli: $withToys su $total. '
          '$nameA ${summary.a.withToys} su ${summary.a.count}, '
          '$nameB ${summary.b.withToys} su ${summary.b.count}.',
      legend: ChartLegend(
        items: [
          LegendItem('$nameA con giocattoli', colors.partnerA),
          LegendItem('$nameA senza', colors.partnerA.withValues(alpha: 0.35)),
          LegendItem('$nameB con giocattoli', colors.partnerB),
          LegendItem('$nameB senza', colors.partnerB.withValues(alpha: 0.35)),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: total == 0
            ? Center(
                child: Text('Nessun dato', style: theme.textTheme.bodyMedium),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    duration: ChartStyle.duration(context),
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 64,
                      sectionsSpace: 2,
                      startDegreeOffset: -90,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$withToys/$total',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text('con giocattoli', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
