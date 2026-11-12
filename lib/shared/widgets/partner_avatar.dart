import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../features/profile/domain/partner_profile.dart';

/// Round avatar of a partner slot with a thin ring in the partner color.
class PartnerAvatar extends StatelessWidget {
  const PartnerAvatar({super.key, required this.partner, this.radius = 20});

  final Partner partner;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ring = radius >= 20 ? 2.5 : 1.5;
    return Container(
      width: radius * 2,
      height: radius * 2,
      padding: EdgeInsets.all(ring),
      decoration: BoxDecoration(
        color: context.appColors.partner(partner),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundImage: AssetImage(partner.avatarAsset),
        backgroundColor: context.appColors.tile,
      ),
    );
  }
}
