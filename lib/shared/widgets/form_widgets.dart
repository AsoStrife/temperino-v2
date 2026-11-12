import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../core/error/app_exception.dart';
import '../../core/utils/date_only.dart';
import '../../core/utils/formatters.dart';
import 'confirm_dialog.dart';
import 'tiles.dart';

/// Operation currently running in a form. One state per form, always reset
/// in `finally` (fix B7).
enum FormBusy { none, saving, deleting }

/// Shows the save/delete error SnackBar (fix B8).
void showErrorSnack(ScaffoldMessengerState messenger, String prefix, Object e) {
  messenger.showSnackBar(
    SnackBar(content: Text('$prefix: ${AppException.from(e).message}')),
  );
}

void showInfoSnack(ScaffoldMessengerState messenger, String message) {
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

/// Asks before leaving a form with unsaved changes.
Future<bool> confirmDiscard(BuildContext context) => showConfirmDialog(
  context,
  title: 'Uscire senza salvare?',
  message: 'Le modifiche andranno perse.',
  confirmLabel: 'Esci',
  cancelLabel: 'Resta',
  icon: Icons.edit_off_rounded,
);

/// Label above a form block.
class FormLabel extends StatelessWidget {
  const FormLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                text,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: context.appColors.muted,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Date with one-tap shortcuts "Oggi" / "Ieri" and a calendar for other
/// days. Future dates are not selectable.
class DateQuickPicker extends StatelessWidget {
  const DateQuickPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final DateOnly value;
  final ValueChanged<DateOnly> onChanged;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final today = DateOnly.today();
    final picked = await showDatePicker(
      context: context,
      initialDate: value.isAfter(today)
          ? today.toDateTime()
          : value.toDateTime(),
      firstDate: DateTime(2000),
      lastDate: today.toDateTime(),
      helpText: 'Seleziona la data',
    );
    if (picked != null) onChanged(DateOnly.fromDateTime(picked));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateOnly.today();
    final yesterday = DateOnly.fromDateTime(
      today.toDateTime().subtract(const Duration(days: 1)),
    );
    final isToday = value == today;
    final isYesterday = value == yesterday;
    final isOther = !isToday && !isYesterday;

    Widget chip(
      String label,
      bool selected,
      VoidCallback onTap, {
      IconData? icon,
    }) => ChoiceChip(
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 18,
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
      label: Text(label),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
      ),
      selected: selected,
      selectedColor: theme.colorScheme.primary,
      onSelected: enabled ? (_) => onTap() : null,
    );

    return Tile(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${Formatters.weekdayLong(value)} ${Formatters.dayMonth(value)}',
            style: theme.textTheme.titleLarge,
          ),
          Text(
            '${value.year}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.appColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              chip('Oggi', isToday, () => onChanged(today)),
              chip('Ieri', isYesterday, () => onChanged(yesterday)),
              chip(
                isOther ? Formatters.date(value) : 'Altro giorno',
                isOther,
                () => _pick(context),
                icon: Icons.calendar_month_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Large on/off row with icon, title and switch; the whole tile toggles.
class ToggleTile extends StatelessWidget {
  const ToggleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    return MergeSemantics(
      child: AnimatedContainer(
        duration: context.motion(const Duration(milliseconds: 200)),
        decoration: BoxDecoration(
          color: value ? c.accentSoft : c.tile,
          borderRadius: BorderRadius.circular(AppRadii.tile),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.tile),
            onTap: onChanged == null ? null : () => onChanged!(!value),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  IconBadge(icon: icon, color: value ? c.accentInk : c.muted),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: c.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Switch(value: value, onChanged: onChanged),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectableOption<T> {
  const SelectableOption(this.value, this.label, this.icon);

  final T value;
  final String label;
  final IconData icon;
}

/// Multi-select grid of tiles with icon and label (2 or 3 columns).
class SelectableGrid<T> extends StatelessWidget {
  const SelectableGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.enabled = true,
  });

  final List<SelectableOption<T>> options;
  final Set<T> selected;
  final ValueChanged<T> onToggle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 10.0;
        final columns = box.maxWidth / scale >= 330 ? 3 : 2;
        final width = (box.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final o in options)
              SizedBox(
                width: width,
                child: _SelectableTile(
                  label: o.label,
                  icon: o.icon,
                  selected: selected.contains(o.value),
                  onTap: enabled ? () => onToggle(o.value) : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(AppRadii.inner + 4);
    return Semantics(
      button: true,
      toggled: selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: context.motion(const Duration(milliseconds: 180)),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer : c.tile,
          borderRadius: radius,
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap!();
                  },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: selected ? scheme.primary : c.muted,
                        size: 26,
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: selected ? 1 : 0,
                        duration: context.motion(
                          const Duration(milliseconds: 150),
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single-select wrap of chips (e.g. cumshot zone).
class ChoiceChipsWrap<T> extends StatelessWidget {
  const ChoiceChipsWrap({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.enabled = true,
  });

  final List<T> options;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          ChoiceChip(
            label: Text(labelOf(o)),
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              color: o == selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            selected: o == selected,
            selectedColor: theme.colorScheme.primary,
            backgroundColor: context.appColors.tile,
            onSelected: enabled ? (_) => onSelected(o) : null,
          ),
      ],
    );
  }
}

/// Big counter with round minus/plus buttons, used for orgasms.
class BigCounter extends StatelessWidget {
  const BigCounter({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.leading,
    this.color,
    this.min = 0,
    this.max = 99,
  });

  final String label;
  final int value;
  final ValueChanged<int>? onChanged;
  final Widget? leading;
  final Color? color;
  final int min;
  final int max;

  void _set(int v) {
    HapticFeedback.selectionClick();
    onChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final tint = color ?? theme.colorScheme.primary;
    Widget button(IconData icon, String tooltip, VoidCallback? onTap) =>
        IconButton.filledTonal(
          tooltip: tooltip,
          onPressed: onTap,
          iconSize: 26,
          style: IconButton.styleFrom(
            minimumSize: const Size(52, 52),
            backgroundColor: tint.withValues(alpha: 0.14),
            foregroundColor: tint,
          ),
          icon: Icon(icon),
        );

    return Tile(
      padding: const EdgeInsets.all(16),
      child: Semantics(
        label: '$label: $value',
        increasedValue: '${value + 1}',
        decreasedValue: '${value - 1}',
        onIncrease: onChanged != null && value < max
            ? () => _set(value + 1)
            : null,
        onDecrease: onChanged != null && value > min
            ? () => _set(value - 1)
            : null,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color ?? c.muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: theme.textTheme.displayMedium?.copyWith(
                fontFeatures: tabularFigures,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                button(
                  Icons.remove_rounded,
                  'Diminuisci',
                  onChanged != null && value > min
                      ? () => _set(value - 1)
                      : null,
                ),
                const SizedBox(width: 16),
                button(
                  Icons.add_rounded,
                  'Aumenta',
                  onChanged != null && value < max
                      ? () => _set(value + 1)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Fixed bottom bar with the primary action of a form.
class SaveBar extends StatelessWidget {
  const SaveBar({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: context.appColors.hairline)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: FilledButton.icon(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        icon: loading
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.colorScheme.onSurface,
                ),
              )
            : const Icon(Icons.check_rounded),
        label: Text(label),
      ),
    );
  }
}
