import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/widgets/app_page.dart';
import '../../../shared/widgets/partner_avatar.dart';
import '../../../shared/widgets/tiles.dart';
import '../../../shared/widgets/year_selector.dart';
import '../../profile/domain/partner_profile.dart';
import '../../profile/presentation/partner_fields.dart';
import '../../profile/presentation/profile_providers.dart';
import '../data/theme_preference.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _editPartner(
    BuildContext context,
    WidgetRef ref,
    Partner partner,
    PartnerInfo current,
  ) async {
    final updated = await showPartnerSheet(
      context,
      partner: partner,
      initial: current,
    );
    if (updated == null) return;
    await ref.read(profileProvider.notifier).updatePartner(partner, updated);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profilo aggiornato')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(requireProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final c = context.appColors;
    final theme = Theme.of(context);

    return AppPage(
      slivers: [
        PageSection(
          children: [
            const SectionTitle('Partner'),
            InsetGroup(
              children: [
                for (final p in Partner.values)
                  _SettingsRow(
                    leading: PartnerAvatar(partner: p, radius: 22),
                    title: profile.nameOf(p),
                    titleColor: c.partnerInk(p),
                    subtitle: '${p.slotLabel} · ${profile.of(p).gender.label}',
                    trailing: Icon(Icons.chevron_right_rounded, color: c.muted),
                    onTap: () => _editPartner(context, ref, p, profile.of(p)),
                  ),
              ],
            ),
            const SectionTitle('Dati'),
            InsetGroup(
              children: [
                _SettingsRow(
                  leading: IconBadge(
                    icon: Icons.calendar_month_rounded,
                    color: c.accentInk,
                  ),
                  title: 'Anno visualizzato',
                  subtitle: 'Vale per tutte le schermate',
                  trailing: const YearSelector(),
                ),
              ],
            ),
            const SectionTitle('Aspetto'),
            Tile(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Tema', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('Auto'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Chiaro'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Scuro'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (s) =>
                        ref.read(themeModeProvider.notifier).select(s.first),
                  ),
                ],
              ),
            ),
            const SectionTitle('Informazioni'),
            InsetGroup(
              children: [
                _SettingsRow(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.small),
                    child: Image.asset(
                      AppConfig.activitiesImage,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: AppConfig.appName,
                  subtitle: 'Versione ${AppConfig.appVersion}',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: titleColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.appColors.muted,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
    if (onTap == null) return MergeSemantics(child: row);
    return InkWell(
      onTap: onTap,
      child: MergeSemantics(child: row),
    );
  }
}
