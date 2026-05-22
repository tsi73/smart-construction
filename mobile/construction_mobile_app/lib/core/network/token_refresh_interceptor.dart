import 'package:dio/dio.dart';
import '../storage/secure_token_storage.dart';
import '../config/environment.dart';
import 'package:flutter/foundation.dart';

class TokenRefreshInterceptor extends Interceptor {
  final TokenStorage _storage;
  final Dio _dio;

  TokenRefreshInterceptor(this._storage, this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.path.contains('/auth/')) {
      return super.onError(err, handler);
    }

    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Attempt to refresh token
          final refreshUrl = Uri.parse(AppConfig.baseUrl).resolve('auth/refresh').toString();
          final response = await _dio.post(
            refreshUrl,
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access_token'];
            final newRefreshToken = response.data['refresh_token'];

            await _storage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Retry the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // If refresh fails, clear tokens and throw session expired error
          await _storage.clearTokens();
          if (kDebugMode) {
            debugPrint(
                'TokenRefreshInterceptor: Refresh failed, session expired');
          }
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: err.response,
              type: err.type,
              error: 'Session expired. Please log in again.',
              message: 'Session expired. Please log in again.',
            ),
          );
        }
      } else {
        // No refresh token available, session expired
        if (kDebugMode) {
          debugPrint(
              'TokenRefreshInterceptor: No refresh token, session expired');
        }
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: err.type,
            error: 'Session expired. Please log in again.',
            message: 'Session expired. Please log in again.',
          ),
        );
      }
    }
    super.onError(err, handler);
  }
}
