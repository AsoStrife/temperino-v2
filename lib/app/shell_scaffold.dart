import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/tiles.dart';
import 'router.dart';
import 'theme.dart';

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Shell with a floating pill navigation bar and a contextual "+" button.
/// Each tab keeps its own stack (StatefulShellRoute.indexedStack); content
/// scrolls behind the bar (`extendBody`).
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    _Destination('Home', Icons.home_outlined, Icons.home_rounded),
    _Destination(
      'Attività',
      Icons.favorite_border_rounded,
      Icons.favorite_rounded,
    ),
    _Destination(
      'Masturbazioni',
      Icons.back_hand_outlined,
      Icons.back_hand_rounded,
    ),
    _Destination(
      'Statistiche',
      Icons.insights_outlined,
      Icons.insights_rounded,
    ),
    _Destination(
      'Impostazioni',
      Icons.settings_outlined,
      Icons.settings_rounded,
    ),
  ];

  void _onSelect(int index) => navigationShell.goBranch(
    index,
    // Tapping the current tab again goes back to its root.
    initialLocation: index == navigationShell.currentIndex,
  );

  /// "+" opens the form of the current list, or asks what to add.
  Future<void> _onAdd(BuildContext context) async {
    switch (navigationShell.currentIndex) {
      case 1:
        await context.push(Routes.newActivity);
      case 2:
        await context.push(Routes.newMasturbation);
      default:
        final route = await showModalBottomSheet<String>(
          context: context,
          // Root navigator: above the floating navigation bar of the shell.
          useRootNavigator: true,
          useSafeArea: true,
          builder: (context) => const _AddSheet(),
        );
        if (route != null && context.mounted) await context.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onHome = navigationShell.currentIndex == 0;
    return PopScope(
      // Android back on a tab root other than Home goes to Home first.
      canPop: onHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !onHome) _onSelect(0);
      },
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _FloatingNavBar(
                  destinations: _destinations,
                  currentIndex: navigationShell.currentIndex,
                  onSelect: _onSelect,
                ),
              ),
              const SizedBox(width: 10),
              _AddButton(onPressed: () => _onAdd(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<_Destination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    const radius = BorderRadius.all(Radius.circular(32));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.5 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: c.tile.withValues(alpha: 0.86),
              borderRadius: radius,
              border: Border.all(color: c.hairline),
            ),
            child: Row(
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _NavItem(
                      destination: destinations[i],
                      selected: i == currentIndex,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onSelect(i);
                      },
                      selectedColor: scheme.primary,
                      selectedBackground: scheme.primaryContainer,
                      color: c.muted,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    required this.selectedBackground,
    required this.color,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color selectedBackground;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      excludeSemantics: true,
      child: Tooltip(
        message: destination.label,
        child: InkResponse(
          onTap: onTap,
          radius: 28,
          child: Center(
            child: AnimatedContainer(
              duration: context.motion(const Duration(milliseconds: 220)),
              curve: Curves.easeOutCubic,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? selectedBackground : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? destination.selectedIcon : destination.icon,
                color: selected ? selectedColor : color,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Semantics(
      button: true,
      label: 'Aggiungi',
      excludeSemantics: true,
      child: Tooltip(
        message: 'Aggiungi',
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,
            child: Ink(
              width: 64,
              height: 64,
              decoration: BoxDecoration(gradient: c.heroGradient),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onPressed();
                },
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "What do you want to add?" sheet, used outside the list tabs.
class _AddSheet extends StatelessWidget {
  const _AddSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = context.appColors;

    Widget option(String title, String subtitle, IconData icon, String route) =>
        Tile(
          color: c.tileHigh,
          onTap: () => Navigator.of(context).pop(route),
          semanticsLabel: title,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconBadge(icon: icon, color: c.accentInk, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: c.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.muted),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Text('Cosa aggiungi?', style: theme.textTheme.titleLarge),
          ),
          option(
            'Attività',
            'Sesso, preliminari, orgasmi',
            Icons.favorite_rounded,
            Routes.newActivity,
          ),
          const SizedBox(height: 10),
          option(
            'Masturbazione',
            'Chi, giocattoli, orgasmi',
            Icons.back_hand_rounded,
            Routes.newMasturbation,
          ),
        ],
      ),
    );
  }
}
