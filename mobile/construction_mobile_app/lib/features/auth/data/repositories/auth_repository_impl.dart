import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../../../core/utils/auth_error_messages.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _storage;

  AuthRepositoryImpl(this._remoteDataSource, this._storage);

  @override
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _remoteDataSource.login(email, password);
      await _storage.saveTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );
      return const Right(unit);
    } catch (e) {
      final errorMessage = AuthErrorMessages.parseFastApiError(e);
      return Left(AuthFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, Unit>> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      await _remoteDataSource.register({
        'full_name': fullName,
        'email': email,
        'password': password,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      });
      // Usually register might also return tokens or require login
      return const Right(unit);
    } catch (e) {
      final errorMessage = AuthErrorMessages.parseFastApiError(e);
      return Left(AuthFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await _storage.clearTokens();
    return const Right(unit);
  }

  @override
  Future<Either<Failure, bool>> checkAuthStatus() async {
    final token = await _storage.getAccessToken();
    return Right(token != null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserMe() async {
    try {
      final data = await _remoteDataSource.getUserMe();
      return Right(data);
    } catch (e) {
      final errorMessage = AuthErrorMessages.parseFastApiError(e);
      return Left(AuthFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateProfile(
      Map<String, dynamic> userData) async {
    try {
      final data = await _remoteDataSource.updateProfile(userData);
      return Right(data);
    } catch (e) {
      final errorMessage = AuthErrorMessages.parseFastApiError(e);
      return Left(AuthFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return const Right(unit);
    } catch (e) {
      final errorMessage = AuthErrorMessages.parseFastApiError(e);
      return Left(AuthFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(unit);
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'reset');
      return Left(AuthFailure(errorMessage));
    }
  }
}
