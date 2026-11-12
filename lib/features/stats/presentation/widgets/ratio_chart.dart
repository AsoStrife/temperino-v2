import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';
import 'chart_card.dart';
import 'chart_style.dart';

/// D/A ratio per month with a reference line at 1.0. Months without data
/// are not drawn (null spots break the line).
class RatioChart extends StatelessWidget {
  const RatioChart({super.key, required this.ratios, required this.title});

  final List<double?> ratios;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final values = ratios.whereType<double>().toList();
    final maxY = ChartStyle.niceMax(
      math.max(2.0, values.isEmpty ? 0 : values.reduce(math.max)),
      0.5,
    );
    final avg = values.isEmpty
        ? null
        : values.reduce((a, b) => a + b) / values.length;

    return ChartCard(
      title: title,
      subtitle: 'Per mese, solo durante il sesso. Linea tratteggiata: 1,0',
      semanticsLabel: values.isEmpty
          ? '$title: nessun dato.'
          : '$title: media mensile ${Formatters.ratio(avg)}, '
                '${values.length} mesi con dati.',
      child: SizedBox(
        height: 200,
        child: values.isEmpty
            ? Center(
                child: Text('Nessun dato', style: theme.textTheme.bodyMedium),
              )
            : LineChart(
                duration: ChartStyle.duration(context),
                LineChartData(
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: maxY,
                  gridData: ChartStyle.grid(context),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: ChartStyle.monthAxis(context),
                    leftTitles: ChartStyle.leftAxis(context, interval: 0.5),
                    topTitles: ChartStyle.hidden,
                    rightTitles: ChartStyle.hidden,
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 1,
                        color: colors.neutral,
                        strokeWidth: 1.5,
                        dashArray: [6, 4],
                      ),
                    ],
                  ),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => ChartStyle.tooltipColor(context),
                      getTooltipItems: (spots) => [
                        for (final s in spots)
                          LineTooltipItem(
                            '${Formatters.monthLong(s.x.toInt() + 1)}: '
                            '${Formatters.ratio(s.y)}',
                            ChartStyle.tooltipText(context, colors.accent),
                          ),
                      ],
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < 12; i++)
                          ratios[i] == null
                              ? FlSpot.nullSpot
                              : FlSpot(i.toDouble(), ratios[i]!),
                      ],
                      color: colors.accent,
                      barWidth: 3,
                      isCurved: false,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
