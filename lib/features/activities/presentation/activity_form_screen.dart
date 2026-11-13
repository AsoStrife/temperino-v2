import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/utils/date_only.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/partner_avatar.dart';
import '../../../shared/widgets/tiles.dart';
import '../../profile/domain/partner_profile.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../settings/data/year_preference.dart';
import '../domain/sexual_activity.dart';
import 'activities_providers.dart';
import 'practice_icons.dart';

/// New activity (`id == null`) or edit of a record of the loaded list.
class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({super.key, this.id, this.year});

  final int? id;

  /// Year of the record to edit (the calendar opens records of any year).
  /// `null` means the selected year.
  final int? year;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  // Cached once found, so the form does not flicker while the list reloads
  // after save/delete.
  SexualActivity? _record;

  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    if (id == null) return const _ActivityForm(initial: null);
    if (_record != null) return _ActivityForm(initial: _record);

    final int year = widget.year ?? ref.watch(yearProvider);
    final list = ref.watch(activitiesProvider(year));
    return Scaffold(
      appBar: AppBar(title: const Text('Modifica attività')),
      body: AsyncBody<List<SexualActivity>>(
        value: list,
        onRetry: () => ref.invalidate(activitiesProvider(year)),
        builder: (context, items) {
          final found = items.where((x) => x.id == id).firstOrNull;
          if (found == null) {
            return const EmptyState(
              icon: Icons.search_off_rounded,
              message: 'Attività non trovata',
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

class _ActivityForm extends ConsumerStatefulWidget {
  const _ActivityForm({required this.initial});

  final SexualActivity? initial;

  @override
  ConsumerState<_ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends ConsumerState<_ActivityForm> {
  late final SexualActivity _start =
      widget.initial ?? SexualActivity(date: DateOnly.today());
  late SexualActivity _value = _start;
  var _busy = FormBusy.none;

  /// Set right before a programmatic pop (after save/delete/discard).
  var _leaving = false;

  bool get _isEdit => widget.initial != null;
  bool get _idle => _busy == FormBusy.none;
  bool get _dirty => _value != _start;

  void _update(SexualActivity Function(SexualActivity v) change) =>
      setState(() => _value = change(_value));

  void _togglePractice(Practice p) => _update(
    (v) => v.copyWith(
      practices: v.practices.contains(p)
          ? ({...v.practices}..remove(p))
          : {...v.practices, p},
    ),
  );

  void _leave() {
    setState(() => _leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    // Edits go through the list of the record's own year (it may differ from
    // the selected year when the record was opened from the calendar).
    final int year = widget.initial?.date.year ?? ref.read(yearProvider);
    final notifier = ref.read(activitiesProvider(year).notifier);
    setState(() => _busy = FormBusy.saving);
    try {
      if (_isEdit) {
        await notifier.edit(_value, previousYear: widget.initial!.date.year);
      } else {
        await notifier.add(_value);
      }
      showInfoSnack(messenger, 'Attività salvata');
      if (mounted) _leave();
    } catch (e) {
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
      title: 'Cancellare l\'attività?',
      message: 'L\'operazione non si può annullare.',
      confirmLabel: 'Cancella',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final year = widget.initial!.date.year;
    setState(() => _busy = FormBusy.deleting);
    try {
      await ref.read(activitiesProvider(year).notifier).remove(id);
      showInfoSnack(messenger, 'Attività cancellata');
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
          title: Text(_isEdit ? 'Modifica attività' : 'Nuova attività'),
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
          label: _isEdit ? 'Salva modifiche' : 'Salva attività',
          loading: _busy == FormBusy.saving,
          onPressed: _idle ? _save : null,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            const FormLabel('Quando'),
            DateQuickPicker(
              value: v.date,
              enabled: _idle,
              onChanged: (d) => _update((v) => v.copyWith(date: d)),
            ),
            const FormLabel('Com\'è andata'),
            ToggleTile(
              icon: practiceIcon(Practice.sex),
              title: Practice.sex.label,
              subtitle: 'Attivalo se è stata una scopata',
              value: v.isSex,
              onChanged: _idle ? (_) => _togglePractice(Practice.sex) : null,
            ),
            const SizedBox(height: 12),
            SelectableGrid<Practice>(
              enabled: _idle,
              selected: v.practices,
              onToggle: _togglePractice,
              options: [
                for (final p in Practice.values)
                  if (p != Practice.sex)
                    SelectableOption(p, p.label, practiceIcon(p)),
              ],
            ),
            const FormLabel('Orgasmi'),
            ResponsivePair(
              first: BigCounter(
                leading: const PartnerAvatar(partner: Partner.a, radius: 12),
                label: profile.nameOf(Partner.a),
                color: c.partnerInk(Partner.a),
                value: v.orgasmA,
                onChanged: _idle
                    ? (n) => _update((v) => v.copyWith(orgasmA: n))
                    : null,
              ),
              second: BigCounter(
                leading: const PartnerAvatar(partner: Partner.b, radius: 12),
                label: profile.nameOf(Partner.b),
                color: c.partnerInk(Partner.b),
                value: v.orgasmB,
                onChanged: _idle
                    ? (n) => _update((v) => v.copyWith(orgasmB: n))
                    : null,
              ),
            ),
            const FormLabel('Zona della sborrata'),
            ChoiceChipsWrap<CumshotZone>(
              enabled: _idle,
              // "none" first: it is the default.
              options: [
                CumshotZone.none,
                ...CumshotZone.values.where((z) => z != CumshotZone.none),
              ],
              selected: v.cumshot,
              labelOf: (z) => z.label,
              onSelected: (z) => _update((v) => v.copyWith(cumshot: z)),
            ),
          ],
        ),
      ),
    );
  }
}
