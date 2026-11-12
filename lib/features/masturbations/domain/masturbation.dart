import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/date_only.dart';
import '../../profile/domain/partner_profile.dart';

part 'masturbation.freezed.dart';

@freezed
abstract class Masturbation with _$Masturbation {
  const factory Masturbation({
    int? id,
    required DateOnly date,
    @Default(Partner.a) Partner who,
    @Default(false) bool toys,
    @Default(0) int orgasms,
  }) = _Masturbation;
}
