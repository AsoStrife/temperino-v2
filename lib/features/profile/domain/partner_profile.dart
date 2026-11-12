import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/config/app_config.dart';

part 'partner_profile.freezed.dart';

enum Gender {
  male('male'),
  female('female');

  const Gender(this.storageValue);

  final String storageValue;

  String get label => this == Gender.male
      ? AppConfig.genderLabelMale
      : AppConfig.genderLabelFemale;

  /// Label of the masturbation counter for a partner of this gender.
  String get masturbationLabel => this == Gender.male
      ? AppConfig.masturbationLabelMale
      : AppConfig.masturbationLabelFemale;

  static Gender? tryParse(String? value) {
    for (final g in Gender.values) {
      if (g.storageValue == value) return g;
    }
    return null;
  }
}

/// Partner slot. `A` in the backend is partner 1 (blue), `B` is partner 2
/// (orange). Colors and avatars belong to the slot, never to the name.
enum Partner {
  a(0),
  b(1);

  const Partner(this._index);

  final int _index;

  String get apiValue => AppConfig.partnerApiValues[_index];

  String get avatarAsset =>
      this == Partner.a ? AppConfig.partnerAvatarA : AppConfig.partnerAvatarB;

  /// "Partner 1" / "Partner 2"
  String get slotLabel => 'Partner ${_index + 1}';

  static Partner fromApi(String? value) =>
      value == Partner.b.apiValue ? Partner.b : Partner.a;
}

@freezed
abstract class PartnerInfo with _$PartnerInfo {
  const factory PartnerInfo({required String name, required Gender gender}) =
      _PartnerInfo;
}

@freezed
abstract class PartnerProfile with _$PartnerProfile {
  const PartnerProfile._();

  const factory PartnerProfile({
    required PartnerInfo partnerA,
    required PartnerInfo partnerB,
  }) = _PartnerProfile;

  PartnerInfo of(Partner partner) => partner == Partner.a ? partnerA : partnerB;

  String nameOf(Partner partner) => of(partner).name;

  PartnerProfile withPartner(Partner partner, PartnerInfo info) =>
      partner == Partner.a
      ? copyWith(partnerA: info)
      : copyWith(partnerB: info);

  /// Name valid after trim: 1-30 characters.
  static bool isValidName(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty &&
        trimmed.length <= AppConfig.partnerNameMaxLength;
  }
}
