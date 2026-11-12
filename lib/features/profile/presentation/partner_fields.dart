import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/widgets/partner_avatar.dart';
import '../domain/partner_profile.dart';

/// Name field + gender selector, shared by onboarding and settings.
class PartnerFields extends StatelessWidget {
  const PartnerFields({
    super.key,
    required this.nameController,
    required this.gender,
    required this.onGenderChanged,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.focusNode,
  });

  final TextEditingController nameController;
  final Gender gender;
  final ValueChanged<Gender> onGenderChanged;
  final bool autofocus;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameController,
          focusNode: focusNode,
          autofocus: autofocus,
          maxLength: AppConfig.partnerNameMaxLength,
          textCapitalization: TextCapitalization.words,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          style: Theme.of(context).textTheme.titleMedium,
          decoration: const InputDecoration(hintText: 'Nome', counterText: ''),
        ),
        const SizedBox(height: 12),
        SegmentedButton<Gender>(
          segments: [
            for (final g in Gender.values)
              ButtonSegment(
                value: g,
                label: Text(g.label),
                icon: Icon(
                  g == Gender.male ? Icons.male_rounded : Icons.female_rounded,
                ),
              ),
          ],
          selected: {gender},
          showSelectedIcon: false,
          onSelectionChanged: (s) => onGenderChanged(s.first),
        ),
      ],
    );
  }
}

/// Header of a partner block: avatar + "Partner N" in the partner color.
class PartnerSlotHeader extends StatelessWidget {
  const PartnerSlotHeader({super.key, required this.partner});

  final Partner partner;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PartnerAvatar(partner: partner, radius: 22),
        const SizedBox(width: 12),
        Text(
          partner.slotLabel,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: context.appColors.partnerInk(partner)),
        ),
      ],
    );
  }
}

/// Bottom sheet to edit one partner. Returns the new [PartnerInfo] or `null`.
Future<PartnerInfo?> showPartnerSheet(
  BuildContext context, {
  required Partner partner,
  required PartnerInfo initial,
}) {
  return showModalBottomSheet<PartnerInfo>(
    context: context,
    // Root navigator: above the floating navigation bar of the shell.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _PartnerSheet(partner: partner, initial: initial),
  );
}

class _PartnerSheet extends StatefulWidget {
  const _PartnerSheet({required this.partner, required this.initial});

  final Partner partner;
  final PartnerInfo initial;

  @override
  State<_PartnerSheet> createState() => _PartnerSheetState();
}

class _PartnerSheetState extends State<_PartnerSheet> {
  late final _name = TextEditingController(text: widget.initial.name)
    ..addListener(() => setState(() {}));
  late Gender _gender = widget.initial.gender;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() =>
      Navigator.of(context)
          .pop(PartnerInfo(name: _name.text.trim(), gender: _gender));

  @override
  Widget build(BuildContext context) {
    final valid = PartnerProfile.isValidName(_name.text);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PartnerSlotHeader(partner: widget.partner),
          const SizedBox(height: 20),
          PartnerFields(
            nameController: _name,
            gender: _gender,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => valid ? _save() : null,
            onGenderChanged: (g) => setState(() => _gender = g),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: valid ? _save : null,
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}
