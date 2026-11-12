import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

class BarEntry {
  const BarEntry(this.label, this.value, {this.color});

  final String label;
  final int value;
  final Color? color;
}

/// Horizontal bars with the label above each bar. Built with plain widgets
/// (not fl_chart) so long Italian labels wrap and scale up to 200% text.
class HorizontalBars extends StatelessWidget {
  const HorizontalBars({super.key, required this.entries, required this.color});

  final List<BarEntry> entries;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = entries.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    final duration = context.motion(const Duration(milliseconds: 450));

    return Column(
      children: [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(e.label, style: theme.textTheme.bodyMedium),
                    ),
                    Text(
                      '${e.value}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(height: 12, color: context.appColors.tileHigh),
                      TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: max == 0 ? 0 : e.value / max,
                        ),
                        duration: duration,
                        curve: Curves.easeOutCubic,
                        builder: (context, f, _) => FractionallySizedBox(
                          widthFactor: f,
                          child: Container(height: 12, color: e.color ?? color),
                        ),
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
