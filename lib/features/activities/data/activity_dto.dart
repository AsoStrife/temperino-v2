import '../../../core/config/app_config.dart';
import '../../../core/utils/date_only.dart';
import '../../../core/utils/json_readers.dart';
import '../domain/sexual_activity.dart';

/// JSON <-> [SexualActivity] mapping for the Strapi `sexual-activities` API.
abstract final class ActivityDto {
  static SexualActivity fromJson(Map<String, dynamic> item) {
    final a = JsonReaders.attributes(item);
    return SexualActivity(
      id: JsonReaders.readId(item),
      date: DateOnly.parse(a[AppConfig.dateField] as String),
      practices: {
        for (final p in Practice.values)
          if (JsonReaders.readBool(a[p.apiField])) p,
      },
      cumshot: CumshotZone.fromApi(a['cumshot']),
      orgasmA: JsonReaders.readInt(a['orgasm_a']),
      orgasmB: JsonReaders.readInt(a['orgasm_b']),
    );
  }

  /// Body for POST/PUT: always `{ "data": { ... } }` with real booleans.
  static Map<String, dynamic> toBody(SexualActivity activity) => {
    'data': {
      for (final p in Practice.values) p.apiField: activity.has(p),
      'cumshot': activity.cumshot.apiValue,
      AppConfig.dateField: activity.date.toJson(),
      'orgasm_a': activity.orgasmA,
      'orgasm_b': activity.orgasmB,
    },
  };
}
