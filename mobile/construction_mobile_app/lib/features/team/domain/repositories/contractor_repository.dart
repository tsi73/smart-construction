import 'package:dartz/dartz.dart';
import 'package:construction_mobile_app/core/errors/failures.dart';
import 'package:construction_mobile_app/features/team/domain/entities/contractor.dart';

abstract class ContractorRepository {
  Future<Either<Failure, List<Contractor>>> getContractors({
    int skip = 0,
    int limit = 100,
  });
  Future<Either<Failure, Contractor>> getContractor(String contractorId);
  Future<Either<Failure, Contractor>> createContractor(String name);
  Future<Either<Failure, Contractor>> updateContractor(
      String contractorId, String? name);
  Future<Either<Failure, void>> deleteContractor(String contractorId);
}
