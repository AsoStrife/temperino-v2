import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../features/settings/data/year_preference.dart';

/// Year pill shown in the top bar of every main screen. Opens a bottom
/// sheet with the selectable years.
class YearSelector extends ConsumerWidget {
  const YearSelector({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, int current) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      // Root navigator: above the floating navigation bar of the shell.
      useRootNavigator: true,
      useSafeArea: true,
      builder: (context) => _YearSheet(current: current),
    );
    if (picked != null) await ref.read(yearProvider.notifier).select(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = ref.watch(yearProvider);
    final c = context.appColors;
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: 'Anno $year, cambia anno',
      excludeSemantics: true,
      child: Material(
        color: c.tileHigh,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context, ref, year),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$year',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFeatures: tabularFigures,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.expand_more_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _YearSheet extends StatelessWidget {
  const _YearSheet({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Text('Scegli l\'anno', style: theme.textTheme.titleLarge),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final y in selectableYears())
                ChoiceChip(
                  label: Text(
                    '$y',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: y == current
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  selected: y == current,
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: c.tileHigh,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  onSelected: (_) => Navigator.of(context).pop(y),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
