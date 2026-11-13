import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import 'adaptive.dart';
import 'empty_state.dart';

/// Main page layout: slim pinned bar with the [actions] (no page title: the
/// floating navigation bar already says where we are), optional
/// pull-to-refresh and bottom padding for the floating navigation bar.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.slivers,
    this.actions = const [],
    this.onRefresh,
    this.bottom,
  });

  final List<Widget> actions;
  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;
  final PreferredSizeWidget? bottom;

  /// Height of the pinned bar below the status bar: toolbar (when there are
  /// [actions]) plus [bottom]. Zero when the page has neither.
  static double barHeight({
    required bool hasActions,
    double bottomHeight = 0,
  }) => (hasActions ? kToolbarHeight : 0) + bottomHeight;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final hasActions = actions.isNotEmpty;
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    // MediaQuery bottom padding includes the floating bar (shell extendBody).
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          // Without actions the bar only paints behind the status bar.
          toolbarHeight: hasActions ? kToolbarHeight : 0,
          actions: hasActions ? [...actions, const SizedBox(width: 8)] : null,
          bottom: bottom,
        ),
        if (!hasActions && bottom == null)
          const SliverPadding(padding: EdgeInsets.only(top: 8)),
        ...slivers,
        SliverPadding(padding: EdgeInsets.only(bottom: padding.bottom + 24)),
      ],
    );
    return Scaffold(
      body: onRefresh == null
          ? scroll
          : RefreshIndicator(
              onRefresh: onRefresh!,
              edgeOffset:
                  padding.top +
                  barHeight(hasActions: hasActions, bottomHeight: bottomHeight),
              child: scroll,
            ),
    );
  }
}

/// List of box widgets with the adaptive page margin, centered within
/// [maxWidth] (readable width by default, `AppLayout.wideWidth` for
/// multi-column pages).
class PageSection extends StatelessWidget {
  const PageSection({
    super.key,
    required this.children,
    this.maxWidth = AppLayout.readableWidth,
  });

  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SliverPageWidth(
      maxWidth: maxWidth,
      builder: (context, _) => SliverList.list(children: children),
    );
  }
}

/// Slivers for an [AsyncValue]: loader, error with retry, or [data].
List<Widget> asyncSlivers<T>(
  AsyncValue<T> value, {
  required List<Widget> Function(T data) data,
  VoidCallback? onRetry,
}) {
  return value.when(
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    data: data,
    loading: () => const [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    ],
    error: (e, _) => [
      SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Qualcosa è andato storto',
          message: AppException.from(e).message,
          actionLabel: onRetry == null ? null : 'Riprova',
          actionIcon: Icons.refresh_rounded,
          onAction: onRetry,
        ),
      ),
    ],
  );
}
