import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Width classes (Material 3 window size classes).
enum WidthClass { compact, medium, expanded }

/// Breakpoints, margins and max widths for phones and tablets.
///
/// Layouts depend on the available width in dp, never on the device type:
/// below [mediumWidth] every screen looks exactly like the phone layout.
abstract final class AppLayout {
  /// Start of the medium class (phone in landscape, tablet split screen).
  static const mediumWidth = 600.0;

  /// Start of the expanded class (tablet).
  static const expandedWidth = 840.0;

  /// Max content width of reading pages: lists, settings, onboarding.
  static const readableWidth = 760.0;

  /// Max content width of multi-column pages: Home, stats, calendar, forms.
  static const wideWidth = 1200.0;

  /// Gap between tiles, horizontal and vertical.
  static const gap = 12.0;

  /// Max width of the floating navigation bar plus the "+" button.
  static const navBarMaxWidth = 560.0;

  /// Width of floating SnackBars and max width of the form save button on
  /// non-compact windows.
  static const actionMaxWidth = 480.0;

  /// Minimum window height for the side rail (5 items + "+" ≈ 400 dp).
  static const railMinHeight = 480.0;

  static WidthClass classOf(double width) => width >= expandedWidth
      ? WidthClass.expanded
      : width >= mediumWidth
      ? WidthClass.medium
      : WidthClass.compact;

  /// Horizontal page margin for a page [width]: 16 / 24 / 32.
  static double gutter(double width) => switch (classOf(width)) {
    WidthClass.compact => 16,
    WidthClass.medium => 24,
    WidthClass.expanded => 32,
  };

  /// Side inset that keeps content within [maxWidth], centered, and never
  /// smaller than the [gutter].
  static double sideInset(double width, double maxWidth) =>
      math.max(gutter(width), (width - maxWidth) / 2);

  /// Content width left by [sideInset].
  static double contentWidth(double width, double maxWidth) =>
      width - 2 * sideInset(width, maxWidth);

  /// How many columns of at least [minWidth] (scaled with the text, so big
  /// text falls back to fewer columns) fit in [width], up to [max].
  static int columns(
    double width, {
    required double minWidth,
    required int max,
    double scale = 1,
    double gap = AppLayout.gap,
  }) => ((width + gap) / (minWidth * scale + gap)).floor().clamp(1, max);

  /// Side navigation rail instead of the bottom bar: wide landscape windows
  /// (tablet held horizontally), where height is the scarce dimension.
  static bool useRail(Size window) =>
      window.width >= expandedWidth &&
      window.width > window.height &&
      window.height >= railMinHeight;
}

/// Text scale factor used to scale column thresholds.
double textScaleOf(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(1);

/// Sliver with the adaptive page margin and centered within [maxWidth].
/// [builder] receives the content width (e.g. to choose a layout).
class SliverPageWidth extends StatelessWidget {
  const SliverPageWidth({
    super.key,
    required this.builder,
    this.maxWidth = AppLayout.readableWidth,
  });

  final double maxWidth;
  final Widget Function(BuildContext context, double width) builder;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final inset = AppLayout.sideInset(width, maxWidth);
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: inset),
          sliver: builder(context, width - 2 * inset),
        );
      },
    );
  }
}

/// `ListView` with the adaptive page margin and content centered within
/// [maxWidth]. The whole width scrolls (also when dragging on the margins).
class PageListView extends StatelessWidget {
  const PageListView({
    super.key,
    required this.children,
    this.maxWidth = AppLayout.readableWidth,
    this.top = 0,
    this.bottom = 24,
  });

  final List<Widget> children;
  final double maxWidth;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final inset = AppLayout.sideInset(box.maxWidth, maxWidth);
        return ListView(
          padding: EdgeInsets.fromLTRB(inset, top, inset, bottom),
          children: children,
        );
      },
    );
  }
}

/// Grid of tiles in rows of up to [maxColumns], each at least [minItemWidth]
/// wide. With one column the children are stacked with a 12 dp gap, so on a
/// phone it reads like a plain list.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.minItemWidth,
    this.maxColumns = 2,
    this.equalHeight = false,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;

  /// Stretches the tiles of a row to the same height (`IntrinsicHeight`).
  /// Only for children that support intrinsic sizes: no charts, no
  /// `LayoutBuilder`.
  final bool equalHeight;

  @override
  Widget build(BuildContext context) {
    final scale = textScaleOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final columns = AppLayout.columns(
          box.maxWidth,
          minWidth: minItemWidth,
          max: maxColumns,
          scale: scale,
        );
        if (columns == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: AppLayout.gap),
                children[i],
              ],
            ],
          );
        }
        final rows = <Widget>[];
        for (var start = 0; start < children.length; start += columns) {
          Widget row = Row(
            crossAxisAlignment: equalHeight
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.start,
            children: [
              for (var c = 0; c < columns; c++) ...[
                if (c > 0) const SizedBox(width: AppLayout.gap),
                Expanded(
                  child: start + c < children.length
                      ? children[start + c]
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          );
          if (equalHeight) row = IntrinsicHeight(child: row);
          if (rows.isNotEmpty) rows.add(const SizedBox(height: AppLayout.gap));
          rows.add(row);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

/// Two columns of blocks side by side when each can be at least
/// [minColumnWidth] wide; otherwise [start] then [end] stacked, separated by
/// [stackGap]. Arrange the blocks so that the stacked order is the phone
/// order.
class ResponsiveColumns extends StatelessWidget {
  const ResponsiveColumns({
    super.key,
    required this.start,
    required this.end,
    this.minColumnWidth = 360,
    this.gap = AppLayout.gap,
    this.stackGap = AppLayout.gap,
  });

  final List<Widget> start;
  final List<Widget> end;
  final double minColumnWidth;

  /// Horizontal gap between the two columns.
  final double gap;

  /// Vertical gap between [start] and [end] when stacked.
  final double stackGap;

  @override
  Widget build(BuildContext context) {
    final scale = textScaleOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final two =
            AppLayout.columns(
              box.maxWidth,
              minWidth: minColumnWidth,
              max: 2,
              scale: scale,
              gap: gap,
            ) ==
            2;
        if (!two) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...start,
              SizedBox(height: stackGap),
              ...end,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: start,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: end,
              ),
            ),
          ],
        );
      },
    );
  }
}
