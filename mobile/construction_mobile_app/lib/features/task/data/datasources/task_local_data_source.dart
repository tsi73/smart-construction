import '../../../../core/storage/app_local_storage.dart';
import '../../domain/entities/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

abstract class TaskLocalDataSource {
  Future<void> cacheTasks(String projectId, List<Task> tasks);
  Future<List<Task>> getCachedTasks(String projectId);
  Future<void> clearCache(String projectId);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final AppLocalStorage _storage;

  TaskLocalDataSourceImpl(this._storage);

  @override
  Future<void> cacheTasks(String projectId, List<Task> tasks) async {
    final taskMaps = tasks
        .map((t) => {
              'id': t.id,
              'project_id': t.projectId,
              'name': t.name,
              'description': t.description,
              'status': t.status,
              'progress_percentage': t.progressPercentage,
              'start_date': t.startDate?.toIso8601String(),
              'end_date': t.endDate?.toIso8601String(),
              'assigned_to': t.assignedTo,
              'planned_duration_days': t.plannedDurationDays,
              'actual_cost': t.actualCost,
              'planned_cost': t.plannedCost,
              'dependencies_json': jsonEncode(t.dependencies.map((d) => d.toJson()).toList()),
              'created_at': t.createdAt?.toIso8601String(),
              'updated_at': t.updatedAt?.toIso8601String(),
            })
        .toList();
    await _storage.cacheTasks(projectId, taskMaps);
  }

  @override
  Future<List<Task>> getCachedTasks(String projectId) async {
    final List<dynamic> maps = await _storage.getCachedTasks(projectId);
    return maps.map<Task>((map) {
      // Parse dependencies from JSON
      List<TaskDependency> dependencies = [];
      if (map['dependencies_json'] != null) {
        try {
          final List<dynamic> depsJson = jsonDecode(map['dependencies_json'] as String);
          dependencies = depsJson
              .map((d) => TaskDependency.fromJson(d as Map<String, dynamic>))
              .toList();
        } catch (e) {
          // If JSON parsing fails, use empty list
          dependencies = [];
        }
      }

      return Task(
        id: map['id'] as String,
        projectId: map['project_id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        status: map['status'] as String,
        progressPercentage:
            (map['progress_percentage'] as num?)?.toDouble() ?? 0.0,
        startDate: map['start_date'] != null
            ? DateTime.parse(map['start_date'] as String)
            : null,
        endDate: map['end_date'] != null
            ? DateTime.parse(map['end_date'] as String)
            : null,
        assignedTo: map['assigned_to'] as String?,
        plannedDurationDays: map['planned_duration_days'] as int?,
        actualCost: (map['actual_cost'] as num?)?.toDouble(),
        plannedCost: (map['planned_cost'] as num?)?.toDouble(),
        dependencies: dependencies,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      );
    }).toList();
  }

  @override
  Future<void> clearCache(String projectId) async {
    await _storage.cacheTasks(projectId, []);
  }
}

final taskLocalDataSourceProvider = Provider<TaskLocalDataSource>((ref) {
  return TaskLocalDataSourceImpl(ref.watch(appLocalStorageProvider));
});
