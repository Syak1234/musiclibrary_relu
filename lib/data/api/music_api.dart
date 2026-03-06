import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:musiclibrary_relu/core/utills/url.dart';

class _RetryInterceptor extends Interceptor {
  final Dio dio;
  _RetryInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final already = err.requestOptions.extra['_retried'] == true;
    if (!already && _retryable(err)) {
      await Future.delayed(const Duration(seconds: 1));
      try {
        final opts = err.requestOptions..extra['_retried'] = true;
        final res = await dio.fetch(opts);
        handler.resolve(res);
        return;
      } catch (_) {}
    }
    handler.next(err);
  }

  bool _retryable(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout;
}

class MusicApi {
  final Dio _dio;

  MusicApi()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiUrl.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      ) {
    _dio.interceptors.add(_RetryInterceptor(_dio));
  }

  Future<List<Map<String, dynamic>>> fetchTracks({
    required int startIndex,
    required int limit,
    String query = 'a',
  }) async {
    // log(query.toString());
    // log(startIndex.toString());
    // log(limit.toString());
    final response = await _dio.get(
      '/tracks',
      queryParameters: {'q': query, 'index': startIndex, 'limit': limit},
    );

    print(response.data.toString());
    // log(response.data.toString());
    final data = response.data as Map<String, dynamic>;
    final tracks = data['tracks'] as List<dynamic>? ?? [];
    return tracks.cast<Map<String, dynamic>>();
  }

  void dispose() {
    _dio.close();
  }
}
