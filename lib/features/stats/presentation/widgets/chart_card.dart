import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/tiles.dart';

/// Card wrapping a chart. [semanticsLabel] is the textual description read by
/// TalkBack; the chart itself is excluded from the semantics tree.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.semanticsLabel,
    required this.child,
    this.subtitle,
    this.legend,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final String semanticsLabel;
  final Widget child;
  final Widget? legend;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tile(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(title, style: theme.textTheme.titleMedium),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.appColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            container: true,
            label: semanticsLabel,
            child: ExcludeSemantics(child: child),
          ),
          if (legend != null) ...[const SizedBox(height: 16), legend!],
        ],
      ),
    );
  }
}

class LegendItem {
  const LegendItem(this.label, this.color);

  final String label;
  final Color color;
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.items});

  final List<LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          for (final item in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
