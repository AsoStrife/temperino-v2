import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/date_only.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/stats_models.dart';
import 'chart_card.dart';

/// Year heatmap: one row per month, one cell per day. Color intensity is the
/// number of activities + masturbations of the day. Tap a cell to see the
/// counters of that day.
class CalendarHeatmap extends StatefulWidget {
  const CalendarHeatmap({super.key, required this.data});

  final CalendarData data;

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  DateOnly? _selected;

  static const _labelWidth = 22.0;
  static const _gap = 2.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.data;
    final activeDays = data.days.values.where((d) => d.total > 0).length;
    final selected = _selected;
    final selectedCount = selected == null ? null : data.of(selected);

    return ChartCard(
      title: 'Calendario ${data.year}',
      subtitle: 'Tocca un giorno per vedere il dettaglio',
      semanticsLabel:
          'Calendario ${data.year}: $activeDays giorni con almeno un evento.',
      legend: Text(
        selected == null
            ? '$activeDays giorni con almeno un evento'
            : '${Formatters.dayMonth(selected)}: '
                  '${selectedCount!.activities} attività, '
                  '${selectedCount.masturbations} masturbazioni',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cell = math.min(
            16.0,
            (constraints.maxWidth - _labelWidth) / 31 - _gap,
          );
          final height = 12 * (cell + _gap);
          return GestureDetector(
            onTapUp: (details) {
              final p = details.localPosition;
              final col = ((p.dx - _labelWidth) / (cell + _gap)).floor();
              final row = (p.dy / (cell + _gap)).floor();
              if (col < 0 || col > 30 || row < 0 || row > 11) return;
              final month = row + 1;
              final day = col + 1;
              if (day > DateUtils.getDaysInMonth(data.year, month)) return;
              setState(() => _selected = DateOnly(data.year, month, day));
            },
            child: CustomPaint(
              size: Size(constraints.maxWidth, height),
              painter: _HeatmapPainter(
                data: data,
                cell: cell,
                gap: _gap,
                labelWidth: _labelWidth,
                selected: _selected,
                empty: context.appColors.tileHigh,
                hot: context.appColors.accent,
                outline: theme.colorScheme.onSurface,
                labelStyle: theme.textTheme.labelSmall!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.data,
    required this.cell,
    required this.gap,
    required this.labelWidth,
    required this.selected,
    required this.empty,
    required this.hot,
    required this.outline,
    required this.labelStyle,
  });

  final CalendarData data;
  final double cell;
  final double gap;
  final double labelWidth;
  final DateOnly? selected;
  final Color empty;
  final Color hot;
  final Color outline;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final max = math.max(1, data.maxTotal);
    final paint = Paint();
    final radius = Radius.circular(cell / 4);

    for (var month = 1; month <= 12; month++) {
      final y = (month - 1) * (cell + gap);

      final label = TextPainter(
        text: TextSpan(
          text: Formatters.monthShort(month).substring(0, 1),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      )..layout();
      label.paint(canvas, Offset(0, y + (cell - label.height) / 2));

      final days = DateUtils.getDaysInMonth(data.year, month);
      for (var day = 1; day <= days; day++) {
        final date = DateOnly(data.year, month, day);
        final total = data.of(date).total;
        paint.color = total == 0
            ? empty
            : Color.lerp(hot.withValues(alpha: 0.35), hot, total / max)!;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(labelWidth + (day - 1) * (cell + gap), y, cell, cell),
          radius,
        );
        canvas.drawRRect(rect, paint);
        if (date == selected) {
          canvas.drawRRect(
            rect,
            Paint()
              ..color = outline
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.data != data ||
      old.cell != cell ||
      old.selected != selected ||
      old.empty != empty ||
      old.hot != hot;
}
