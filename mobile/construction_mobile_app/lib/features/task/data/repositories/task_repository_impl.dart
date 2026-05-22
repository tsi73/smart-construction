import 'package:dartz/dartz.dart' hide Task;
import 'package:construction_mobile_app/core/errors/failures.dart';
import 'package:construction_mobile_app/core/network/network_info.dart';
import 'package:construction_mobile_app/features/task/domain/entities/task.dart';
import 'package:construction_mobile_app/features/task/domain/repositories/task_repository.dart';
import 'package:construction_mobile_app/features/task/data/datasources/task_remote_data_source.dart';
import 'package:construction_mobile_app/features/task/data/datasources/task_local_data_source.dart';

import 'package:construction_mobile_app/core/errors/error_handler.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  TaskRepositoryImpl(
      this._remoteDataSource, this._localDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<Task>>> getProjectTasks(String projectId) async {
    if (await _networkInfo.isConnected) {
      try {
        final tasks = await _remoteDataSource.getProjectTasks(projectId);
        // Sort tasks chronologically by start date (or end date if start date is null)
        final sortedTasks = _sortTasksChronologically(tasks);
        await _localDataSource.cacheTasks(projectId, sortedTasks);
        return Right(sortedTasks);
      } catch (e) {
        // Fallback to cache if remote fails even when "connected" (e.g. timeout)
        final cached = await _localDataSource.getCachedTasks(projectId);
        if (cached.isNotEmpty) return Right(cached);
        return Left(ErrorHandler.handleException(e));
      }
    } else {
      try {
        final cached = await _localDataSource.getCachedTasks(projectId);
        if (cached.isNotEmpty) return Right(cached);
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  List<Task> _sortTasksChronologically(List<Task> tasks) {
    return tasks..sort((a, b) {
      // Sort by start date if both have it
      if (a.startDate != null && b.startDate != null) {
        return a.startDate!.compareTo(b.startDate!);
      }
      // Fall back to end date if start date is null for either
      if (a.endDate != null && b.endDate != null) {
        return a.endDate!.compareTo(b.endDate!);
      }
      // If no dates, sort by name as fallback
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  @override
  Future<Either<Failure, Task>> getTask(String taskId) async {
    try {
      final task = await _remoteDataSource.getTask(taskId);
      return Right(task);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(
      String projectId, Map<String, dynamic> data) async {
    try {
      final task = await _remoteDataSource.createTask(projectId, data);
      return Right(task);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(
      String taskId, Map<String, dynamic> data) async {
    try {
      final task = await _remoteDataSource.updateTask(taskId, data);
      return Right(task);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String taskId) async {
    try {
      await _remoteDataSource.deleteTask(taskId);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<TaskDependency>>> getTaskDependencies(
      String taskId) async {
    try {
      final dependencies = await _remoteDataSource.getTaskDependencies(taskId);
      return Right(dependencies);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, TaskDependency>> addTaskDependency(
      String taskId, String dependsOnTaskId) async {
    try {
      final dependency =
          await _remoteDataSource.addTaskDependency(taskId, dependsOnTaskId);
      return Right(dependency);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeTaskDependency(
      String taskId, String depId) async {
    try {
      await _remoteDataSource.removeTaskDependency(taskId, depId);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
