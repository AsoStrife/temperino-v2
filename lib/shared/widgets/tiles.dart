import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/config/app_config.dart';

/// Base surface of the design system: rounded, borderless, tappable.
class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color,
    this.gradient,
    this.semanticsLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;

  /// When set, the tile is read as one node with this label.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.tile);
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = InkWell(onTap: onTap, borderRadius: radius, child: content);
    }
    Widget tile = Material(
      color: gradient == null
          ? (color ?? context.appColors.tile)
          : Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: gradient == null
          ? content
          : Ink(
              decoration: BoxDecoration(gradient: gradient),
              child: content,
            ),
    );
    if (semanticsLabel != null) {
      tile = Semantics(
        container: true,
        button: onTap != null,
        label: semanticsLabel,
        excludeSemantics: true,
        child: tile,
      );
    }
    return tile;
  }
}

/// Small rounded square with an icon on a tonal background.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(AppRadii.small),
    ),
    child: Icon(icon, color: color, size: size * 0.55),
  );
}

/// Big number with a label: the building block of the bento grids.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.leading,
    this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final Widget? leading;

  /// Color of the value and of the icon badge.
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final accent = color ?? theme.colorScheme.onSurface;
    return Tile(
      onTap: onTap,
      semanticsLabel: '$label: $value${caption != null ? ', $caption' : ''}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null)
            leading!
          else if (icon != null)
            IconBadge(icon: icon!, color: color ?? c.muted),
          if (leading != null || icon != null) const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              color: accent,
              fontFeatures: tabularFigures,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.titleSmall),
          if (caption != null)
            Text(
              caption!,
              style: theme.textTheme.bodySmall?.copyWith(color: c.muted),
            ),
        ],
      ),
    );
  }
}

/// Gradient hero with a big number and the app illustration.
class HeroTile extends StatelessWidget {
  const HeroTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const onHero = Colors.white;
    return Tile(
      gradient: context.appColors.heroGradient,
      padding: const EdgeInsets.all(24),
      semanticsLabel: '$label: $value${caption != null ? ', $caption' : ''}',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(color: onHero),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: onHero,
                    fontFeatures: tabularFigures,
                    height: 1,
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    caption!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onHero.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: onHero.withValues(alpha: 0.35),
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Image.asset(
                AppConfig.activitiesImage,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section title of scrolling pages.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 28, 4, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
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
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Rows grouped in one rounded tile, separated by hairlines (inset grouped).
class InsetGroup extends StatelessWidget {
  const InsetGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Tile(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 16, endIndent: 16),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Two children side by side when there is room, stacked otherwise (keeps
/// tiles readable with 200% text).
class ResponsivePair extends StatelessWidget {
  const ResponsivePair({super.key, required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth / scale < 300) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 12), second],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: second),
            ],
          ),
        );
      },
    );
  }
}

/// Small rounded label (e.g. "Scopata", "Anal", "98 attività").
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.filled = false,
  });

  final String label;
  final IconData? icon;
  final Color? color;

  /// Filled with [color] (white text) instead of tonal.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;
    final base = color ?? c.muted;
    final fg = filled ? Colors.white : (color ?? theme.colorScheme.onSurface);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled
            ? base
            : (color == null ? c.tileHigh : base.withValues(alpha: 0.14)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: fg)),
        ],
      ),
    );
  }
}
