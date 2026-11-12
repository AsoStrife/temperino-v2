import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../../../shared/widgets/partner_avatar.dart';
import '../../../shared/widgets/tiles.dart';
import '../../profile/domain/partner_profile.dart';
import '../../profile/presentation/partner_fields.dart';
import '../../profile/presentation/profile_providers.dart';

/// First launch: names and genders of the two partners. The router redirects
/// to Home as soon as the profile is saved.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameA = TextEditingController();
  final _nameB = TextEditingController();
  final _focusB = FocusNode();
  var _genderA = Gender.male;
  var _genderB = Gender.female;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _nameA.addListener(_refresh);
    _nameB.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _nameA.dispose();
    _nameB.dispose();
    _focusB.dispose();
    super.dispose();
  }

  bool get _valid =>
      PartnerProfile.isValidName(_nameA.text) &&
      PartnerProfile.isValidName(_nameB.text);

  Future<void> _continue() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(profileProvider.notifier)
          .save(
            PartnerProfile(
              partnerA: PartnerInfo(name: _nameA.text, gender: _genderA),
              partnerB: PartnerInfo(name: _nameB.text, gender: _genderB),
            ),
          );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    return Scaffold(
      bottomNavigationBar: SaveBar(
        label: 'Continua',
        loading: _saving,
        onPressed: _valid ? _continue : null,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
          children: [
            const Center(child: _CoupleBadge()),
            const SizedBox(height: 28),
            Text(
              'Chi siete?',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Ci servono solo nomi e sesso. Puoi cambiarli in Impostazioni.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: c.muted),
            ),
            const SizedBox(height: 28),
            Tile(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PartnerSlotHeader(partner: Partner.a),
                  const SizedBox(height: 16),
                  PartnerFields(
                    nameController: _nameA,
                    gender: _genderA,
                    autofocus: true,
                    onSubmitted: (_) => _focusB.requestFocus(),
                    onGenderChanged: (g) => setState(() => _genderA = g),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Tile(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PartnerSlotHeader(partner: Partner.b),
                  const SizedBox(height: 16),
                  PartnerFields(
                    nameController: _nameB,
                    focusNode: _focusB,
                    gender: _genderB,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _valid ? _continue() : null,
                    onGenderChanged: (g) => setState(() => _genderB = g),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two overlapping partner avatars with a heart.
class _CoupleBadge extends StatelessWidget {
  const _CoupleBadge();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return ExcludeSemantics(
      child: SizedBox(
        width: 152,
        height: 96,
        child: Stack(
          children: [
            const Positioned(
              left: 0,
              child: PartnerAvatar(partner: Partner.a, radius: 48),
            ),
            const Positioned(
              right: 0,
              child: PartnerAvatar(partner: Partner.b, radius: 48),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: c.heroGradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
