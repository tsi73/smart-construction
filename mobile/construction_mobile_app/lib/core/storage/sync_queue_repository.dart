import 'package:construction_mobile_app/features/daily_log/domain/entities/daily_log.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_mobile_app/core/errors/failures.dart';
import 'package:construction_mobile_app/core/network/network_info.dart';
import 'package:construction_mobile_app/core/storage/sync_queue_data_source.dart';

import 'package:construction_mobile_app/features/daily_log/data/datasources/daily_log_remote_data_source.dart';

abstract class SyncQueueRepository {
  Future<Either<Failure, int>> addToQueue(SyncItem item);
  Future<Either<Failure, List<SyncItem>>> getPendingItems();
  Future<Either<Failure, void>> processQueue();
}

class SyncQueueRepositoryImpl implements SyncQueueRepository {
  final SyncQueueDataSource _localDataSource;
  final DailyLogRemoteDataSource _logRemoteDataSource;
  final NetworkInfo _networkInfo;

  SyncQueueRepositoryImpl(
      this._localDataSource, this._logRemoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, int>> addToQueue(SyncItem item) async {
    try {
      final id = await _localDataSource.addItem(item);
      return Right(id);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SyncItem>>> getPendingItems() async {
    try {
      final items = await _localDataSource.getPendingItems();
      return Right(items);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> processQueue() async {
    if (!(await _networkInfo.isConnected)) return const Left(NetworkFailure());

    final pendingResult = await getPendingItems();
    return pendingResult.fold(
      (failure) => Left(failure),
      (items) async {
        for (final item in items) {
          await _processItem(item);
        }
        return const Right(null);
      },
    );
  }

  Future<void> _processItem(SyncItem item) async {
    // Basic Idempotency: If server_id exists, we might have partially succeeded
    try {
      final updatedItem = SyncItem(
        localId: item.localId,
        serverId: item.serverId,
        entityType: item.entityType,
        operationType: item.operationType,
        projectId: item.projectId,
        taskId: item.taskId,
        payload: item.payload,
        status: 'syncing',
        attemptCount: item.attemptCount + 1,
        lastAttemptAt: DateTime.now(),
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
      );
      await _localDataSource.updateItem(updatedItem);

      if (item.entityType == 'daily_log' && item.operationType == 'create') {
        await _syncDailyLog(updatedItem);
      }

      // Mark as synced
      await _localDataSource.updateItem(SyncItem(
        localId: item.localId,
        serverId: updatedItem.serverId,
        entityType: item.entityType,
        operationType: item.operationType,
        projectId: item.projectId,
        taskId: item.taskId,
        payload: item.payload,
        status: 'synced',
        attemptCount: updatedItem.attemptCount,
        lastAttemptAt: DateTime.now(),
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      await _localDataSource.updateItem(SyncItem(
        localId: item.localId,
        serverId: item.serverId,
        entityType: item.entityType,
        operationType: item.operationType,
        projectId: item.projectId,
        taskId: item.taskId,
        payload: item.payload,
        status: 'failed',
        attemptCount: item.attemptCount + 1,
        lastAttemptAt: DateTime.now(),
        lastError: e.toString(),
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _syncDailyLog(SyncItem item) async {
    String? serverId = item.serverId;
    final payload = item.payload;

    // 1. Create Log Shell if no serverId
    if (serverId == null) {
      final data = {
        'date': payload['date'],
        'notes': payload['notes'],
        'weather': payload['weather'],
      };
      final DailyLog created;
      if (item.taskId != null) {
        created = await _logRemoteDataSource.createTaskDailyLog(
            item.projectId!, item.taskId!, data);
      } else {
        created =
            await _logRemoteDataSource.createDailyLog(item.projectId!, data);
      }
      serverId = created.id;
      // Update local storage immediately with serverId to prevent duplicate creation on next retry if sub-entities fail
      await _localDataSource.updateItem(SyncItem(
        localId: item.localId,
        serverId: serverId,
        entityType: item.entityType,
        operationType: item.operationType,
        projectId: item.projectId,
        taskId: item.taskId,
        payload: item.payload,
        status: 'syncing',
        attemptCount: item.attemptCount,
        lastAttemptAt: DateTime.now(),
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
      ));
    }

    // 2. Sync sub-entities
    if (payload['labor'] != null) {
      await _logRemoteDataSource.addLabor(
          serverId!, List<Map<String, dynamic>>.from(payload['labor']));
    }
    if (payload['materials'] != null) {
      await _logRemoteDataSource.addMaterials(
          serverId!, List<Map<String, dynamic>>.from(payload['materials']));
    }
    if (payload['equipment'] != null) {
      await _logRemoteDataSource.addEquipment(
          serverId!, List<Map<String, dynamic>>.from(payload['equipment']));
    }
    if (payload['shifts'] != null) {
      await _logRemoteDataSource.addShifts(
          serverId!, List<Map<String, dynamic>>.from(payload['shifts']));
    }
  }
}

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepositoryImpl(
    ref.watch(syncQueueDataSourceProvider),
    ref.watch(dailyLogRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});
