import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_mobile_app/features/task/domain/entities/task.dart';
import 'package:construction_mobile_app/features/task/domain/repositories/task_repository.dart';
import 'package:construction_mobile_app/features/task/data/datasources/task_remote_data_source.dart';
import 'package:construction_mobile_app/features/task/data/datasources/task_local_data_source.dart';
import 'package:construction_mobile_app/features/task/data/repositories/task_repository_impl.dart';
import 'package:construction_mobile_app/core/network/dio_client.dart';
import 'package:construction_mobile_app/core/network/network_info.dart';
import 'package:construction_mobile_app/core/notifications/notification_service.dart';
import 'package:construction_mobile_app/core/routing/route_names.dart';

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(ref.watch(dioProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    ref.watch(taskRemoteDataSourceProvider),
    ref.watch(taskLocalDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final projectTasksProvider =
    FutureProvider.family<List<Task>, String>((ref, projectId) async {
  final repository = ref.watch(taskRepositoryProvider);
  final result = await repository.getProjectTasks(projectId);
  return result.fold((l) => throw l.message, (r) => r);
});

final taskDetailProvider =
    FutureProvider.family<Task, String>((ref, taskId) async {
  final repository = ref.watch(taskRepositoryProvider);
  final result = await repository.getTask(taskId);
  return result.fold((l) => throw l.message, (r) => r);
});

final taskDependenciesProvider =
    FutureProvider.family<List<TaskDependency>, String>((ref, taskId) async {
  final repository = ref.watch(taskRepositoryProvider);
  final result = await repository.getTaskDependencies(taskId);
  return result.fold((l) => throw l.message, (r) => r);
});

class TaskController extends StateNotifier<AsyncValue<Task?>> {
  final TaskRepository _repository;
  final Ref _ref;

  TaskController(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createTask(String projectId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    final result = await _repository.createTask(projectId, data);
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) {
        // Notify assigned user
        final assignee = data['assigned_to'] as String?;
        if (assignee != null && assignee.isNotEmpty) {
          final taskName = data['name'] as String? ?? 'New Task';
          _ref.read(notificationServiceProvider.notifier).addLocal(
                type: NotificationType.taskAssigned,
                title: 'Task Assigned',
                message: 'You have been assigned to task: $taskName',
                projectId: projectId,
                taskId: r.id,
                actionRoute: '${RouteNames.tasks}/${r.id}',
              );
        }
        return AsyncValue.data(r);
      },
    );
  }

  Future<void> updateTaskProgress(String taskId, double progress) async {
    state = const AsyncValue.loading();
    final result =
        await _repository.updateTask(taskId, {'progress_percentage': progress});
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) => const AsyncValue.data(null),
    );
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    state = const AsyncValue.loading();
    final result = await _repository.updateTask(taskId, {'status': status});
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) {
        final task = state.value;
        final taskName = task?.name ?? 'Task';
        _ref.read(notificationServiceProvider.notifier).addLocal(
              type: NotificationType.taskStatusChanged,
              title: 'Task Status Changed',
              message:
                  'Task $taskName status changed to ${_statusLabel(status)}',
              taskId: taskId,
              actionRoute: '${RouteNames.tasks}/$taskId',
            );
        return const AsyncValue.data(null);
      },
    );
  }

  Future<bool> addTaskDependency(String taskId, String dependsOnTaskId) async {
    final result = await _repository.addTaskDependency(taskId, dependsOnTaskId);
    return result.fold(
      (l) => false,
      (r) => true,
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}

final taskControllerProvider =
    StateNotifierProvider<TaskController, AsyncValue<Task?>>((ref) {
  return TaskController(ref.watch(taskRepositoryProvider), ref);
});
