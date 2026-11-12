import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/formatters.dart';

/// Shared fl_chart styling helpers.
abstract final class ChartStyle {
  static const animation = Duration(milliseconds: 350);

  static Duration duration(BuildContext context) => context.motion(animation);

  /// Month initials on the bottom axis (x = 0..11).
  static AxisTitles monthAxis(BuildContext context) => AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      interval: 1,
      reservedSize: 28,
      getTitlesWidget: (value, meta) {
        final i = value.round();
        if (i < 0 || i > 11 || value != i.toDouble()) {
          return const SizedBox.shrink();
        }
        return SideTitleWidget(
          meta: meta,
          child: Text(
            Formatters.monthShort(i + 1).substring(0, 1),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        );
      },
    ),
  );

  static AxisTitles leftAxis(BuildContext context, {double? interval}) =>
      AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          interval: interval,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(
              Formatters.axis(value),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      );

  static const hidden = AxisTitles(sideTitles: SideTitles(showTitles: false));

  static FlGridData grid(BuildContext context) => FlGridData(
    drawVerticalLine: false,
    getDrawingHorizontalLine: (_) => FlLine(
      color: context.appColors.hairline,
      strokeWidth: 1,
      dashArray: const [4, 4],
    ),
  );

  /// Vertical fade under a line series.
  static BarAreaData area(Color color) => BarAreaData(
    show: true,
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
    ),
  );

  static Color tooltipColor(BuildContext context) =>
      Theme.of(context).colorScheme.inverseSurface;

  static TextStyle tooltipText(BuildContext context, Color color) =>
      TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12);

  /// Top of the y axis: a multiple of [interval] above [max], so that no
  /// extra label with a decimal value is drawn at the top.
  static double niceMax(num max, double interval) =>
      max <= 0 ? interval : ((max * 1.05) / interval).ceil() * interval;

  /// Last month (1-12) that can contain data for [year]: future months of
  /// the current year are not drawn.
  static int lastMonth(int year) {
    final now = DateTime.now();
    return year == now.year ? now.month : 12;
  }

  /// Nice integer step for a y axis with max value [max].
  static double intInterval(num max) {
    if (max <= 5) return 1;
    if (max <= 10) return 2;
    if (max <= 25) return 5;
    if (max <= 50) return 10;
    return (max / 5).ceilToDouble();
  }
}
