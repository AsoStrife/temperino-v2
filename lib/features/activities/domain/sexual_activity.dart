import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/date_only.dart';
import '../../profile/domain/partner_profile.dart';

part 'sexual_activity.freezed.dart';

/// The 12 values of the `cumshot` field.
enum CumshotZone {
  mouth('mouth'),
  butts('butts'),
  ass('ass'),
  face('face'),
  hips('hips'),
  pussyInside('pussy-inside'),
  pussyCondom('pussy-condom'),
  belly('belly'),
  feet('feet'),
  back('back'),
  tits('tits'),
  none('none');

  const CumshotZone(this.apiValue);

  final String apiValue;

  String get label => AppConfig.cumshotLabels[apiValue] ?? apiValue;

  /// Empty or unknown values (old records) map to [none].
  static CumshotZone fromApi(Object? value) {
    for (final z in CumshotZone.values) {
      if (z.apiValue == value) return z;
    }
    return CumshotZone.none;
  }
}

/// Boolean practices of an activity. [apiField] is the Strapi attribute.
enum Practice {
  sex('sex'),
  blowjob('blowjob'),
  handjob('handjob'),
  anal('anal'),
  fingering('fingering'),
  lick('lick'),
  titsFuck('tits_fuck');

  const Practice(this.apiField);

  final String apiField;

  String get label => AppConfig.practiceLabels[apiField] ?? apiField;

  /// Practices counted in the "Pratiche" statistics (sex is counted apart).
  static const statsPractices = [
    Practice.blowjob,
    Practice.handjob,
    Practice.fingering,
    Practice.lick,
    Practice.titsFuck,
    Practice.anal,
  ];
}

@freezed
abstract class SexualActivity with _$SexualActivity {
  const SexualActivity._();

  const factory SexualActivity({
    int? id,
    required DateOnly date,
    @Default(<Practice>{}) Set<Practice> practices,
    @Default(CumshotZone.none) CumshotZone cumshot,
    @Default(0) int orgasmA,
    @Default(0) int orgasmB,
  }) = _SexualActivity;

  bool has(Practice practice) => practices.contains(practice);

  bool get isSex => has(Practice.sex);

  int orgasmsOf(Partner partner) => partner == Partner.a ? orgasmA : orgasmB;
}
