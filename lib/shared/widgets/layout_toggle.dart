import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/data/layout_preference.dart';

/// Two-icon segmented control (list / calendar) for the top bar of the
/// activities and masturbations tabs. The choice is shared and persisted.
class ListLayoutToggle extends ConsumerWidget {
  const ListLayoutToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(listLayoutProvider);
    return SegmentedButton<ListLayout>(
      showSelectedIcon: false,
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
      ),
      segments: const [
        ButtonSegment(
          value: ListLayout.list,
          icon: Icon(Icons.view_agenda_rounded),
          tooltip: 'Vista lista',
        ),
        ButtonSegment(
          value: ListLayout.calendar,
          icon: Icon(Icons.calendar_month_rounded),
          tooltip: 'Vista calendario',
        ),
      ],
      selected: {layout},
      onSelectionChanged: (s) {
        HapticFeedback.selectionClick();
        ref.read(listLayoutProvider.notifier).select(s.first);
      },
    );
  }
}
