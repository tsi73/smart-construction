import 'package:freezed_annotation/freezed_annotation.dart';
// ignore_for_file: invalid_annotation_target

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    @JsonKey(name: 'project_id') required String projectId,
    required String name,
    String? description,
    required String status, // pending, in_progress, completed
    @JsonKey(name: 'progress_percentage')
    @Default(0.0)
    double progressPercentage,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'assigned_to') String? assignedTo,
    @JsonKey(name: 'planned_duration_days') int? plannedDurationDays,
    @JsonKey(name: 'actual_cost') double? actualCost,
    @JsonKey(name: 'planned_cost') double? plannedCost,
    @Default([])
    @JsonKey(name: 'dependencies')
    List<TaskDependency> dependencies,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

@freezed
class TaskDependency with _$TaskDependency {
  const factory TaskDependency({
    required String id,
    @JsonKey(name: 'depends_on_task_id') required String dependsOnTaskId,
    @JsonKey(name: 'depends_on_task_name') String? dependsOnTaskName,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _TaskDependency;

  factory TaskDependency.fromJson(Map<String, dynamic> json) =>
      _$TaskDependencyFromJson(json);
}
