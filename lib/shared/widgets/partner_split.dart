import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/profile/domain/partner_profile.dart';
import 'partner_avatar.dart';
import 'tiles.dart';

/// Compares one value between the two partners: names and numbers on the
/// sides, a two-color split bar below.
class PartnerSplitTile extends StatelessWidget {
  const PartnerSplitTile({
    super.key,
    required this.title,
    required this.profile,
    required this.a,
    required this.b,
    this.caption,
  });

  final String title;
  final String? caption;
  final PartnerProfile profile;
  final int a;
  final int b;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final nameA = profile.nameOf(Partner.a);
    final nameB = profile.nameOf(Partner.b);

    Widget side(Partner p, int value, CrossAxisAlignment align) => Expanded(
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (p == Partner.a) ...[
                PartnerAvatar(partner: p, radius: 12),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  profile.nameOf(p),
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: c.partnerInk(p),
                  ),
                ),
              ),
              if (p == Partner.b) ...[
                const SizedBox(width: 8),
                PartnerAvatar(partner: p, radius: 12),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: theme.textTheme.displaySmall?.copyWith(
              fontFeatures: tabularFigures,
              height: 1,
            ),
          ),
        ],
      ),
    );

    return Tile(
      semanticsLabel: '$title. $nameA $a, $nameB $b.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          if (caption != null)
            Text(
              caption!,
              style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              side(Partner.a, a, CrossAxisAlignment.start),
              side(Partner.b, b, CrossAxisAlignment.end),
            ],
          ),
          const SizedBox(height: 16),
          SplitBar(a: a, b: b),
        ],
      ),
    );
  }
}

/// Horizontal bar split proportionally between the partner colors.
class SplitBar extends StatelessWidget {
  const SplitBar({
    super.key,
    required this.a,
    required this.b,
    this.height = 12,
  });

  final int a;
  final int b;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final total = a + b;
    final share = total == 0 ? 0.5 : a / total;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: total == 0
            ? ColoredBox(color: c.tileHigh)
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: share),
                duration: context.motion(const Duration(milliseconds: 500)),
                curve: Curves.easeOutCubic,
                builder: (context, f, _) => LayoutBuilder(
                  builder: (context, box) {
                    const gap = 3.0;
                    final wa = (box.maxWidth - gap) * f;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: wa,
                          child: ColoredBox(color: c.partnerA),
                        ),
                        const SizedBox(width: gap),
                        Expanded(child: ColoredBox(color: c.partnerB)),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
