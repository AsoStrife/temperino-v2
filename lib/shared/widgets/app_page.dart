import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import 'empty_state.dart';

/// Main page layout: large collapsing title, optional pull-to-refresh and
/// bottom padding for the floating navigation bar.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    this.title,
    required this.slivers,
    this.actions = const [],
    this.onRefresh,
    this.bottom,
  });

  /// Large collapsing title; `null` shows a slim bar with only [actions].
  final String? title;
  final List<Widget> actions;
  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    // MediaQuery bottom padding includes the floating bar (shell extendBody).
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (title != null)
          SliverAppBar.large(
            title: Text(title!),
            actions: [...actions, const SizedBox(width: 8)],
            bottom: bottom,
          )
        else
          SliverAppBar(
            pinned: true,
            actions: [...actions, const SizedBox(width: 8)],
            bottom: bottom,
          ),
        ...slivers,
        SliverPadding(padding: EdgeInsets.only(bottom: bottomInset + 24)),
      ],
    );
    return Scaffold(
      body: onRefresh == null
          ? scroll
          : RefreshIndicator(
              onRefresh: onRefresh!,
              edgeOffset: 120,
              child: scroll,
            ),
    );
  }
}

/// Horizontal page padding for a list of box widgets.
class PageSection extends StatelessWidget {
  const PageSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.list(children: children),
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
