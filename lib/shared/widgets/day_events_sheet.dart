import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/utils/date_only.dart';
import '../../core/utils/formatters.dart';

/// Bottom sheet with the records of one day. Returns the tapped record, or
/// `null` when the sheet is dismissed. The caller opens the record.
Future<T?> showDayEventsSheet<T>(
  BuildContext context, {
  required DateOnly date,
  required String subtitle,
  required List<T> items,
  required Widget Function(BuildContext context, T item) rowBuilder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // Root navigator: above the floating navigation bar of the shell.
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) => _DayEventsSheet<T>(
      date: date,
      subtitle: subtitle,
      items: items,
      rowBuilder: rowBuilder,
    ),
  );
}

class _DayEventsSheet<T> extends StatelessWidget {
  const _DayEventsSheet({
    required this.date,
    required this.subtitle,
    required this.items,
    required this.rowBuilder,
  });

  final DateOnly date;
  final String subtitle;
  final List<T> items;
  final Widget Function(BuildContext context, T item) rowBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Semantics(
                header: true,
                child: Text(
                  Formatters.dateLong(date),
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: c.muted),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Material(
                  color: c.tileHigh,
                  borderRadius: BorderRadius.circular(AppRadii.tile),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const Divider(indent: 16, endIndent: 16),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(items[i]),
                          child: rowBuilder(context, items[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
