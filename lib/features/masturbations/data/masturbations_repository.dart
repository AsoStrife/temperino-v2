import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/strapi_pagination.dart';
import '../domain/masturbation.dart';
import 'masturbation_dto.dart';

class MasturbationsRepository {
  MasturbationsRepository(this._client);

  final ApiClient _client;

  static const _path = AppConfig.masturbationsPath;

  /// All masturbations of [year], newest first (sorted on a new list, B4).
  Future<List<Masturbation>> listForYear(int year) async {
    final raw = await fetchAllPages(_client, _path, query: yearQuery(year));
    final items = raw.map(MasturbationDto.fromJson).toList()
      ..sort((x, y) => y.date.compareTo(x.date));
    return List.unmodifiable(items);
  }

  Future<void> create(Masturbation m) =>
      _client.post(_path, MasturbationDto.toBody(m));

  Future<void> update(Masturbation m) {
    final id = m.id;
    if (id == null) throw ArgumentError('update() requires an id');
    return _client.put('$_path/$id', MasturbationDto.toBody(m));
  }

  Future<void> delete(int id) => _client.delete('$_path/$id');
}

final masturbationsRepositoryProvider = Provider<MasturbationsRepository>(
  (ref) => MasturbationsRepository(ref.watch(apiClientProvider)),
);
