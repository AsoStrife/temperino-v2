import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../error/app_exception.dart';

/// Thin wrapper around [Dio]: base URL, timeouts, `Authorization` header and
/// conversion of every failure into [AppException]. Screens never use dio
/// directly; only repositories use this client.
class ApiClient {
  ApiClient([Dio? dio]) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.requestTimeout,
        receiveTimeout: AppConfig.requestTimeout,
        sendTimeout: AppConfig.requestTimeout,
        responseType: ResponseType.json,
        contentType: Headers.jsonContentType,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer ${AppConfig.apiToken}';
          handler.next(options);
        },
      ),
    );
    return dio;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _run(() => _dio.get<Object?>(path, queryParameters: query));

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) =>
      _run(() => _dio.post<Object?>(path, data: body));

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) =>
      _run(() => _dio.put<Object?>(path, data: body));

  Future<Map<String, dynamic>> delete(String path) =>
      _run(() => _dio.delete<Object?>(path));

  Future<Map<String, dynamic>> _run(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      if (data == null || data == '') return const {};
      if (data is Map<String, dynamic>) return data;
      throw InvalidResponseException('Expected a JSON object, got $data');
    } catch (e) {
      throw AppException.from(e);
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
