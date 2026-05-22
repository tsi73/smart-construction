import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: avoid_print
import '../config/environment.dart';
import '../storage/secure_token_storage.dart';
import 'auth_interceptor.dart';
import 'token_refresh_interceptor.dart';

class _RedactLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Log with redacted headers
    final redactedHeaders = Map<String, dynamic>.from(options.headers);
    if (redactedHeaders['Authorization'] != null) {
      redactedHeaders['Authorization'] = 'Bearer [REDACTED]';
    }
    if (redactedHeaders['authorization'] != null) {
      redactedHeaders['authorization'] = 'Bearer [REDACTED]';
    }

    print('DIO: ${options.method} ${options.uri}');
    print('DIO: Headers: $redactedHeaders');

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
        'DIO: Error on ${err.requestOptions.method} ${err.requestOptions.uri}');
    print('DIO: Error type: ${err.type}');
    print('DIO: Error message: ${err.message}');
    if (err.response != null) {
      print('DIO: Response status: ${err.response?.statusCode}');
      print('DIO: Response data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        'DIO: Response ${response.statusCode} from ${response.requestOptions.uri}');
    super.onResponse(response, handler);
  }
}

class _NormalizePathInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    // Only strip leading slashes for relative paths (not full URLs)
    if (path.startsWith('/') && !path.startsWith('http')) {
      options.path = path.substring(1);
    }
    super.onRequest(options, handler);
  }
}

class _LocalLoopbackFallbackInterceptor extends Interceptor {
  final Dio _dio;

  _LocalLoopbackFallbackInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!kIsWeb || !_shouldRetry(err)) {
      return super.onError(err, handler);
    }

    final original = err.requestOptions;
    if (original.extra['skipLoopbackFallback'] == true) {
      return super.onError(err, handler);
    }

    if (original.extra['loopbackFallbackTried'] == true) {
      return super.onError(err, handler);
    }

    final uri = original.uri;
    if (uri.host != '127.0.0.1' && uri.host != 'localhost') {
      return super.onError(err, handler);
    }

    final fallbackHost = uri.host == '127.0.0.1' ? 'localhost' : '127.0.0.1';
    final fallbackUri = uri.replace(host: fallbackHost);
    final retryOptions = original.copyWith(
      path: fallbackUri.path,
      queryParameters: Map<String, dynamic>.from(fallbackUri.queryParameters),
      extra: {
        ...original.extra,
        'loopbackFallbackTried': true,
      },
    );

    try {
      final response = await _dio.fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } catch (_) {
      return super.onError(err, handler);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown;
  }
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final storage = ref.watch(secureTokenStorageProvider);

  dio.interceptors.addAll([
    AuthInterceptor(storage),
    _NormalizePathInterceptor(),
    _LocalLoopbackFallbackInterceptor(dio),
    TokenRefreshInterceptor(storage, dio),
    _RedactLogInterceptor(),
  ]);

  return dio;
});
