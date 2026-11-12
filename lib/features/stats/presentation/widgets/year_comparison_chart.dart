import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/stats_models.dart';
import 'chart_card.dart';
import 'chart_style.dart';

enum ComparisonMetric { sex, orgasms }

/// One line per year over the 12 months. The metric can be switched
/// between "scopate" and total orgasms.
class YearComparisonChart extends StatefulWidget {
  const YearComparisonChart({super.key, required this.years});

  final List<YearStats> years;

  @override
  State<YearComparisonChart> createState() => _YearComparisonChartState();
}

class _YearComparisonChartState extends State<YearComparisonChart> {
  var _metric = ComparisonMetric.sex;

  List<int> _values(YearStats y) =>
      _metric == ComparisonMetric.sex ? y.monthlySex : y.monthlyOrgasms;

  /// Most recent year in accent, older years fading to neutral.
  List<Color> _palette(BuildContext context, int n) {
    final colors = context.appColors;
    final base = [
      colors.accent,
      colors.partnerA,
      colors.positive,
      colors.partnerB,
      colors.warning,
    ];
    return List.generate(n, (i) {
      final fromNewest = n - 1 - i;
      return fromNewest < base.length ? base[fromNewest] : colors.neutral;
    });
  }

  @override
  Widget build(BuildContext context) {
    final years = widget.years;
    final palette = _palette(context, years.length);
    final maxY = years.fold<int>(
      0,
      (m, y) => math.max(m, _values(y).fold(0, math.max)),
    );
    final metricLabel = _metric == ComparisonMetric.sex ? 'scopate' : 'orgasmi';

    return ChartCard(
      title: 'Confronto anni',
      subtitle:
          'Andamento mensile di ${metricLabel == 'scopate' ? 'scopate' : 'orgasmi totali'}',
      semanticsLabel:
          'Confronto anni, $metricLabel: ${years.map((y) {
            final total = _metric == ComparisonMetric.sex ? y.totalSex : y.totalOrgasms;
            return '${y.year} $total';
          }).join(', ')}.',
      legend: Column(
        children: [
          ChartLegend(
            items: [
              for (var i = 0; i < years.length; i++)
                LegendItem('${years[i].year}', palette[i]),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<ComparisonMetric>(
            segments: const [
              ButtonSegment(
                value: ComparisonMetric.sex,
                label: Text('Scopate'),
              ),
              ButtonSegment(
                value: ComparisonMetric.orgasms,
                label: Text('Orgasmi'),
              ),
            ],
            selected: {_metric},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _metric = s.first),
          ),
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
                      '${years[s.barIndex].year}: ${s.y.toInt()}',
                      ChartStyle.tooltipText(context, palette[s.barIndex]),
                    ),
                ],
              ),
            ),
            lineBarsData: [
              for (var i = 0; i < years.length; i++)
                LineChartBarData(
                  spots: [
                    for (var m = 0; m < 12; m++)
                      m < ChartStyle.lastMonth(years[i].year)
                          ? FlSpot(
                              m.toDouble(),
                              _values(years[i])[m].toDouble(),
                            )
                          : FlSpot.nullSpot,
                  ],
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: palette[i],
                  barWidth: i == years.length - 1 ? 3.5 : 2,
                  isStrokeCapRound: true,
                  belowBarData: i == years.length - 1
                      ? ChartStyle.area(palette[i])
                      : BarAreaData(),
                  dotData: const FlDotData(show: false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
