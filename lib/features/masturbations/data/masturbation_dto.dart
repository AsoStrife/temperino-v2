import '../../../core/config/app_config.dart';
import '../../../core/utils/date_only.dart';
import '../../../core/utils/json_readers.dart';
import '../../profile/domain/partner_profile.dart';
import '../domain/masturbation.dart';

/// JSON <-> [Masturbation] mapping for the Strapi `masturbations` API.
abstract final class MasturbationDto {
  static Masturbation fromJson(Map<String, dynamic> item) {
    final a = JsonReaders.attributes(item);
    return Masturbation(
      id: JsonReaders.readId(item),
      date: DateOnly.parse(a[AppConfig.dateField] as String),
      who: Partner.fromApi(a['who'] as String?),
      toys: JsonReaders.readBool(a['toys']),
      orgasms: JsonReaders.readInt(a['n_orgasms']),
    );
  }

  /// Body for POST/PUT. `toys` is always a boolean (fix B12).
  static Map<String, dynamic> toBody(Masturbation m) => {
    'data': {
      'who': m.who.apiValue,
      'toys': m.toys,
      AppConfig.dateField: m.date.toJson(),
      'n_orgasms': m.orgasms,
    },
  };
}
