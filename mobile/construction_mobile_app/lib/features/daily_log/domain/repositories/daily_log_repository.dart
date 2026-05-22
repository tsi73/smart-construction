import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/daily_log.dart';

abstract class DailyLogRepository {
  Future<Either<Failure, List<DailyLog>>> getProjectLogs(String projectId);
  Future<Either<Failure, DailyLog>> getDailyLog(String logId);
  Future<Either<Failure, DailyLog>> createDailyLog(DailyLog log);
  Future<Either<Failure, Unit>> submitDailyLog(String logId);
  Future<Either<Failure, Unit>> reviewDailyLog(String logId, bool approved);
  Future<Either<Failure, Unit>> consultantApprove(String logId);
  Future<Either<Failure, Unit>> pmApprove(String logId);
  Future<Either<Failure, Unit>> rejectDailyLog(String logId, String reason);
}
