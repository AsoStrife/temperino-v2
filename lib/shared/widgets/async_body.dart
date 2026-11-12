import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import 'empty_state.dart';

/// Loading / error / content switch for an [AsyncValue] in non-sliver
/// layouts. While reloading with previous data, the content stays visible.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (data) => builder(context, data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Qualcosa è andato storto',
        message: AppException.from(error).message,
        actionLabel: onRetry == null ? null : 'Riprova',
        actionIcon: Icons.refresh_rounded,
        onAction: onRetry,
      ),
    );
  }
}

/// Small inline loader for tiles/charts.
class InlineLoader extends StatelessWidget {
  const InlineLoader({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: const Center(child: CircularProgressIndicator()),
  );
}
