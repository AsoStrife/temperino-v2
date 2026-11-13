import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../core/utils/date_only.dart';
import '../../core/utils/formatters.dart';
import '../../features/calendar/domain/day_events.dart';
import 'adaptive.dart';
import 'app_page.dart';
import 'tiles.dart';

/// What the calendar shows on a day with events.
class CalendarDay {
  const CalendarDay({
    required this.count,
    required this.marker,
    required this.description,
  });

  /// Number of records of the day (summed in the month header).
  final int count;

  /// Drawn under the day number (a `HeartMark`).
  final Widget marker;

  /// Read by TalkBack after the date, e.g. "2 attività".
  final String description;
}

/// Vertical calendar for a `CustomScrollView` (period-tracker style): one
/// month per item, newest at the top, days with events marked and tappable.
///
/// On wide pages (tablets) the months are laid out in a grid of 2 or 3
/// columns ([columnsFor]); each month then has its own weekday row and six
/// week rows, so that the months of a row have the same height.
///
/// Items (months, or rows of months) have an exact height
/// (`SliverVariedExtentList`), so the calendar can jump to any month with
/// [SliverEventCalendarState.showMonth] even if it was never built.
class SliverEventCalendar extends StatefulWidget {
  const SliverEventCalendar({
    super.key,
    required this.months,
    required this.today,
    required this.dayOf,
    required this.onDayTap,
    this.initialMonth,
  });

  /// Horizontal page margin of the calendar on phones. Smaller than the
  /// usual 16 so a day cell is at least 48 dp wide on a 360 dp phone.
  static const gutter = 12.0;

  /// Horizontal gap between the months of a grid row.
  static const monthGap = 16.0;

  /// Minimum width of a month in the grid.
  static const monthMinWidth = 340.0;

  /// Horizontal inset of the calendar on a page [width].
  static double insetFor(double width) => width < AppLayout.mediumWidth
      ? gutter
      : AppLayout.sideInset(width, AppLayout.wideWidth);

  /// Months per row on a page [width]: 1 on phones, 2 on a tablet in
  /// portrait, 3 in landscape. Fewer with big text.
  static int columnsFor(double width, {double textScale = 1}) =>
      width < AppLayout.mediumWidth
      ? 1
      : AppLayout.columns(
          width - 2 * insetFor(width),
          minWidth: monthMinWidth,
          max: 3,
          scale: textScale,
          gap: monthGap,
        );

  /// Months to show, newest first.
  final List<CalendarMonth> months;
  final DateOnly today;

  /// Events of a day, `null` when there are none.
  final CalendarDay? Function(DateOnly day) dayOf;
  final ValueChanged<DateOnly> onDayTap;

  /// Month shown when the calendar appears (no animation). `null` or the
  /// first month keeps the top of the page.
  final CalendarMonth? initialMonth;

  @override
  State<SliverEventCalendar> createState() => SliverEventCalendarState();
}

class SliverEventCalendarState extends State<SliverEventCalendar> {
  _Metrics? _metrics;
  var _columns = 1;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMonth;
    if (initial != null && initial != widget.months.firstOrNull) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showMonth(initial, animate: false);
      });
    }
  }

  /// Scrolls so that [month] is right under the pinned app bar.
  void showMonth(CalendarMonth month, {bool animate = true}) {
    final metrics = _metrics;
    final index = widget.months.indexOf(month);
    final sliver = context.findRenderObject();
    final position = Scrollable.maybeOf(context)?.position;
    if (metrics == null ||
        index < 0 ||
        sliver is! RenderSliver ||
        !sliver.attached ||
        position == null) {
      return;
    }
    // Item of the month: the month itself, or its row in the grid.
    final item = index ~/ _columns;
    var offset = 0.0;
    if (item > 0) {
      offset = sliver.constraints.precedingScrollExtent - _pinnedExtent();
      for (var i = 0; i < item; i++) {
        offset += metrics.itemExtent(widget.months, i, _columns);
      }
    }
    offset = offset.clamp(position.minScrollExtent, position.maxScrollExtent);
    final duration = context.motion(const Duration(milliseconds: 450));
    if (!animate || duration == Duration.zero) {
      position.jumpTo(offset);
    } else {
      position.animateTo(
        offset,
        duration: duration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Height of the pinned `AppPage` bar: status bar + toolbar +
  /// [CalendarWeekdayHeader] (only with one column).
  double _pinnedExtent() =>
      MediaQuery.paddingOf(context).top +
      AppPage.barHeight(
        hasActions: true,
        bottomHeight: _columns == 1 ? CalendarWeekdayHeader.height : 0,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns = SliverEventCalendar.columnsFor(
          width,
          textScale: scaler.scale(1),
        );
        final inset = SliverEventCalendar.insetFor(width);
        final monthWidth =
            (width - 2 * inset - (columns - 1) * SliverEventCalendar.monthGap) /
            columns;
        final metrics = _Metrics(theme, scaler, monthWidth, grid: columns > 1);
        _metrics = metrics;
        _columns = columns;
        final months = widget.months;
        final items = (months.length / columns).ceil();

        Widget month(int i) => _MonthView(
          month: months[i],
          metrics: metrics,
          today: widget.today,
          dayOf: widget.dayOf,
          onDayTap: widget.onDayTap,
        );

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: inset),
          sliver: SliverVariedExtentList.builder(
            itemCount: items,
            itemExtentBuilder: (i, _) =>
                i < items ? metrics.itemExtent(months, i, columns) : null,
            itemBuilder: (context, i) => columns == 1
                ? month(i)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var c = 0; c < columns; c++) ...[
                        if (c > 0)
                          const SizedBox(width: SliverEventCalendar.monthGap),
                        Expanded(
                          child: i * columns + c < months.length
                              ? month(i * columns + c)
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// Row of weekday initials (L M M G V S D), pinned as the `bottom` of the
/// app bar while the calendar is shown.
class CalendarWeekdayHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const CalendarWeekdayHeader({super.key});

  static const height = 36.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, box) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SliverEventCalendar.insetFor(box.maxWidth),
            ),
            child: const _WeekdayInitials(),
          ),
        ),
      ),
    );
  }
}

/// L M M G V S D, one per column of the month grid.
class _WeekdayInitials extends StatelessWidget {
  const _WeekdayInitials();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: context.appColors.muted);
    return Row(
      children: [
        for (var d = DateTime.monday; d <= DateTime.sunday; d++)
          Expanded(
            child: Center(
              child: Text(
                Formatters.weekdayNarrow(d),
                style: style,
                maxLines: 1,
                // The row has a fixed height: cap the scale.
                textScaler: MediaQuery.textScalerOf(context)
                    .clamp(maxScaleFactor: 1.6),
              ),
            ),
          ),
      ],
    );
  }
}

/// Sizes that depend on width and text scale. Every height is computed here
/// so that the item extents and the built months always match.
class _Metrics {
  factory _Metrics(
    ThemeData theme,
    TextScaler scaler,
    double width, {
    bool grid = false,
  }) {
    final titleSize = theme.textTheme.titleMedium?.fontSize ?? 16;
    final numberSize = theme.textTheme.bodyMedium?.fontSize ?? 14;
    final titleLine = scaler.scale(titleSize) * titleHeight;
    final numberLine = scaler.scale(numberSize) * numberHeight;
    final numberBox = math.max(30.0, numberLine + 8);
    final content = numberBox + markerGap + markerSize + 6;
    final cellWidth = width / 7;
    final row = math.max(math.max(48.0, math.min(cellWidth, 60.0)), content);
    return _Metrics._(
      headerExtent: headerTop + titleLine + headerBottom,
      rowExtent: row,
      numberBox: numberBox,
      weekdayExtent: grid ? weekdayRow : 0,
      fixedRows: grid ? 6 : null,
    );
  }

  const _Metrics._({
    required this.headerExtent,
    required this.rowExtent,
    required this.numberBox,
    required this.weekdayExtent,
    required this.fixedRows,
  });

  static const titleHeight = 1.5;
  static const numberHeight = 1.2;
  static const headerTop = 20.0;
  static const headerBottom = 8.0;
  static const gridPadding = 6.0;
  static const markerSize = 16.0;
  static const markerGap = 2.0;

  /// Weekday row inside each month of the grid.
  static const weekdayRow = 32.0;

  final double headerExtent;
  final double rowExtent;

  /// Side of the (round) box of the day number.
  final double numberBox;

  /// Height of the weekday row inside the month (grid only, else 0).
  final double weekdayExtent;

  /// Week rows of every month in the grid (6, so months of a row align);
  /// `null` for the real number of weeks.
  final int? fixedRows;

  int rowsOf(CalendarMonth m) =>
      fixedRows ?? CalendarDays.weekRows(m.year, m.month);

  double monthExtent(CalendarMonth m) =>
      headerExtent + 2 * gridPadding + weekdayExtent + rowsOf(m) * rowExtent;

  /// Height of item [i]: a month, or a row of [columns] months (all with
  /// the same height in the grid).
  double itemExtent(List<CalendarMonth> months, int i, int columns) =>
      monthExtent(months[i * columns]);
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.month,
    required this.metrics,
    required this.today,
    required this.dayOf,
    required this.onDayTap,
  });

  final CalendarMonth month;
  final _Metrics metrics;
  final DateOnly today;
  final CalendarDay? Function(DateOnly day) dayOf;
  final ValueChanged<DateOnly> onDayTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final (:year, month: m) = month;
    final blanks = CalendarDays.leadingBlanks(year, m);
    final days = CalendarDays.daysInMonth(year, m);
    final rows = metrics.rowsOf(month);
    final infos = <int, CalendarDay>{
      for (var d = 1; d <= days; d++) d: ?dayOf(DateOnly(year, m, d)),
    };
    final count = infos.values.fold(0, (sum, i) => sum + i.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: metrics.headerExtent,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              4,
              _Metrics.headerTop,
              4,
              _Metrics.headerBottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      Formatters.monthYear(year, m),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        height: _Metrics.titleHeight,
                      ),
                    ),
                  ),
                ),
                if (count > 0)
                  Text(
                    '$count',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: c.muted,
                      fontFeatures: tabularFigures,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Tile(
          padding: const EdgeInsets.symmetric(vertical: _Metrics.gridPadding),
          child: Column(
            children: [
              if (metrics.weekdayExtent > 0)
                SizedBox(
                  height: metrics.weekdayExtent,
                  child: const ExcludeSemantics(child: _WeekdayInitials()),
                ),
              for (var r = 0; r < rows; r++)
                SizedBox(
                  height: metrics.rowExtent,
                  child: Row(
                    children: [
                      for (var col = 0; col < 7; col++)
                        Expanded(
                          child: switch (r * 7 + col - blanks + 1) {
                            final d when d >= 1 && d <= days => _DayCell(
                              date: DateOnly(year, m, d),
                              info: infos[d],
                              today: today,
                              metrics: metrics,
                              onTap: onDayTap,
                            ),
                            _ => const SizedBox.shrink(),
                          },
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.info,
    required this.today,
    required this.metrics,
    required this.onTap,
  });

  final DateOnly date;
  final CalendarDay? info;
  final DateOnly today;
  final _Metrics metrics;
  final ValueChanged<DateOnly> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final info = this.info;
    final isToday = date == today;
    final isFuture = date.isAfter(today);

    final number = Container(
      width: metrics.numberBox,
      height: metrics.numberBox,
      alignment: Alignment.center,
      decoration: isToday
          ? BoxDecoration(color: c.accentSoft, shape: BoxShape.circle)
          : null,
      child: Text(
        '${date.day}',
        maxLines: 1,
        softWrap: false,
        style: theme.textTheme.bodyMedium?.copyWith(
          height: _Metrics.numberHeight,
          fontFeatures: tabularFigures,
          fontWeight: info != null || isToday ? FontWeight.w700 : null,
          color: isToday ? c.accentInk : (isFuture ? c.muted : null),
        ),
      ),
    );

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        number,
        const SizedBox(height: _Metrics.markerGap),
        SizedBox(
          height: _Metrics.markerSize,
          child: info == null ? null : Center(child: info.marker),
        ),
      ],
    );

    final label = [
      Formatters.dateLong(date),
      if (isToday) 'oggi',
      if (info != null) info.description,
    ].join(', ');

    return Semantics(
      button: info != null,
      label: label,
      excludeSemantics: true,
      child: info == null
          ? content
          : InkWell(
              borderRadius: BorderRadius.circular(AppRadii.inner),
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(date);
              },
              child: content,
            ),
    );
  }
}
