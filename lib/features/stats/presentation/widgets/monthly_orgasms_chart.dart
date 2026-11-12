import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../profile/domain/partner_profile.dart';
import '../../domain/stats_models.dart';
import 'chart_card.dart';
import 'chart_style.dart';

/// Line chart with area: orgasms per month, one series per partner.
class MonthlyOrgasmsChart extends StatelessWidget {
  const MonthlyOrgasmsChart({
    super.key,
    required this.year,
    required this.months,
    required this.profile,
  });

  final int year;
  final List<PartnerPair> months;
  final PartnerProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final maxY = months.fold<int>(0, (m, p) => math.max(m, math.max(p.a, p.b)));
    final nameA = profile.nameOf(Partner.a);
    final nameB = profile.nameOf(Partner.b);

    var bestMonth = 0;
    for (var i = 1; i < 12; i++) {
      if (months[i].total > months[bestMonth].total) bestMonth = i;
    }
    final description = maxY == 0
        ? 'Orgasmi per mese: nessun dato.'
        : 'Orgasmi per mese. Mese migliore ${Formatters.monthLong(bestMonth + 1)} '
              'con ${months[bestMonth].a} per $nameA e ${months[bestMonth].b} per $nameB.';

    LineChartBarData series(Partner p) {
      final color = colors.partner(p);
      return LineChartBarData(
        spots: [
          for (var i = 0; i < 12; i++)
            i < ChartStyle.lastMonth(year)
                ? FlSpot(i.toDouble(), months[i].of(p).toDouble())
                : FlSpot.nullSpot,
        ],
        isCurved: true,
        preventCurveOverShooting: true,
        color: color,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: ChartStyle.area(color),
      );
    }

    return ChartCard(
      title: 'Orgasmi per mese',
      subtitle: 'Attività e masturbazioni',
      semanticsLabel: description,
      legend: ChartLegend(
        items: [
          LegendItem(nameA, colors.partnerA),
          LegendItem(nameB, colors.partnerB),
        ],
      ),
      child: SizedBox(
        height: 220,
        child: LineChart(
          duration: ChartStyle.duration(context),
          LineChartData(
            minX: 0,
            maxX: 11,
            minY: 0,
            maxY: ChartStyle.niceMax(maxY, ChartStyle.intInterval(maxY)),
            gridData: ChartStyle.grid(context),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: ChartStyle.monthAxis(context),
              leftTitles: ChartStyle.leftAxis(
                context,
                interval: ChartStyle.intInterval(maxY),
              ),
              topTitles: ChartStyle.hidden,
              rightTitles: ChartStyle.hidden,
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => ChartStyle.tooltipColor(context),
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    LineTooltipItem(
                      '${s.barIndex == 0 ? '${Formatters.monthLong(s.x.toInt() + 1)}\n' : ''}'
                      '${s.barIndex == 0 ? nameA : nameB}: ${s.y.toInt()}',
                      ChartStyle.tooltipText(
                        context,
                        s.bar.color ?? Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            lineBarsData: [series(Partner.a), series(Partner.b)],
          ),
        ),
      ),
    );
  }
}
