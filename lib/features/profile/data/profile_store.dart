import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../domain/partner_profile.dart';

/// Reads and writes the partner profile in shared_preferences. The profile
/// lives only on the device; the backend knows only `A` and `B`.
class ProfileStore {
  ProfileStore(this._prefs);

  final SharedPreferences _prefs;

  /// Returns `null` when the profile is missing or incomplete (tolerant read).
  PartnerProfile? read() {
    if (_prefs.getBool(AppConfig.prefOnboarded) != true) return null;
    final a = _readPartner(
      AppConfig.prefPartnerAName,
      AppConfig.prefPartnerAGender,
    );
    final b = _readPartner(
      AppConfig.prefPartnerBName,
      AppConfig.prefPartnerBGender,
    );
    if (a == null || b == null) return null;
    return PartnerProfile(partnerA: a, partnerB: b);
  }

  PartnerInfo? _readPartner(String nameKey, String genderKey) {
    final name = _prefs.getString(nameKey);
    final gender = Gender.tryParse(_prefs.getString(genderKey));
    if (name == null || gender == null || !PartnerProfile.isValidName(name)) {
      return null;
    }
    return PartnerInfo(name: name.trim(), gender: gender);
  }

  Future<void> write(PartnerProfile profile) async {
    await _prefs.setString(
      AppConfig.prefPartnerAName,
      profile.partnerA.name.trim(),
    );
    await _prefs.setString(
      AppConfig.prefPartnerAGender,
      profile.partnerA.gender.storageValue,
    );
    await _prefs.setString(
      AppConfig.prefPartnerBName,
      profile.partnerB.name.trim(),
    );
    await _prefs.setString(
      AppConfig.prefPartnerBGender,
      profile.partnerB.gender.storageValue,
    );
    await _prefs.setBool(AppConfig.prefOnboarded, true);
  }
}
