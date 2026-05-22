import '../../../../core/storage/app_local_storage.dart';
import '../../../../core/storage/secure_token_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ProjectLocalDataSource {
  Future<void> cacheProjects(List<Map<String, dynamic>> projects);
  Future<List<Map<String, dynamic>>> getCachedProjects();
  Future<void> cacheProject(Map<String, dynamic> project);
  Future<Map<String, dynamic>?> getCachedProjectById(String id);
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final AppLocalStorage _storage;
  final TokenStorage _tokenStorage;

  ProjectLocalDataSourceImpl(this._storage, this._tokenStorage);

  @override
  Future<void> cacheProjects(List<Map<String, dynamic>> projects) async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null) {
      debugPrint('ProjectLocalDataSource: User ID not found, skipping cache');
      return;
    }
    await _storage.cacheProjects(userId, projects);
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedProjects() async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null) {
      debugPrint(
          'ProjectLocalDataSource: User ID not found, returning empty list');
      return [];
    }
    return await _storage.getCachedProjects(userId);
  }

  @override
  Future<void> cacheProject(Map<String, dynamic> project) async {
    // For single project caching, we can just update the list for now
    final userId = await _tokenStorage.getUserId();
    if (userId == null) {
      debugPrint('ProjectLocalDataSource: User ID not found, skipping cache');
      return;
    }
    final existing = await _storage.getCachedProjects(userId);
    final index = existing.indexWhere((p) => p['id'] == project['id']);
    if (index != -1) {
      existing[index] = project;
    } else {
      existing.add(project);
    }
    await _storage.cacheProjects(userId, existing);
  }

  @override
  Future<Map<String, dynamic>?> getCachedProjectById(String id) async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null) {
      debugPrint('ProjectLocalDataSource: User ID not found, returning null');
      return null;
    }
    final projects = await _storage.getCachedProjects(userId);
    return projects.firstWhere((p) => p['id'] == id, orElse: () => {});
  }
}

final projectLocalDataSourceProvider = Provider<ProjectLocalDataSource>((ref) {
  return ProjectLocalDataSourceImpl(
    ref.watch(appLocalStorageProvider),
    ref.watch(secureTokenStorageProvider),
  );
});
