import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';
import '../datasources/project_local_data_source.dart';
import 'package:flutter/foundation.dart';

import 'package:construction_mobile_app/core/errors/error_handler.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _remoteDataSource;
  final ProjectLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ProjectRepositoryImpl(
      this._remoteDataSource, this._localDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getProjects() async {
    if (await _networkInfo.isConnected) {
      try {
        final data = await _remoteDataSource.getProjects();
        final projects = List<Map<String, dynamic>>.from(data);

        if (kDebugMode) {
          debugPrint(
              'ProjectRepository: Fetched ${projects.length} projects from REMOTE');
        }
        await _localDataSource.cacheProjects(projects);
        return Right(projects);
      } catch (e) {
        final cached = await _localDataSource.getCachedProjects();
        if (kDebugMode) {
          debugPrint(
              'ProjectRepository: Fallback to ${cached.length} projects from CACHE due to error');
        }
        if (cached.isNotEmpty) return Right(cached);
        return Left(ErrorHandler.handleException(e));
      }
    } else {
      try {
        final cached = await _localDataSource.getCachedProjects();
        if (kDebugMode) {
          debugPrint(
              'ProjectRepository: Fetched ${cached.length} projects from CACHE (Offline)');
        }
        if (cached.isNotEmpty) return Right(cached);
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectById(
      String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final data = await _remoteDataSource.getProjectById(id);
        await _localDataSource.cacheProject(data);
        return Right(data);
      } catch (e) {
        final cached = await _localDataSource.getCachedProjectById(id);
        if (cached != null) return Right(cached);
        return Left(ErrorHandler.handleException(e));
      }
    } else {
      try {
        final cached = await _localDataSource.getCachedProjectById(id);
        if (cached != null) return Right(cached);
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createProject(
      Map<String, dynamic> projectData) async {
    if (!(await _networkInfo.isConnected)) return const Left(NetworkFailure());
    try {
      final data = await _remoteDataSource.createProject(projectData);
      return Right(data);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getProjectMembers(
      String projectId) async {
    try {
      final data = await _remoteDataSource.getProjectMembers(projectId);
      return Right(List<Map<String, dynamic>>.from(data));
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
