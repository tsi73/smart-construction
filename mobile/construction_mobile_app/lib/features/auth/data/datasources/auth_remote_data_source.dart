import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData);
  Future<Map<String, dynamic>> getUserMe();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> userData);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (kDebugMode) {
      debugPrint('AuthRemoteDataSource: Login request to /auth/login');
      debugPrint('AuthRemoteDataSource: Email: $email');
    }
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (kDebugMode) {
        debugPrint('AuthRemoteDataSource: Login successful');
      }
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthRemoteDataSource: Login failed: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await _dio.post(
      '/auth/register',
      data: userData,
      options: Options(
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getUserMe() async {
    final response = await _dio.get('/users/me');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> userData) async {
    final response = await _dio.put('/users/me', data: userData);
    return response.data;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {
      'email': email,
    });
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dio.post('/auth/reset-password', data: {
      'token': token,
      'new_password': newPassword,
    });
  }
}
