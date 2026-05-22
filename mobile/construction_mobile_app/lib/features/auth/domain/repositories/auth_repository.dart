import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  });

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, bool>> checkAuthStatus();

  Future<Either<Failure, Map<String, dynamic>>> getUserMe();

  Future<Either<Failure, Map<String, dynamic>>> updateProfile(
      Map<String, dynamic> userData);

  Future<Either<Failure, Unit>> forgotPassword(String email);

  Future<Either<Failure, Unit>> resetPassword({
    required String token,
    required String newPassword,
  });
}
