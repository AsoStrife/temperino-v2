import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../core/utils/date_only.dart';
import '../../core/utils/formatters.dart';
import 'confirm_dialog.dart';
import 'tiles.dart';

/// One month of items.
class MonthGroup<T> {
  const MonthGroup(this.year, this.month, this.items);

  final int year;
  final int month;
  final List<T> items;
}

/// Groups [items] (already sorted, newest first) by month.
List<MonthGroup<T>> groupByMonth<T>(
  List<T> items,
  DateOnly Function(T item) dateOf,
) {
  final groups = <MonthGroup<T>>[];
  for (final item in items) {
    final d = dateOf(item);
    if (groups.isEmpty ||
        groups.last.year != d.year ||
        groups.last.month != d.month) {
      groups.add(MonthGroup(d.year, d.month, []));
    }
    groups.last.items.add(item);
  }
  return groups;
}

/// Sliver list of months; each month is an inset group of rows that can be
/// swiped left to delete (after confirmation).
class SliverMonthGroups<T> extends StatelessWidget {
  const SliverMonthGroups({
    super.key,
    required this.groups,
    required this.keyOf,
    required this.rowBuilder,
    required this.onTap,
    required this.onDelete,
    required this.deleteTitle,
  });

  final List<MonthGroup<T>> groups;
  final Object Function(T item) keyOf;
  final Widget Function(BuildContext context, T item) rowBuilder;
  final ValueChanged<T> onTap;

  /// Called after the user confirmed the swipe.
  final ValueChanged<T> onDelete;
  final String deleteTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final g = groups[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          Formatters.monthYear(g.year, g.month),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                    Text(
                      '${g.items.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
              InsetGroup(
                children: [
                  for (final item in g.items)
                    _SwipeToDelete(
                      key: ValueKey(keyOf(item)),
                      title: deleteTitle,
                      onConfirmed: () => onDelete(item),
                      child: InkWell(
                        onTap: () => onTap(item),
                        child: rowBuilder(context, item),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SwipeToDelete extends StatelessWidget {
  const _SwipeToDelete({
    super.key,
    required this.child,
    required this.title,
    required this.onConfirmed,
  });

  final Widget child;
  final String title;
  final VoidCallback onConfirmed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_outline_rounded, color: scheme.onError),
      ),
      confirmDismiss: (_) {
        HapticFeedback.mediumImpact();
        return showConfirmDialog(
          context,
          title: title,
          message: 'L\'operazione non si può annullare.',
          confirmLabel: 'Cancella',
          destructive: true,
        );
      },
      onDismissed: (_) => onConfirmed(),
      child: child,
    );
  }
}

/// Leading day number + short weekday of list rows.
class DayBadge extends StatelessWidget {
  const DayBadge({super.key, required this.date});

  final DateOnly date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 44,
      child: Column(
        children: [
          Text(
            '${date.day}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontFeatures: tabularFigures,
              height: 1.1,
            ),
          ),
          Text(
            Formatters.weekdayShort(date),
            style: theme.textTheme.labelSmall?.copyWith(
              color: context.appColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small colored circle with a number (orgasms of a partner).
class CountBubble extends StatelessWidget {
  const CountBubble({
    super.key,
    required this.value,
    required this.color,
    required this.textColor,
  });

  final int value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    padding: const EdgeInsets.symmetric(horizontal: 6),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      '$value',
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: textColor, fontFeatures: tabularFigures),
    ),
  );
}

/// Wrap of summary pills shown at the top of a list.
class SummaryPills extends StatelessWidget {
  const SummaryPills({super.key, required this.pills});

  final List<Pill> pills;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
    sliver: SliverToBoxAdapter(
      child: Wrap(spacing: 8, runSpacing: 8, children: pills),
    ),
  );
}
