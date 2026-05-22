import 'package:freezed_annotation/freezed_annotation.dart';
// ignore_for_file: invalid_annotation_target

part 'daily_log.freezed.dart';
part 'daily_log.g.dart';

@freezed
class DailyLog with _$DailyLog {
  const factory DailyLog({
    String? id,
    int? localId, // Added for offline tracking
    @JsonKey(name: 'project_id') required String projectId,
    String? taskId,
    required DateTime date,
    required String status,
    String? weather,
    required String notes,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    @JsonKey(name: 'created_by') String? createdBy,
    @Default([]) List<LogLabor> labor,
    @Default([]) List<LogMaterial> materials,
    @Default([]) List<LogEquipment> equipment,
    @Default([]) List<LogShift> shifts,
    @Default([]) @JsonKey(name: 'attachments') List<String> attachments,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'sync_status')
    @Default('synced')
    String syncStatus, // Added for UI feedback
  }) = _DailyLog;

  factory DailyLog.fromJson(Map<String, dynamic> json) =>
      _$DailyLogFromJson(json);
}

@freezed
class LogLabor with _$LogLabor {
  const factory LogLabor({
    String? id,
    @JsonKey(name: 'worker_type') required String workerType,
    @JsonKey(name: 'hours_worked') required double hoursWorked,
    required double cost,
  }) = _LogLabor;

  factory LogLabor.fromJson(Map<String, dynamic> json) =>
      _$LogLaborFromJson(json);
}

@freezed
class LogMaterial with _$LogMaterial {
  const factory LogMaterial({
    String? id,
    required String name,
    required double quantity,
    required String unit,
    required double cost,
  }) = _LogMaterial;

  factory LogMaterial.fromJson(Map<String, dynamic> json) =>
      _$LogMaterialFromJson(json);
}

@freezed
class LogEquipment with _$LogEquipment {
  const factory LogEquipment({
    String? id,
    required String name,
    @JsonKey(name: 'hours_used') required double hoursUsed,
    required double cost,
  }) = _LogEquipment;

  factory LogEquipment.fromJson(Map<String, dynamic> json) =>
      _$LogEquipmentFromJson(json);
}

@freezed
class LogShift with _$LogShift {
  const factory LogShift({
    String? id,
    @JsonKey(name: 'shift_type') required String shiftType,
  }) = _LogShift;

  factory LogShift.fromJson(Map<String, dynamic> json) =>
      _$LogShiftFromJson(json);
}
