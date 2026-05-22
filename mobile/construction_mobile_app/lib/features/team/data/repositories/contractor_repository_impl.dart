import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_mobile_app/core/errors/failures.dart';
import 'package:construction_mobile_app/core/network/dio_client.dart';
import 'package:construction_mobile_app/core/utils/auth_error_messages.dart';
import 'package:construction_mobile_app/features/team/domain/repositories/contractor_repository.dart';
import 'package:construction_mobile_app/features/team/data/datasources/contractor_remote_data_source.dart';
import 'package:construction_mobile_app/features/team/domain/entities/contractor.dart';

class ContractorRepositoryImpl implements ContractorRepository {
  final ContractorRemoteDataSource _dataSource;

  ContractorRepositoryImpl(this._dataSource);

  Contractor _mapContractor(Map<String, dynamic> m) {
    return Contractor(
      id: m['id']?.toString() ?? '',
      name: m['name']?.toString() ?? '',
    );
  }

  @override
  Future<Either<Failure, List<Contractor>>> getContractors({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final list = await _dataSource.getContractors(skip: skip, limit: limit);
      return Right(list.map(_mapContractor).toList());
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'contractor');
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, Contractor>> getContractor(String contractorId) async {
    try {
      final m = await _dataSource.getContractor(contractorId);
      return Right(_mapContractor(m));
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'contractor');
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, Contractor>> createContractor(String name) async {
    try {
      final m = await _dataSource.createContractor(name);
      return Right(_mapContractor(m));
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'contractor');
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, Contractor>> updateContractor(
      String contractorId, String? name) async {
    try {
      final m = await _dataSource.updateContractor(contractorId, name);
      return Right(_mapContractor(m));
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'contractor');
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContractor(String contractorId) async {
    try {
      await _dataSource.deleteContractor(contractorId);
      return const Right(null);
    } catch (e) {
      final errorMessage =
          AuthErrorMessages.parseFastApiError(e, context: 'contractor');
      return Left(ServerFailure(errorMessage));
    }
  }
}

final contractorRemoteDataSourceProvider =
    Provider<ContractorRemoteDataSource>((ref) {
  return ContractorRemoteDataSourceImpl(ref.watch(dioProvider));
});

final contractorRepositoryProvider = Provider<ContractorRepository>((ref) {
  return ContractorRepositoryImpl(
      ref.watch(contractorRemoteDataSourceProvider));
});
