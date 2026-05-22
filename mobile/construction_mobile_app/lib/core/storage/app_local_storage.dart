import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_service.dart';

abstract class AppLocalStorage {
  Future<void> init();
  bool get supportsFullOfflineSync;

  // Projects
  Future<void> cacheProjects(
      String userId, List<Map<String, dynamic>> projects);
  Future<List<Map<String, dynamic>>> getCachedProjects(String userId);
  Future<void> clearProjectsCache();

  // Tasks
  Future<void> cacheTasks(String projectId, List<dynamic> tasks);
  Future<List<dynamic>> getCachedTasks(String projectId);
  Future<void> clearTasksCache();

  // Daily Logs
  Future<void> cacheDailyLogs(String projectId, List<dynamic> logs);
  Future<List<dynamic>> getCachedDailyLogs(String projectId);
  Future<int> saveDailyLogDraft(Map<String, dynamic> log);
  Future<List<Map<String, dynamic>>> getDailyLogDrafts(String projectId);

  Future<void> updateDailyLogDraft(int localId, Map<String, dynamic> data);
  Future<void> deleteDailyLogDraft(int localId);

  // Sync Queue
  Future<int> addToSyncQueue(Map<String, dynamic> item);
  Future<List<Map<String, dynamic>>> getPendingSyncItems();
  Future<void> updateSyncItem(Map<String, dynamic> item);
  Future<void> deleteSyncItem(int localId);

  // Clear all user data (for logout/account switch)
  Future<void> clearAllUserData();
}

class SqliteAppLocalStorage implements AppLocalStorage {
  final DatabaseService _dbService;
  SqliteAppLocalStorage(this._dbService);

  @override
  Future<void> init() async {
    await _dbService.database;
  }
  
  // Helper method to filter project fields
  Map<String, dynamic> _filterProjectFields(Map<String, dynamic> project) {
    const allowedProjectFields = {
      'id', 'name', 'description', 'client_name', 'client_email', 
      'client_id', 'location', 'total_budget', 'budget_spent', 
      'progress_percentage', 'status', 'role', 'owner_id', 
      'planned_start_date', 'planned_end_date', 'created_at', 'updated_at'
    };
    
    final filtered = <String, dynamic>{};
    for (final key in project.keys) {
      if (allowedProjectFields.contains(key)) {
        filtered[key] = project[key];
      }
    }
    return filtered;
  }
  
  // Helper method to filter task fields
  Map<String, dynamic> _filterTaskFields(Map<String, dynamic> task) {
    const allowedTaskFields = {
      'id', 'project_id', 'name', 'description', 'status', 
      'progress_percentage', 'start_date', 'end_date', 'assigned_to',
      'planned_duration_days', 'actual_cost', 'planned_cost', 
      'dependencies_json', 'created_at', 'updated_at'
    };
    
    final filtered = <String, dynamic>{};
    for (final key in task.keys) {
      if (allowedTaskFields.contains(key)) {
        filtered[key] = task[key];
      }
    }
    return filtered;
  }

  @override
  bool get supportsFullOfflineSync => true;

  @override
  Future<void> cacheProjects(
      String userId, List<Map<String, dynamic>> projects) async {
    final db = await _dbService.database;
    
    await db.transaction((txn) async {
      // Delete existing projects for this user
      await txn
          .delete('projects_cache', where: 'user_id = ?', whereArgs: [userId]);
      for (final p in projects) {
        final filteredProject = _filterProjectFields(p);
        // Add system fields
        filteredProject['user_id'] = userId;
        filteredProject['cached_at'] = DateTime.now().toIso8601String();
        
        await txn.insert('projects_cache', filteredProject);
      }
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedProjects(String userId) async {
    final db = await _dbService.database;
    return await db.query('projects_cache',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'name ASC');
  }

  @override
  Future<void> clearProjectsCache() async {
    final db = await _dbService.database;
    await db.delete('projects_cache');
  }

  @override
  Future<void> cacheTasks(String projectId, List<dynamic> tasks) async {
    final db = await _dbService.database;
    
    await db.transaction((txn) async {
      await txn.delete('tasks_cache',
          where: 'project_id = ?', whereArgs: [projectId]);
      for (final t in tasks) {
        final filteredTask = _filterTaskFields(t as Map<String, dynamic>);
        // Add system field
        filteredTask['cached_at'] = DateTime.now().toIso8601String();
        
        await txn.insert('tasks_cache', filteredTask);
      }
    });
  }

  @override
  Future<List<dynamic>> getCachedTasks(String projectId) async {
    final db = await _dbService.database;
    return await db
        .query('tasks_cache', where: 'project_id = ?', whereArgs: [projectId]);
  }

  @override
  Future<void> clearTasksCache() async {
    final db = await _dbService.database;
    await db.delete('tasks_cache');
  }

  @override
  Future<void> cacheDailyLogs(String projectId, List<dynamic> logs) async {
    // Implementation for caching daily logs (remote logs for offline viewing)
  }

  @override
  Future<List<dynamic>> getCachedDailyLogs(String projectId) async {
    return [];
  }

  @override
  Future<int> saveDailyLogDraft(Map<String, dynamic> log) async {
    final db = await _dbService.database;
    return await db.insert('daily_log_drafts', log);
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyLogDrafts(String projectId) async {
    final db = await _dbService.database;
    return await db.query('daily_log_drafts',
        where: 'project_id = ?', whereArgs: [projectId]);
  }

  @override
  Future<void> updateDailyLogDraft(
      int localId, Map<String, dynamic> data) async {
    final db = await _dbService.database;
    await db.update('daily_log_drafts', data,
        where: 'local_id = ?', whereArgs: [localId]);
  }

  @override
  Future<void> deleteDailyLogDraft(int localId) async {
    final db = await _dbService.database;
    await db.delete('daily_log_drafts',
        where: 'local_id = ?', whereArgs: [localId]);
  }

  @override
  Future<int> addToSyncQueue(Map<String, dynamic> item) async {
    final db = await _dbService.database;
    return await db.insert('sync_queue', item);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await _dbService.database;
    return await db.query('sync_queue',
        where: 'status IN (?, ?)', whereArgs: ['pending', 'failed']);
  }

  @override
  Future<void> updateSyncItem(Map<String, dynamic> item) async {
    final db = await _dbService.database;
    await db.update('sync_queue', item,
        where: 'local_id = ?', whereArgs: [item['local_id']]);
  }

  @override
  Future<void> deleteSyncItem(int localId) async {
    final db = await _dbService.database;
    await db.delete('sync_queue', where: 'local_id = ?', whereArgs: [localId]);
  }

  @override
  Future<void> clearAllUserData() async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      await txn.delete('projects_cache');
      await txn.delete('tasks_cache');
      await txn.delete('daily_log_drafts');
      // Note: We keep sync_queue as it may contain pending operations
    });
  }
}

class WebAppLocalStorageFallback implements AppLocalStorage {
  final Map<String, List<dynamic>> _memoryCache = {};

  @override
  Future<void> init() async {
    debugPrint('WebAppLocalStorageFallback: Initialized (In-memory)');
  }

  @override
  bool get supportsFullOfflineSync => false;

  @override
  Future<void> cacheProjects(
      String userId, List<Map<String, dynamic>> projects) async {
    _memoryCache['projects_$userId'] = projects;
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedProjects(String userId) async {
    return List<Map<String, dynamic>>.from(
        _memoryCache['projects_$userId'] ?? []);
  }

  @override
  Future<void> clearProjectsCache() async {
    _memoryCache.keys
        .where((key) => key.startsWith('projects_'))
        .toList()
        .forEach((key) {
      _memoryCache.remove(key);
    });
  }

  @override
  Future<void> cacheTasks(String projectId, List<dynamic> tasks) async {
    _memoryCache['tasks_$projectId'] = tasks;
  }

  @override
  Future<List<dynamic>> getCachedTasks(String projectId) async {
    return _memoryCache['tasks_$projectId'] ?? [];
  }

  @override
  Future<void> clearTasksCache() async {
    _memoryCache.keys
        .where((key) => key.startsWith('tasks_'))
        .toList()
        .forEach((key) {
      _memoryCache.remove(key);
    });
  }

  @override
  Future<void> cacheDailyLogs(String projectId, List<dynamic> logs) async {
    _memoryCache['logs_$projectId'] = logs;
  }

  @override
  Future<List<dynamic>> getCachedDailyLogs(String projectId) async {
    return _memoryCache['logs_$projectId'] ?? [];
  }

  @override
  Future<int> saveDailyLogDraft(Map<String, dynamic> log) async {
    final drafts = _memoryCache['daily_log_drafts'] ?? [];
    final id = drafts.length + 1;
    drafts.add({...log, 'local_id': id});
    _memoryCache['daily_log_drafts'] = drafts;
    return id;
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyLogDrafts(String projectId) async {
    final drafts = _memoryCache['daily_log_drafts'] ?? [];
    return drafts
        .where((d) => d['project_id'] == projectId)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<void> updateDailyLogDraft(
      int localId, Map<String, dynamic> data) async {
    final drafts = _memoryCache['daily_log_drafts'] ?? [];
    final index = drafts.indexWhere((d) => d['local_id'] == localId);
    if (index != -1) {
      drafts[index] = {...drafts[index], ...data};
    }
  }

  @override
  Future<void> deleteDailyLogDraft(int localId) async {
    final drafts = _memoryCache['daily_log_drafts'] ?? [];
    drafts.removeWhere((d) => d['local_id'] == localId);
  }

  @override
  Future<int> addToSyncQueue(Map<String, dynamic> item) async {
    final queue = _memoryCache['sync_queue'] ?? [];
    final id = queue.length + 1;
    queue.add({...item, 'local_id': id});
    _memoryCache['sync_queue'] = queue;
    return id;
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final queue = _memoryCache['sync_queue'] ?? [];
    return queue
        .where((i) => i['status'] == 'pending' || i['status'] == 'failed')
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  @override
  Future<void> updateSyncItem(Map<String, dynamic> item) async {
    final queue = _memoryCache['sync_queue'] ?? [];
    final index = queue.indexWhere((i) => i['local_id'] == item['local_id']);
    if (index != -1) {
      queue[index] = item;
    }
  }

  @override
  Future<void> deleteSyncItem(int localId) async {
    final queue = _memoryCache['sync_queue'] ?? [];
    queue.removeWhere((i) => i['local_id'] == localId);
  }

  @override
  Future<void> clearAllUserData() async {
    _memoryCache.keys
        .where((key) => key.startsWith('projects_'))
        .toList()
        .forEach((key) {
      _memoryCache.remove(key);
    });
    _memoryCache.keys
        .where((key) => key.startsWith('tasks_'))
        .toList()
        .forEach((key) {
      _memoryCache.remove(key);
    });
    _memoryCache.keys
        .where((key) => key.startsWith('logs_'))
        .toList()
        .forEach((key) {
      _memoryCache.remove(key);
    });
    _memoryCache.remove('daily_log_drafts');
    // Note: We keep sync_queue as it may contain pending operations
  }
}

final appLocalStorageProvider = Provider<AppLocalStorage>((ref) {
  if (kIsWeb) {
    return WebAppLocalStorageFallback();
  }
  return SqliteAppLocalStorage(ref.watch(databaseServiceProvider));
});
