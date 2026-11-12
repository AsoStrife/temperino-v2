import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/preferences_provider.dart';
import '../data/profile_store.dart';
import '../domain/partner_profile.dart';

final profileStoreProvider = Provider<ProfileStore>(
  (ref) => ProfileStore(ref.watch(sharedPreferencesProvider)),
);

/// Partner profile, or `null` when onboarding is not complete.
class ProfileNotifier extends Notifier<PartnerProfile?> {
  @override
  PartnerProfile? build() => ref.watch(profileStoreProvider).read();

  Future<void> save(PartnerProfile profile) async {
    final trimmed = PartnerProfile(
      partnerA: profile.partnerA.copyWith(name: profile.partnerA.name.trim()),
      partnerB: profile.partnerB.copyWith(name: profile.partnerB.name.trim()),
    );
    await ref.read(profileStoreProvider).write(trimmed);
    state = trimmed;
  }

  Future<void> updatePartner(Partner partner, PartnerInfo info) async {
    final current = state;
    if (current == null) return;
    await save(current.withPartner(partner, info));
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, PartnerProfile?>(
  ProfileNotifier.new,
);

final isOnboardedProvider = Provider<bool>(
  (ref) => ref.watch(profileProvider) != null,
);

/// Profile for screens behind the onboarding redirect. Falls back to the slot
/// labels in the (theoretical) case the profile is missing.
final requireProfileProvider = Provider<PartnerProfile>(
  (ref) =>
      ref.watch(profileProvider) ??
      PartnerProfile(
        partnerA: PartnerInfo(name: Partner.a.slotLabel, gender: Gender.male),
        partnerB: PartnerInfo(name: Partner.b.slotLabel, gender: Gender.female),
      ),
);
