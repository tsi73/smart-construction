import 'dart:convert';
import '../../../../core/storage/app_local_storage.dart';
import '../../domain/entities/daily_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class DailyLogLocalDataSource {
  Future<int> saveDraft(DailyLog log);
  Future<List<DailyLog>> getDrafts(String projectId);
  Future<void> deleteDraft(int localId);
  Future<void> updateSyncStatus(int localId, String status,
      {String? serverId, String? error});
  Future<void> cacheLogs(String projectId, List<DailyLog> logs);
}

class DailyLogLocalDataSourceImpl implements DailyLogLocalDataSource {
  final AppLocalStorage _storage;

  DailyLogLocalDataSourceImpl(this._storage);

  @override
  Future<int> saveDraft(DailyLog log) async {
    final map = {
      'project_id': log.projectId,
      'task_id': log.taskId,
      'date': log.date.toIso8601String(),
      'weather': log.weather,
      'notes': log.notes,
      'status': log.status,
      'labor_json': jsonEncode(log.labor.map((e) => e.toJson()).toList()),
      'materials_json':
          jsonEncode(log.materials.map((e) => e.toJson()).toList()),
      'equipment_json':
          jsonEncode(log.equipment.map((e) => e.toJson()).toList()),
      'shifts_json': jsonEncode(log.shifts.map((e) => e.toJson()).toList()),
      'sync_status': log.syncStatus,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    return await _storage.saveDailyLogDraft(map);
  }

  @override
  Future<List<DailyLog>> getDrafts(String projectId) async {
    final List<Map<String, dynamic>> maps =
        await _storage.getDailyLogDrafts(projectId);

    return maps.map((map) {
      return DailyLog(
        id: map['server_id'],
        localId: map['local_id'],
        projectId: map['project_id'],
        taskId: map['task_id'],
        date: DateTime.parse(map['date']),
        weather: map['weather'],
        notes: map['notes'],
        status: map['status'],
        labor: (jsonDecode(map['labor_json'] ?? '[]') as List)
            .map((e) => LogLabor.fromJson(e))
            .toList(),
        materials: (jsonDecode(map['materials_json'] ?? '[]') as List)
            .map((e) => LogMaterial.fromJson(e))
            .toList(),
        equipment: (jsonDecode(map['equipment_json'] ?? '[]') as List)
            .map((e) => LogEquipment.fromJson(e))
            .toList(),
        shifts: (jsonDecode(map['shifts_json'] ?? '[]') as List)
            .map((e) => LogShift.fromJson(e))
            .toList(),
        syncStatus: map['sync_status'] ?? 'synced',
      );
    }).toList();
  }

  @override
  Future<void> deleteDraft(int localId) async {
    await _storage.deleteDailyLogDraft(localId);
  }

  @override
  Future<void> updateSyncStatus(int localId, String status,
      {String? serverId, String? error}) async {
    await _storage.updateDailyLogDraft(localId, {
      'sync_status': status,
      if (serverId != null) 'server_id': serverId,
      if (error != null) 'last_error': error,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> cacheLogs(String projectId, List<DailyLog> logs) async {
    await _storage.cacheDailyLogs(
        projectId, logs.map((l) => l.toJson()).toList());
  }
}

final dailyLogLocalDataSourceProvider =
    Provider<DailyLogLocalDataSource>((ref) {
  return DailyLogLocalDataSourceImpl(ref.watch(appLocalStorageProvider));
});
