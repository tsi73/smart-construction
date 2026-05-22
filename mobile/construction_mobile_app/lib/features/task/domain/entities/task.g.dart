// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      assignedTo: json['assigned_to'] as String?,
      plannedDurationDays: (json['planned_duration_days'] as num?)?.toInt(),
      actualCost: (json['actual_cost'] as num?)?.toDouble(),
      plannedCost: (json['planned_cost'] as num?)?.toDouble(),
      dependencies: (json['dependencies'] as List<dynamic>?)
              ?.map((e) => TaskDependency.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'name': instance.name,
      'description': instance.description,
      'status': instance.status,
      'progress_percentage': instance.progressPercentage,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'assigned_to': instance.assignedTo,
      'planned_duration_days': instance.plannedDurationDays,
      'actual_cost': instance.actualCost,
      'planned_cost': instance.plannedCost,
      'dependencies': instance.dependencies,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$TaskDependencyImpl _$$TaskDependencyImplFromJson(Map<String, dynamic> json) =>
    _$TaskDependencyImpl(
      id: json['id'] as String,
      dependsOnTaskId: json['depends_on_task_id'] as String,
      dependsOnTaskName: json['depends_on_task_name'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$TaskDependencyImplToJson(
        _$TaskDependencyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'depends_on_task_id': instance.dependsOnTaskId,
      'depends_on_task_name': instance.dependsOnTaskName,
      'created_at': instance.createdAt?.toIso8601String(),
    };
