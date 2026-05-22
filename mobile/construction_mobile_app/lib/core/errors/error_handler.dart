import 'package:dio/dio.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handleException(dynamic e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) {
        return const AuthFailure('Your session expired. Please log in again.');
      }
      final message =
          e.response?.data?['detail'] ?? e.message ?? 'Unknown Server Error';
      return ServerFailure(message.toString());
    }
    return ServerFailure(e.toString());
  }
}
