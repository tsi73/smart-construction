import 'package:dio/dio.dart';
import '../config/environment.dart';

class AuthErrorMessages {
  const AuthErrorMessages._();

  static String userMessage(String? message,
      {required String fallback, String context = 'auth'}) {
    final text = message?.trim();
    if (text == null || text.isEmpty) return fallback;

    final normalized = text.toLowerCase();

    // Session expired
    if (normalized.contains('session expired')) {
      return 'Session expired. Please log in again.';
    }

    // Network/connection errors
    final isConnectionFailure = normalized.contains('dioexception') ||
        normalized.contains('xmlhttprequest') ||
        normalized.contains('connection error') ||
        normalized.contains('connection errored') ||
        normalized.contains('connection refused') ||
        normalized.contains('socketexception') ||
        normalized.contains('failed host lookup') ||
        normalized.contains('network is unreachable') ||
        normalized.contains('no internet');

    if (isConnectionFailure) {
      return 'Could not reach the ConstructPro server. Make sure the backend is running at ${AppConfig.apiOrigin} and try again.';
    }

    // Timeout errors - context-specific
    if (normalized.contains('timeout') ||
        normalized.contains('deadline exceeded')) {
      switch (context) {
        case 'login':
          return 'Login is taking longer than expected. Please try again.';
        case 'register':
          return 'Registration is taking longer than expected. Please try again.';
        case 'forgot':
          return 'Password reset request is taking longer than expected. Please try again.';
        default:
          return 'Request is taking longer than expected. Please try again.';
      }
    }

    // Server errors (500)
    if (normalized.contains('500') ||
        normalized.contains('internal server error')) {
      return 'Server error. Please try again later.';
    }

    return text;
  }

  static String parseFastApiError(dynamic error, {String context = 'auth'}) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response!.data;
        // Handle {"detail":"message"}
        if (data is Map<String, dynamic> && data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) {
            return detail;
          }
          // Handle {"detail":[{"msg":"message"}]}
          if (detail is List && detail.isNotEmpty) {
            final firstItem = detail[0];
            if (firstItem is Map<String, dynamic> &&
                firstItem.containsKey('msg')) {
              return firstItem['msg'] as String;
            }
          }
        }
      }

      // Handle DioException types - context-specific
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        switch (context) {
          case 'login':
            return 'Login is taking longer than expected. Please try again.';
          case 'register':
            return 'Registration is taking longer than expected. Please try again.';
          case 'forgot':
            return 'Password reset request is taking longer than expected. Please try again.';
          default:
            return 'Request is taking longer than expected. Please try again.';
        }
      }

      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.badCertificate) {
        return 'Could not reach the ConstructPro server. Make sure the backend is running at ${AppConfig.apiOrigin} and try again.';
      }

      if (error.response?.statusCode != null) {
        final statusCode = error.response!.statusCode;
        if (statusCode! >= 500) {
          return 'Server error. Please try again later.';
        }
      }
    }

    return error.toString();
  }
}
