import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activities/presentation/activities_list_screen.dart';
import '../features/activities/presentation/activity_form_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/masturbations/presentation/masturbation_form_screen.dart';
import '../features/masturbations/presentation/masturbations_list_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_providers.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
import 'shell_scaffold.dart';

/// Route paths. Use these constants instead of string literals.
abstract final class Routes {
  static const onboarding = '/onboarding';
  static const home = '/';
  static const activities = '/activities';
  static const newActivity = '/activities/new';
  static String activity(int id) => '/activities/$id';
  static const masturbations = '/masturbations';
  static const newMasturbation = '/masturbations/new';
  static String masturbation(int id) => '/masturbations/$id';
  static const stats = '/stats';
  static const settings = '/settings';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run the redirect whenever the onboarding state changes.
  final onboarded = ValueNotifier<bool>(ref.read(isOnboardedProvider));
  ref.listen<bool>(isOnboardedProvider, (_, next) => onboarded.value = next);
  ref.onDispose(onboarded.dispose);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    refreshListenable: onboarded,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboarded.value) return atOnboarding ? null : Routes.onboarding;
      if (atOnboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            ShellScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.activities,
                builder: (context, state) => const ActivitiesListScreen(),
                routes: [
                  // Full-screen routes, outside the shell (no bottom bar).
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => const MaterialPage<void>(
                      fullscreenDialog: true,
                      child: ActivityFormScreen(),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => MaterialPage<void>(
                      fullscreenDialog: true,
                      child: ActivityFormScreen(
                        id: int.tryParse(state.pathParameters['id'] ?? ''),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.masturbations,
                builder: (context, state) => const MasturbationsListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => const MaterialPage<void>(
                      fullscreenDialog: true,
                      child: MasturbationFormScreen(),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => MaterialPage<void>(
                      fullscreenDialog: true,
                      child: MasturbationFormScreen(
                        id: int.tryParse(state.pathParameters['id'] ?? ''),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.stats,
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
