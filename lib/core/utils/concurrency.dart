/// Runs [task] for each item with at most [limit] tasks in flight and returns
/// the results in the same order as [items].
Future<List<R>> mapWithConcurrency<T, R>(
  List<T> items,
  int limit,
  Future<R> Function(T item) task,
) async {
  final results = List<R?>.filled(items.length, null);
  var next = 0;

  Future<void> worker() async {
    while (next < items.length) {
      final index = next++;
      results[index] = await task(items[index]);
    }
  }

  final workers = List.generate(
    limit < items.length ? limit : items.length,
    (_) => worker(),
  );
  await Future.wait(workers);
  return results.cast<R>();
}
