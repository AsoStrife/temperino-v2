import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/strapi_pagination.dart';
import '../domain/sexual_activity.dart';
import 'activity_dto.dart';

class ActivitiesRepository {
  ActivitiesRepository(this._client);

  final ApiClient _client;

  static const _path = AppConfig.sexualActivitiesPath;

  /// All activities of [year], newest first. The list is sorted client side
  /// too, on a new list (fix B4, safety net for B10).
  Future<List<SexualActivity>> listForYear(int year) async {
    final raw = await fetchAllPages(_client, _path, query: yearQuery(year));
    final items = raw.map(ActivityDto.fromJson).toList()
      ..sort((x, y) => y.date.compareTo(x.date));
    return List.unmodifiable(items);
  }

  Future<void> create(SexualActivity activity) =>
      _client.post(_path, ActivityDto.toBody(activity));

  Future<void> update(SexualActivity activity) {
    final id = activity.id;
    if (id == null) throw ArgumentError('update() requires an id');
    return _client.put('$_path/$id', ActivityDto.toBody(activity));
  }

  Future<void> delete(int id) => _client.delete('$_path/$id');
}

final activitiesRepositoryProvider = Provider<ActivitiesRepository>(
  (ref) => ActivitiesRepository(ref.watch(apiClientProvider)),
);
