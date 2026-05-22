import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _storage;

  AuthInterceptor(this._storage);

  // Auth endpoints that should not include Authorization header
  static const _authEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/refresh',
  ];

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Don't add Authorization header to auth endpoints
    final isAuthEndpoint =
        _authEndpoints.any((endpoint) => options.path.contains(endpoint));

    if (!isAuthEndpoint) {
      final token = await _storage.getAccessToken();
      if (kDebugMode) {
        debugPrint('AuthInterceptor: Request to ${options.path}');
        debugPrint('AuthInterceptor: Token available: ${token != null}');
      }
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } else {
      if (kDebugMode) {
        debugPrint('AuthInterceptor: Skipping auth header for ${options.path}');
      }
    }
    super.onRequest(options, handler);
  }
}
