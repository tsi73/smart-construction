// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyLogImpl _$$DailyLogImplFromJson(Map<String, dynamic> json) =>
    _$DailyLogImpl(
      id: json['id'] as String?,
      localId: (json['localId'] as num?)?.toInt(),
      projectId: json['project_id'] as String,
      taskId: json['taskId'] as String?,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      weather: json['weather'] as String?,
      notes: json['notes'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      createdBy: json['created_by'] as String?,
      labor: (json['labor'] as List<dynamic>?)
              ?.map((e) => LogLabor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      materials: (json['materials'] as List<dynamic>?)
              ?.map((e) => LogMaterial.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      equipment: (json['equipment'] as List<dynamic>?)
              ?.map((e) => LogEquipment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      shifts: (json['shifts'] as List<dynamic>?)
              ?.map((e) => LogShift.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      syncStatus: json['sync_status'] as String? ?? 'synced',
    );

Map<String, dynamic> _$$DailyLogImplToJson(_$DailyLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'localId': instance.localId,
      'project_id': instance.projectId,
      'taskId': instance.taskId,
      'date': instance.date.toIso8601String(),
      'status': instance.status,
      'weather': instance.weather,
      'notes': instance.notes,
      'rejection_reason': instance.rejectionReason,
      'created_by': instance.createdBy,
      'labor': instance.labor,
      'materials': instance.materials,
      'equipment': instance.equipment,
      'shifts': instance.shifts,
      'attachments': instance.attachments,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'sync_status': instance.syncStatus,
    };

_$LogLaborImpl _$$LogLaborImplFromJson(Map<String, dynamic> json) =>
    _$LogLaborImpl(
      id: json['id'] as String?,
      workerType: json['worker_type'] as String,
      hoursWorked: (json['hours_worked'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
    );

Map<String, dynamic> _$$LogLaborImplToJson(_$LogLaborImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'worker_type': instance.workerType,
      'hours_worked': instance.hoursWorked,
      'cost': instance.cost,
    };

_$LogMaterialImpl _$$LogMaterialImplFromJson(Map<String, dynamic> json) =>
    _$LogMaterialImpl(
      id: json['id'] as String?,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      cost: (json['cost'] as num).toDouble(),
    );

Map<String, dynamic> _$$LogMaterialImplToJson(_$LogMaterialImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'cost': instance.cost,
    };

_$LogEquipmentImpl _$$LogEquipmentImplFromJson(Map<String, dynamic> json) =>
    _$LogEquipmentImpl(
      id: json['id'] as String?,
      name: json['name'] as String,
      hoursUsed: (json['hours_used'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
    );

Map<String, dynamic> _$$LogEquipmentImplToJson(_$LogEquipmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hours_used': instance.hoursUsed,
      'cost': instance.cost,
    };

_$LogShiftImpl _$$LogShiftImplFromJson(Map<String, dynamic> json) =>
    _$LogShiftImpl(
      id: json['id'] as String?,
      shiftType: json['shift_type'] as String,
    );

Map<String, dynamic> _$$LogShiftImplToJson(_$LogShiftImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shift_type': instance.shiftType,
    };
