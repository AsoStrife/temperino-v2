import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/utils/date_only.dart';
import '../../../shared/widgets/adaptive.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/partner_avatar.dart';
import '../../../shared/widgets/tiles.dart';
import '../../profile/domain/partner_profile.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../settings/data/year_preference.dart';
import '../domain/masturbation.dart';
import 'masturbations_providers.dart';

/// New masturbation (`id == null`) or edit of a record of the loaded list.
class MasturbationFormScreen extends ConsumerStatefulWidget {
  const MasturbationFormScreen({super.key, this.id, this.year});

  final int? id;

  /// Year of the record to edit (the calendar opens records of any year).
  /// `null` means the selected year.
  final int? year;

  @override
  ConsumerState<MasturbationFormScreen> createState() =>
      _MasturbationFormScreenState();
}

class _MasturbationFormScreenState
    extends ConsumerState<MasturbationFormScreen> {
  Masturbation? _record;

  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    if (id == null) return const _MasturbationForm(initial: null);
    if (_record != null) return _MasturbationForm(initial: _record);

    final int year = widget.year ?? ref.watch(yearProvider);
    final list = ref.watch(masturbationsProvider(year));
    return Scaffold(
      appBar: AppBar(title: const Text('Modifica masturbazione')),
      body: AsyncBody<List<Masturbation>>(
        value: list,
        onRetry: () => ref.invalidate(masturbationsProvider(year)),
        builder: (context, items) {
          final found = items.where((m) => m.id == id).firstOrNull;
          if (found == null) {
            return const EmptyState(
              icon: Icons.search_off_rounded,
              message: 'Masturbazione non trovata',
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _record = found);
          });
          return const InlineLoader();
        },
      ),
    );
  }
}

class _MasturbationForm extends ConsumerStatefulWidget {
  const _MasturbationForm({required this.initial});

  final Masturbation? initial;

  @override
  ConsumerState<_MasturbationForm> createState() => _MasturbationFormState();
}

class _MasturbationFormState extends ConsumerState<_MasturbationForm> {
  late final Masturbation _start =
      widget.initial ?? Masturbation(date: DateOnly.today());
  late Masturbation _value = _start;
  var _busy = FormBusy.none;
  var _leaving = false;

  bool get _isEdit => widget.initial != null;
  bool get _idle => _busy == FormBusy.none;
  bool get _dirty => _value != _start;

  void _update(Masturbation Function(Masturbation v) change) =>
      setState(() => _value = change(_value));

  void _leave() {
    setState(() => _leaving = true);
    // Pop after the rebuild, when PopScope.canPop is already true.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    // Edits go through the list of the record's own year (it may differ from
    // the selected year when the record was opened from the calendar).
    final int year = widget.initial?.date.year ?? ref.read(yearProvider);
    final notifier = ref.read(masturbationsProvider(year).notifier);
    setState(() => _busy = FormBusy.saving);
    try {
      if (_isEdit) {
        await notifier.edit(_value, previousYear: widget.initial!.date.year);
      } else {
        await notifier.add(_value);
      }
      showInfoSnack(messenger, 'Masturbazione salvata');
      if (mounted) _leave();
    } catch (e) {
      // B8: the error is always shown.
      showErrorSnack(messenger, 'Salvataggio non riuscito', e);
    } finally {
      if (mounted) setState(() => _busy = FormBusy.none);
    }
  }

  Future<void> _delete() async {
    final id = widget.initial?.id;
    if (id == null) return;
    final confirmed = await showConfirmDialog(
      context,
      title: 'Cancellare la masturbazione?',
      message: 'L\'operazione non si può annullare.',
      confirmLabel: 'Cancella',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final year = widget.initial!.date.year;
    setState(() => _busy = FormBusy.deleting);
    try {
      await ref.read(masturbationsProvider(year).notifier).remove(id);
      showInfoSnack(messenger, 'Masturbazione cancellata');
      if (mounted) _leave();
    } catch (e) {
      showErrorSnack(messenger, 'Cancellazione non riuscita', e);
    } finally {
      if (mounted) setState(() => _busy = FormBusy.none);
    }
  }

  Future<void> _onPopBlocked() async {
    if (!_idle) return;
    if (await confirmDiscard(context) && mounted) _leave();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(requireProfileProvider);
    final c = context.appColors;
    final v = _value;

    return PopScope(
      canPop: _leaving || (!_dirty && _idle),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onPopBlocked();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEdit ? 'Modifica masturbazione' : 'Nuova masturbazione',
          ),
          actions: [
            if (_isEdit)
              _busy == FormBusy.deleting
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Cancella',
                      onPressed: _idle ? _delete : null,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
            const SizedBox(width: 4),
          ],
        ),
        bottomNavigationBar: SaveBar(
          label: _isEdit ? 'Salva modifiche' : 'Salva masturbazione',
          loading: _busy == FormBusy.saving,
          onPressed: _idle ? _save : null,
        ),
        body: PageListView(
          maxWidth: AppLayout.wideWidth,
          children: [
            // Two columns on tablets; stacked it is the phone order.
            ResponsiveColumns(
              minColumnWidth: formColumnMinWidth,
              gap: formColumnGap,
              stackGap: 0,
              start: [
                const FormLabel('Chi'),
                ResponsivePair(
                  first: _PartnerChoice(
                    partner: Partner.a,
                    name: profile.nameOf(Partner.a),
                    selected: v.who == Partner.a,
                    onTap: _idle
                        ? () => _update((v) => v.copyWith(who: Partner.a))
                        : null,
                  ),
                  second: _PartnerChoice(
                    partner: Partner.b,
                    name: profile.nameOf(Partner.b),
                    selected: v.who == Partner.b,
                    onTap: _idle
                        ? () => _update((v) => v.copyWith(who: Partner.b))
                        : null,
                  ),
                ),
                const FormLabel('Quando'),
                DateQuickPicker(
                  value: v.date,
                  enabled: _idle,
                  onChanged: (d) => _update((v) => v.copyWith(date: d)),
                ),
              ],
              end: [
                const FormLabel('Dettagli'),
                ToggleTile(
                  icon: Icons.vibration_rounded,
                  title: 'Giocattoli',
                  subtitle: 'Con vibratore o altri giochi',
                  value: v.toys,
                  onChanged: _idle
                      ? (on) => _update((v) => v.copyWith(toys: on))
                      : null,
                ),
                const SizedBox(height: 12),
                BigCounter(
                  label: 'Orgasmi',
                  color: c.partnerInk(v.who),
                  value: v.orgasms,
                  onChanged: _idle
                      ? (n) => _update((v) => v.copyWith(orgasms: n))
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

/// Large selectable tile with the partner avatar and name.
class _PartnerChoice extends StatelessWidget {
  const _PartnerChoice({
    required this.partner,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final Partner partner;
  final String name;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final color = c.partner(partner);
    final radius = BorderRadius.circular(AppRadii.tile);
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: context.motion(const Duration(milliseconds: 180)),
        decoration: BoxDecoration(
          color: selected ? c.partnerSoft(partner) : c.tile,
          borderRadius: radius,
          border: Border.all(
            color: selected ? color : Colors.transparent,
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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      PartnerAvatar(partner: partner, radius: 32),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: AnimatedScale(
                          scale: selected ? 1 : 0,
                          duration: context.motion(
                            const Duration(milliseconds: 180),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: c.tile,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: color,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: selected
                          ? c.partnerInk(partner)
                          : theme.colorScheme.onSurface,
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
