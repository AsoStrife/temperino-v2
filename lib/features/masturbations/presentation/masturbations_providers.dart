import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stats/presentation/stats_providers.dart';
import '../data/masturbations_repository.dart';
import '../domain/masturbation.dart';

/// Masturbations of one year, newest first. Same contract as
/// `ActivitiesNotifier`.
class MasturbationsNotifier extends AsyncNotifier<List<Masturbation>> {
  MasturbationsNotifier(this.year);

  final int year;

  MasturbationsRepository get _repo =>
      ref.read(masturbationsRepositoryProvider);

  @override
  Future<List<Masturbation>> build() =>
      ref.watch(masturbationsRepositoryProvider).listForYear(year);

  Future<void> add(Masturbation m) async {
    await _repo.create(m);
    await _reload({m.date.year});
  }

  Future<void> edit(Masturbation m, {int? previousYear}) async {
    await _repo.update(m);
    await _reload({m.date.year, ?previousYear});
  }

  Future<void> remove(int id) async {
    await _repo.delete(id);
    await _reload(const {});
  }

  Future<void> _reload(Set<int> touchedYears) async {
    for (final y in touchedYears) {
      if (y != year) ref.invalidate(masturbationsProvider(y));
    }
    ref.invalidate(yearlyProvider);
    state = await AsyncValue.guard(() => _repo.listForYear(year));
  }

  Masturbation? findById(int id) {
    for (final m in state.value ?? const <Masturbation>[]) {
      if (m.id == id) return m;
    }
    return null;
  }
}

final masturbationsProvider =
    AsyncNotifierProvider.family<
      MasturbationsNotifier,
      List<Masturbation>,
      int
    >(MasturbationsNotifier.new);
