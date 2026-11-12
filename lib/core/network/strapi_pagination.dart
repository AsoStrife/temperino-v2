import '../config/app_config.dart';
import '../error/app_exception.dart';
import 'api_client.dart';

/// Downloads every page of a Strapi v4 collection and returns the merged
/// `data` array. Stops when `meta.pagination.page >= pageCount`.
Future<List<Map<String, dynamic>>> fetchAllPages(
  ApiClient client,
  String path, {
  Map<String, dynamic> query = const {},
}) async {
  final items = <Map<String, dynamic>>[];
  var page = 1;
  while (true) {
    final json = await client.get(
      path,
      query: {
        ...query,
        AppConfig.paginationPageParam: page,
        AppConfig.paginationPageSizeParam: AppConfig.pageSize,
      },
    );
    final data = json['data'];
    if (data is! List) {
      throw InvalidResponseException('Missing "data" array in $path');
    }
    items.addAll(data.whereType<Map<String, dynamic>>());

    final pagination = (json['meta'] as Map?)?['pagination'] as Map?;
    final pageCount = (pagination?['pageCount'] as num?)?.toInt() ?? 1;
    if (page >= pageCount) break;
    page++;
  }
  return items;
}

/// Standard list query for one year (sort fixes B10).
Map<String, dynamic> yearQuery(int year) => {
  AppConfig.filterDateGteParam: '$year-01-01',
  AppConfig.filterDateLteParam: '$year-12-31',
  AppConfig.sortQueryParam: AppConfig.sortParam,
};
