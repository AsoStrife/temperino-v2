import 'package:flutter/material.dart';

import '../domain/sexual_activity.dart';

/// Icon of each practice, shared by form, list and statistics.
IconData practiceIcon(Practice p) => switch (p) {
  Practice.sex => Icons.favorite_rounded,
  Practice.blowjob => Icons.face_retouching_natural_rounded,
  Practice.handjob => Icons.back_hand_rounded,
  Practice.anal => Icons.radio_button_checked_rounded,
  Practice.fingering => Icons.touch_app_rounded,
  Practice.lick => Icons.emoji_emotions_rounded,
  Practice.titsFuck => Icons.spa_rounded,
};
