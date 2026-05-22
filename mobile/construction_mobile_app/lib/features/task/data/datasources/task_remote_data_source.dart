import 'package:dio/dio.dart';
import '../../domain/entities/task.dart';

abstract class TaskRemoteDataSource {
  Future<List<Task>> getProjectTasks(String projectId);
  Future<Task> getTask(String taskId);
  Future<Task> createTask(String projectId, Map<String, dynamic> data);
  Future<Task> updateTask(String taskId, Map<String, dynamic> data);
  Future<void> deleteTask(String taskId);
  Future<List<TaskDependency>> getTaskDependencies(String taskId);
  Future<TaskDependency> addTaskDependency(
      String taskId, String dependsOnTaskId);
  Future<void> removeTaskDependency(String taskId, String depId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio _dio;

  TaskRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Task>> getProjectTasks(String projectId) async {
    final response = await _dio.get('/projects/$projectId/tasks');
    return (response.data as List).map((e) => Task.fromJson(e)).toList();
  }

  @override
  Future<Task> getTask(String taskId) async {
    final response = await _dio.get('/projects/tasks/$taskId');
    return Task.fromJson(response.data);
  }

  @override
  Future<Task> createTask(String projectId, Map<String, dynamic> data) async {
    final response = await _dio.post('/projects/$projectId/tasks', data: data);

    // Dio automatically throws for non-2xx status codes
    // If we get here, the request was successful (200 or 201)
    if (response.data != null && response.data is Map<String, dynamic>) {
      try {
        return Task.fromJson(response.data);
      } catch (e) {
        // If JSON parsing fails but status was 201, still treat as success
        return Task(
          id: response.data['id']?.toString() ?? '',
          projectId: projectId,
          name: response.data['name'] ?? data['name'] ?? 'New Task',
          status: response.data['status'] ?? data['status'] ?? 'pending',
          progressPercentage: 0.0,
        );
      }
    }

    // If response body is empty/null but status is success,
    // create a minimal task object to indicate success
    return Task(
      id: '', // Will be populated when task list is refreshed
      projectId: projectId,
      name: data['name'] ?? 'New Task',
      status: data['status'] ?? 'pending',
      progressPercentage: 0.0,
    );
  }

  @override
  Future<Task> updateTask(String taskId, Map<String, dynamic> data) async {
    final response = await _dio.put('/projects/tasks/$taskId', data: data);
    return Task.fromJson(response.data);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _dio.delete('/projects/tasks/$taskId');
  }

  @override
  Future<List<TaskDependency>> getTaskDependencies(String taskId) async {
    final response = await _dio.get('/projects/tasks/$taskId/dependencies');
    return (response.data as List)
        .map((e) => TaskDependency.fromJson(e))
        .toList();
  }

  @override
  Future<TaskDependency> addTaskDependency(
      String taskId, String dependsOnTaskId) async {
    final response = await _dio.post(
      '/projects/tasks/$taskId/dependencies',
      data: {'depends_on_task_id': dependsOnTaskId},
    );
    return TaskDependency.fromJson(response.data);
  }

  @override
  Future<void> removeTaskDependency(String taskId, String depId) async {
    await _dio.delete('/projects/tasks/$taskId/dependencies/$depId');
  }
}
