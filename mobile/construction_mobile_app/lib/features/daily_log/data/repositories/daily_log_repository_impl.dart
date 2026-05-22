import 'package:dartz/dartz.dart';
import 'package:construction_mobile_app/core/errors/failures.dart';
import 'package:construction_mobile_app/core/network/network_info.dart';
import 'package:construction_mobile_app/features/daily_log/domain/entities/daily_log.dart';
import 'package:construction_mobile_app/features/daily_log/domain/repositories/daily_log_repository.dart';
import 'package:construction_mobile_app/core/storage/sync_queue_data_source.dart';
import 'package:construction_mobile_app/core/storage/sync_queue_repository.dart';
import 'package:construction_mobile_app/features/daily_log/data/datasources/daily_log_local_data_source.dart';
import 'package:construction_mobile_app/features/daily_log/data/datasources/daily_log_remote_data_source.dart';

import 'package:construction_mobile_app/core/errors/error_handler.dart';

class DailyLogRepositoryImpl implements DailyLogRepository {
  final DailyLogRemoteDataSource _remoteDataSource;
  final DailyLogLocalDataSource _localDataSource;
  final SyncQueueRepository _syncQueueRepository;
  final NetworkInfo _networkInfo;

  DailyLogRepositoryImpl(this._remoteDataSource, this._localDataSource,
      this._syncQueueRepository, this._networkInfo);

  @override
  Future<Either<Failure, List<DailyLog>>> getProjectLogs(
      String projectId) async {
    // 1. Always try to get remote logs first if online
    if (await _networkInfo.isConnected) {
      try {
        final remoteLogs = await _remoteDataSource.getProjectLogs(projectId);
        // TODO: Cache remote logs for offline viewing

        // 2. Also get local drafts
        final localDrafts = await _localDataSource.getDrafts(projectId);

        // 3. Combine them
        return Right([...localDrafts, ...remoteLogs]);
      } catch (e) {
        // Fallback to local only if remote fails
        try {
          final localDrafts = await _localDataSource.getDrafts(projectId);
          return Right(localDrafts);
        } catch (e) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      // 4. Offline: Return local drafts only (plus cached remote logs if we had them)
      try {
        final localDrafts = await _localDataSource.getDrafts(projectId);
        return Right(localDrafts);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, DailyLog>> getDailyLog(String logId) async {
    try {
      final log = await _remoteDataSource.getDailyLog(logId);
      return Right(log);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, DailyLog>> createDailyLog(DailyLog log) async {
    // If online, try to create directly
    if (await _networkInfo.isConnected) {
      try {
        final createdLog = await _syncDailyLogDirectly(log);
        return Right(createdLog);
      } catch (e) {
        // If direct creation fails, queue it
        return _queueForOffline(log);
      }
    } else {
      // Offline: Queue it
      return _queueForOffline(log);
    }
  }

  Future<DailyLog> _syncDailyLogDirectly(DailyLog log) async {
    // 1. Create the log shell
    final data = {
      'date': log.date.toIso8601String(),
      'notes': log.notes,
      'weather': log.weather,
    };
    final DailyLog createdLog;
    if (log.taskId != null) {
      createdLog = await _remoteDataSource.createTaskDailyLog(
          log.projectId, log.taskId!, data);
    } else {
      createdLog = await _remoteDataSource.createDailyLog(log.projectId, data);
    }

    // 2. Add sub-entities
    final logId = createdLog.id!;
    if (log.labor.isNotEmpty) {
      await _remoteDataSource.addLabor(
          logId, log.labor.map((e) => e.toJson()).toList());
    }
    if (log.materials.isNotEmpty) {
      await _remoteDataSource.addMaterials(
          logId, log.materials.map((e) => e.toJson()).toList());
    }
    if (log.equipment.isNotEmpty) {
      await _remoteDataSource.addEquipment(
          logId, log.equipment.map((e) => e.toJson()).toList());
    }
    if (log.shifts.isNotEmpty) {
      await _remoteDataSource.addShifts(
          logId, log.shifts.map((e) => e.toJson()).toList());
    }

    return createdLog;
  }

  Future<Either<Failure, DailyLog>> _queueForOffline(DailyLog log) async {
    try {
      // 1. Save to local drafts table (for UI visibility)
      final localId =
          await _localDataSource.saveDraft(log.copyWith(syncStatus: 'pending'));

      // 2. Add to central Sync Queue
      final syncItem = SyncItem(
        entityType: 'daily_log',
        operationType: 'create',
        projectId: log.projectId,
        taskId: log.taskId,
        payload: log.toJson(),
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _syncQueueRepository.addToQueue(syncItem);

      return Right(log.copyWith(localId: localId, syncStatus: 'pending'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitDailyLog(String logId) async {
    try {
      await _remoteDataSource.submitDailyLog(logId);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> reviewDailyLog(
      String logId, bool approved) async {
    try {
      await _remoteDataSource.reviewDailyLog(logId, approved);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> consultantApprove(String logId) async {
    try {
      await _remoteDataSource.consultantApprove(logId);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> pmApprove(String logId) async {
    try {
      await _remoteDataSource.pmApprove(logId);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectDailyLog(
      String logId, String reason) async {
    try {
      await _remoteDataSource.rejectDailyLog(logId, reason);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
