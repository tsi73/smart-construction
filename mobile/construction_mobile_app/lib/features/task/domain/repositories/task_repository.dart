import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getProjectTasks(String projectId);
  Future<Either<Failure, Task>> getTask(String taskId);
  Future<Either<Failure, Task>> createTask(
      String projectId, Map<String, dynamic> data);
  Future<Either<Failure, Task>> updateTask(
      String taskId, Map<String, dynamic> data);
  Future<Either<Failure, Unit>> deleteTask(String taskId);
  Future<Either<Failure, List<TaskDependency>>> getTaskDependencies(
      String taskId);
  Future<Either<Failure, TaskDependency>> addTaskDependency(
      String taskId, String dependsOnTaskId);
  Future<Either<Failure, Unit>> removeTaskDependency(
      String taskId, String depId);
}
