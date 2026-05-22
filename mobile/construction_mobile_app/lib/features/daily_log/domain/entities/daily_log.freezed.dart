// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyLog _$DailyLogFromJson(Map<String, dynamic> json) {
  return _DailyLog.fromJson(json);
}

/// @nodoc
mixin _$DailyLog {
  String? get id => throw _privateConstructorUsedError;
  int? get localId =>
      throw _privateConstructorUsedError; // Added for offline tracking
  @JsonKey(name: 'project_id')
  String get projectId => throw _privateConstructorUsedError;
  String? get taskId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get weather => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String? get createdBy => throw _privateConstructorUsedError;
  List<LogLabor> get labor => throw _privateConstructorUsedError;
  List<LogMaterial> get materials => throw _privateConstructorUsedError;
  List<LogEquipment> get equipment => throw _privateConstructorUsedError;
  List<LogShift> get shifts => throw _privateConstructorUsedError;
  @JsonKey(name: 'attachments')
  List<String> get attachments => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'sync_status')
  String get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this DailyLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyLogCopyWith<DailyLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyLogCopyWith<$Res> {
  factory $DailyLogCopyWith(DailyLog value, $Res Function(DailyLog) then) =
      _$DailyLogCopyWithImpl<$Res, DailyLog>;
  @useResult
  $Res call(
      {String? id,
      int? localId,
      @JsonKey(name: 'project_id') String projectId,
      String? taskId,
      DateTime date,
      String status,
      String? weather,
      String notes,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      @JsonKey(name: 'created_by') String? createdBy,
      List<LogLabor> labor,
      List<LogMaterial> materials,
      List<LogEquipment> equipment,
      List<LogShift> shifts,
      @JsonKey(name: 'attachments') List<String> attachments,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'sync_status') String syncStatus});
}

/// @nodoc
class _$DailyLogCopyWithImpl<$Res, $Val extends DailyLog>
    implements $DailyLogCopyWith<$Res> {
  _$DailyLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? localId = freezed,
    Object? projectId = null,
    Object? taskId = freezed,
    Object? date = null,
    Object? status = null,
    Object? weather = freezed,
    Object? notes = null,
    Object? rejectionReason = freezed,
    Object? createdBy = freezed,
    Object? labor = null,
    Object? materials = null,
    Object? equipment = null,
    Object? shifts = null,
    Object? attachments = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? syncStatus = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      localId: freezed == localId
          ? _value.localId
          : localId // ignore: cast_nullable_to_non_nullable
              as int?,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: freezed == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      weather: freezed == weather
          ? _value.weather
          : weather // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      labor: null == labor
          ? _value.labor
          : labor // ignore: cast_nullable_to_non_nullable
              as List<LogLabor>,
      materials: null == materials
          ? _value.materials
          : materials // ignore: cast_nullable_to_non_nullable
              as List<LogMaterial>,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<LogEquipment>,
      shifts: null == shifts
          ? _value.shifts
          : shifts // ignore: cast_nullable_to_non_nullable
              as List<LogShift>,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyLogImplCopyWith<$Res>
    implements $DailyLogCopyWith<$Res> {
  factory _$$DailyLogImplCopyWith(
          _$DailyLogImpl value, $Res Function(_$DailyLogImpl) then) =
      __$$DailyLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      int? localId,
      @JsonKey(name: 'project_id') String projectId,
      String? taskId,
      DateTime date,
      String status,
      String? weather,
      String notes,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      @JsonKey(name: 'created_by') String? createdBy,
      List<LogLabor> labor,
      List<LogMaterial> materials,
      List<LogEquipment> equipment,
      List<LogShift> shifts,
      @JsonKey(name: 'attachments') List<String> attachments,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'sync_status') String syncStatus});
}

/// @nodoc
class __$$DailyLogImplCopyWithImpl<$Res>
    extends _$DailyLogCopyWithImpl<$Res, _$DailyLogImpl>
    implements _$$DailyLogImplCopyWith<$Res> {
  __$$DailyLogImplCopyWithImpl(
      _$DailyLogImpl _value, $Res Function(_$DailyLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? localId = freezed,
    Object? projectId = null,
    Object? taskId = freezed,
    Object? date = null,
    Object? status = null,
    Object? weather = freezed,
    Object? notes = null,
    Object? rejectionReason = freezed,
    Object? createdBy = freezed,
    Object? labor = null,
    Object? materials = null,
    Object? equipment = null,
    Object? shifts = null,
    Object? attachments = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? syncStatus = null,
  }) {
    return _then(_$DailyLogImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      localId: freezed == localId
          ? _value.localId
          : localId // ignore: cast_nullable_to_non_nullable
              as int?,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: freezed == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String?,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      weather: freezed == weather
          ? _value.weather
          : weather // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      labor: null == labor
          ? _value._labor
          : labor // ignore: cast_nullable_to_non_nullable
              as List<LogLabor>,
      materials: null == materials
          ? _value._materials
          : materials // ignore: cast_nullable_to_non_nullable
              as List<LogMaterial>,
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<LogEquipment>,
      shifts: null == shifts
          ? _value._shifts
          : shifts // ignore: cast_nullable_to_non_nullable
              as List<LogShift>,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyLogImpl implements _DailyLog {
  const _$DailyLogImpl(
      {this.id,
      this.localId,
      @JsonKey(name: 'project_id') required this.projectId,
      this.taskId,
      required this.date,
      required this.status,
      this.weather,
      required this.notes,
      @JsonKey(name: 'rejection_reason') this.rejectionReason,
      @JsonKey(name: 'created_by') this.createdBy,
      final List<LogLabor> labor = const [],
      final List<LogMaterial> materials = const [],
      final List<LogEquipment> equipment = const [],
      final List<LogShift> shifts = const [],
      @JsonKey(name: 'attachments') final List<String> attachments = const [],
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'sync_status') this.syncStatus = 'synced'})
      : _labor = labor,
        _materials = materials,
        _equipment = equipment,
        _shifts = shifts,
        _attachments = attachments;

  factory _$DailyLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyLogImplFromJson(json);

  @override
  final String? id;
  @override
  final int? localId;
// Added for offline tracking
  @override
  @JsonKey(name: 'project_id')
  final String projectId;
  @override
  final String? taskId;
  @override
  final DateTime date;
  @override
  final String status;
  @override
  final String? weather;
  @override
  final String notes;
  @override
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;
  final List<LogLabor> _labor;
  @override
  @JsonKey()
  List<LogLabor> get labor {
    if (_labor is EqualUnmodifiableListView) return _labor;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labor);
  }

  final List<LogMaterial> _materials;
  @override
  @JsonKey()
  List<LogMaterial> get materials {
    if (_materials is EqualUnmodifiableListView) return _materials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_materials);
  }

  final List<LogEquipment> _equipment;
  @override
  @JsonKey()
  List<LogEquipment> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  final List<LogShift> _shifts;
  @override
  @JsonKey()
  List<LogShift> get shifts {
    if (_shifts is EqualUnmodifiableListView) return _shifts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_shifts);
  }

  final List<String> _attachments;
  @override
  @JsonKey(name: 'attachments')
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @override
  @JsonKey(name: 'sync_status')
  final String syncStatus;

  @override
  String toString() {
    return 'DailyLog(id: $id, localId: $localId, projectId: $projectId, taskId: $taskId, date: $date, status: $status, weather: $weather, notes: $notes, rejectionReason: $rejectionReason, createdBy: $createdBy, labor: $labor, materials: $materials, equipment: $equipment, shifts: $shifts, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.localId, localId) || other.localId == localId) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            const DeepCollectionEquality().equals(other._labor, _labor) &&
            const DeepCollectionEquality()
                .equals(other._materials, _materials) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment) &&
            const DeepCollectionEquality().equals(other._shifts, _shifts) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      localId,
      projectId,
      taskId,
      date,
      status,
      weather,
      notes,
      rejectionReason,
      createdBy,
      const DeepCollectionEquality().hash(_labor),
      const DeepCollectionEquality().hash(_materials),
      const DeepCollectionEquality().hash(_equipment),
      const DeepCollectionEquality().hash(_shifts),
      const DeepCollectionEquality().hash(_attachments),
      createdAt,
      updatedAt,
      syncStatus);

  /// Create a copy of DailyLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyLogImplCopyWith<_$DailyLogImpl> get copyWith =>
      __$$DailyLogImplCopyWithImpl<_$DailyLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyLogImplToJson(
      this,
    );
  }
}

abstract class _DailyLog implements DailyLog {
  const factory _DailyLog(
      {final String? id,
      final int? localId,
      @JsonKey(name: 'project_id') required final String projectId,
      final String? taskId,
      required final DateTime date,
      required final String status,
      final String? weather,
      required final String notes,
      @JsonKey(name: 'rejection_reason') final String? rejectionReason,
      @JsonKey(name: 'created_by') final String? createdBy,
      final List<LogLabor> labor,
      final List<LogMaterial> materials,
      final List<LogEquipment> equipment,
      final List<LogShift> shifts,
      @JsonKey(name: 'attachments') final List<String> attachments,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      @JsonKey(name: 'sync_status') final String syncStatus}) = _$DailyLogImpl;

  factory _DailyLog.fromJson(Map<String, dynamic> json) =
      _$DailyLogImpl.fromJson;

  @override
  String? get id;
  @override
  int? get localId; // Added for offline tracking
  @override
  @JsonKey(name: 'project_id')
  String get projectId;
  @override
  String? get taskId;
  @override
  DateTime get date;
  @override
  String get status;
  @override
  String? get weather;
  @override
  String get notes;
  @override
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason;
  @override
  @JsonKey(name: 'created_by')
  String? get createdBy;
  @override
  List<LogLabor> get labor;
  @override
  List<LogMaterial> get materials;
  @override
  List<LogEquipment> get equipment;
  @override
  List<LogShift> get shifts;
  @override
  @JsonKey(name: 'attachments')
  List<String> get attachments;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(name: 'sync_status')
  String get syncStatus;

  /// Create a copy of DailyLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyLogImplCopyWith<_$DailyLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LogLabor _$LogLaborFromJson(Map<String, dynamic> json) {
  return _LogLabor.fromJson(json);
}

/// @nodoc
mixin _$LogLabor {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'worker_type')
  String get workerType => throw _privateConstructorUsedError;
  @JsonKey(name: 'hours_worked')
  double get hoursWorked => throw _privateConstructorUsedError;
  double get cost => throw _privateConstructorUsedError;

  /// Serializes this LogLabor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LogLabor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogLaborCopyWith<LogLabor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogLaborCopyWith<$Res> {
  factory $LogLaborCopyWith(LogLabor value, $Res Function(LogLabor) then) =
      _$LogLaborCopyWithImpl<$Res, LogLabor>;
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'worker_type') String workerType,
      @JsonKey(name: 'hours_worked') double hoursWorked,
      double cost});
}

/// @nodoc
class _$LogLaborCopyWithImpl<$Res, $Val extends LogLabor>
    implements $LogLaborCopyWith<$Res> {
  _$LogLaborCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogLabor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? workerType = null,
    Object? hoursWorked = null,
    Object? cost = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      workerType: null == workerType
          ? _value.workerType
          : workerType // ignore: cast_nullable_to_non_nullable
              as String,
      hoursWorked: null == hoursWorked
          ? _value.hoursWorked
          : hoursWorked // ignore: cast_nullable_to_non_nullable
              as double,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogLaborImplCopyWith<$Res>
    implements $LogLaborCopyWith<$Res> {
  factory _$$LogLaborImplCopyWith(
          _$LogLaborImpl value, $Res Function(_$LogLaborImpl) then) =
      __$$LogLaborImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      @JsonKey(name: 'worker_type') String workerType,
      @JsonKey(name: 'hours_worked') double hoursWorked,
      double cost});
}

/// @nodoc
class __$$LogLaborImplCopyWithImpl<$Res>
    extends _$LogLaborCopyWithImpl<$Res, _$LogLaborImpl>
    implements _$$LogLaborImplCopyWith<$Res> {
  __$$LogLaborImplCopyWithImpl(
      _$LogLaborImpl _value, $Res Function(_$LogLaborImpl) _then)
      : super(_value, _then);

  /// Create a copy of LogLabor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? workerType = null,
    Object? hoursWorked = null,
    Object? cost = null,
  }) {
    return _then(_$LogLaborImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      workerType: null == workerType
          ? _value.workerType
          : workerType // ignore: cast_nullable_to_non_nullable
              as String,
      hoursWorked: null == hoursWorked
          ? _value.hoursWorked
          : hoursWorked // ignore: cast_nullable_to_non_nullable
              as double,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LogLaborImpl implements _LogLabor {
  const _$LogLaborImpl(
      {this.id,
      @JsonKey(name: 'worker_type') required this.workerType,
      @JsonKey(name: 'hours_worked') required this.hoursWorked,
      required this.cost});

  factory _$LogLaborImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogLaborImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'worker_type')
  final String workerType;
  @override
  @JsonKey(name: 'hours_worked')
  final double hoursWorked;
  @override
  final double cost;

  @override
  String toString() {
    return 'LogLabor(id: $id, workerType: $workerType, hoursWorked: $hoursWorked, cost: $cost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogLaborImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workerType, workerType) ||
                other.workerType == workerType) &&
            (identical(other.hoursWorked, hoursWorked) ||
                other.hoursWorked == hoursWorked) &&
            (identical(other.cost, cost) || other.cost == cost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, workerType, hoursWorked, cost);

  /// Create a copy of LogLabor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogLaborImplCopyWith<_$LogLaborImpl> get copyWith =>
      __$$LogLaborImplCopyWithImpl<_$LogLaborImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogLaborImplToJson(
      this,
    );
  }
}

abstract class _LogLabor implements LogLabor {
  const factory _LogLabor(
      {final String? id,
      @JsonKey(name: 'worker_type') required final String workerType,
      @JsonKey(name: 'hours_worked') required final double hoursWorked,
      required final double cost}) = _$LogLaborImpl;

  factory _LogLabor.fromJson(Map<String, dynamic> json) =
      _$LogLaborImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'worker_type')
  String get workerType;
  @override
  @JsonKey(name: 'hours_worked')
  double get hoursWorked;
  @override
  double get cost;

  /// Create a copy of LogLabor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogLaborImplCopyWith<_$LogLaborImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LogMaterial _$LogMaterialFromJson(Map<String, dynamic> json) {
  return _LogMaterial.fromJson(json);
}

/// @nodoc
mixin _$LogMaterial {
  String? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  double get cost => throw _privateConstructorUsedError;

  /// Serializes this LogMaterial to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LogMaterial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogMaterialCopyWith<LogMaterial> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogMaterialCopyWith<$Res> {
  factory $LogMaterialCopyWith(
          LogMaterial value, $Res Function(LogMaterial) then) =
      _$LogMaterialCopyWithImpl<$Res, LogMaterial>;
  @useResult
  $Res call(
      {String? id, String name, double quantity, String unit, double cost});
}

/// @nodoc
class _$LogMaterialCopyWithImpl<$Res, $Val extends LogMaterial>
    implements $LogMaterialCopyWith<$Res> {
  _$LogMaterialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogMaterial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? quantity = null,
    Object? unit = null,
    Object? cost = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogMaterialImplCopyWith<$Res>
    implements $LogMaterialCopyWith<$Res> {
  factory _$$LogMaterialImplCopyWith(
          _$LogMaterialImpl value, $Res Function(_$LogMaterialImpl) then) =
      __$$LogMaterialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id, String name, double quantity, String unit, double cost});
}

/// @nodoc
class __$$LogMaterialImplCopyWithImpl<$Res>
    extends _$LogMaterialCopyWithImpl<$Res, _$LogMaterialImpl>
    implements _$$LogMaterialImplCopyWith<$Res> {
  __$$LogMaterialImplCopyWithImpl(
      _$LogMaterialImpl _value, $Res Function(_$LogMaterialImpl) _then)
      : super(_value, _then);

  /// Create a copy of LogMaterial
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? quantity = null,
    Object? unit = null,
    Object? cost = null,
  }) {
    return _then(_$LogMaterialImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LogMaterialImpl implements _LogMaterial {
  const _$LogMaterialImpl(
      {this.id,
      required this.name,
      required this.quantity,
      required this.unit,
      required this.cost});

  factory _$LogMaterialImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogMaterialImplFromJson(json);

  @override
  final String? id;
  @override
  final String name;
  @override
  final double quantity;
  @override
  final String unit;
  @override
  final double cost;

  @override
  String toString() {
    return 'LogMaterial(id: $id, name: $name, quantity: $quantity, unit: $unit, cost: $cost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogMaterialImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.cost, cost) || other.cost == cost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, quantity, unit, cost);

  /// Create a copy of LogMaterial
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogMaterialImplCopyWith<_$LogMaterialImpl> get copyWith =>
      __$$LogMaterialImplCopyWithImpl<_$LogMaterialImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogMaterialImplToJson(
      this,
    );
  }
}

abstract class _LogMaterial implements LogMaterial {
  const factory _LogMaterial(
      {final String? id,
      required final String name,
      required final double quantity,
      required final String unit,
      required final double cost}) = _$LogMaterialImpl;

  factory _LogMaterial.fromJson(Map<String, dynamic> json) =
      _$LogMaterialImpl.fromJson;

  @override
  String? get id;
  @override
  String get name;
  @override
  double get quantity;
  @override
  String get unit;
  @override
  double get cost;

  /// Create a copy of LogMaterial
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogMaterialImplCopyWith<_$LogMaterialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LogEquipment _$LogEquipmentFromJson(Map<String, dynamic> json) {
  return _LogEquipment.fromJson(json);
}

/// @nodoc
mixin _$LogEquipment {
  String? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'hours_used')
  double get hoursUsed => throw _privateConstructorUsedError;
  double get cost => throw _privateConstructorUsedError;

  /// Serializes this LogEquipment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LogEquipment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogEquipmentCopyWith<LogEquipment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogEquipmentCopyWith<$Res> {
  factory $LogEquipmentCopyWith(
          LogEquipment value, $Res Function(LogEquipment) then) =
      _$LogEquipmentCopyWithImpl<$Res, LogEquipment>;
  @useResult
  $Res call(
      {String? id,
      String name,
      @JsonKey(name: 'hours_used') double hoursUsed,
      double cost});
}

/// @nodoc
class _$LogEquipmentCopyWithImpl<$Res, $Val extends LogEquipment>
    implements $LogEquipmentCopyWith<$Res> {
  _$LogEquipmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogEquipment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? hoursUsed = null,
    Object? cost = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      hoursUsed: null == hoursUsed
          ? _value.hoursUsed
          : hoursUsed // ignore: cast_nullable_to_non_nullable
              as double,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogEquipmentImplCopyWith<$Res>
    implements $LogEquipmentCopyWith<$Res> {
  factory _$$LogEquipmentImplCopyWith(
          _$LogEquipmentImpl value, $Res Function(_$LogEquipmentImpl) then) =
      __$$LogEquipmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String name,
      @JsonKey(name: 'hours_used') double hoursUsed,
      double cost});
}

/// @nodoc
class __$$LogEquipmentImplCopyWithImpl<$Res>
    extends _$LogEquipmentCopyWithImpl<$Res, _$LogEquipmentImpl>
    implements _$$LogEquipmentImplCopyWith<$Res> {
  __$$LogEquipmentImplCopyWithImpl(
      _$LogEquipmentImpl _value, $Res Function(_$LogEquipmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of LogEquipment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? hoursUsed = null,
    Object? cost = null,
  }) {
    return _then(_$LogEquipmentImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      hoursUsed: null == hoursUsed
          ? _value.hoursUsed
          : hoursUsed // ignore: cast_nullable_to_non_nullable
              as double,
      cost: null == cost
          ? _value.cost
          : cost // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LogEquipmentImpl implements _LogEquipment {
  const _$LogEquipmentImpl(
      {this.id,
      required this.name,
      @JsonKey(name: 'hours_used') required this.hoursUsed,
      required this.cost});

  factory _$LogEquipmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogEquipmentImplFromJson(json);

  @override
  final String? id;
  @override
  final String name;
  @override
  @JsonKey(name: 'hours_used')
  final double hoursUsed;
  @override
  final double cost;

  @override
  String toString() {
    return 'LogEquipment(id: $id, name: $name, hoursUsed: $hoursUsed, cost: $cost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogEquipmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.hoursUsed, hoursUsed) ||
                other.hoursUsed == hoursUsed) &&
            (identical(other.cost, cost) || other.cost == cost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, hoursUsed, cost);

  /// Create a copy of LogEquipment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogEquipmentImplCopyWith<_$LogEquipmentImpl> get copyWith =>
      __$$LogEquipmentImplCopyWithImpl<_$LogEquipmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogEquipmentImplToJson(
      this,
    );
  }
}

abstract class _LogEquipment implements LogEquipment {
  const factory _LogEquipment(
      {final String? id,
      required final String name,
      @JsonKey(name: 'hours_used') required final double hoursUsed,
      required final double cost}) = _$LogEquipmentImpl;

  factory _LogEquipment.fromJson(Map<String, dynamic> json) =
      _$LogEquipmentImpl.fromJson;

  @override
  String? get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'hours_used')
  double get hoursUsed;
  @override
  double get cost;

  /// Create a copy of LogEquipment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogEquipmentImplCopyWith<_$LogEquipmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LogShift _$LogShiftFromJson(Map<String, dynamic> json) {
  return _LogShift.fromJson(json);
}

/// @nodoc
mixin _$LogShift {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'shift_type')
  String get shiftType => throw _privateConstructorUsedError;

  /// Serializes this LogShift to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LogShift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogShiftCopyWith<LogShift> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogShiftCopyWith<$Res> {
  factory $LogShiftCopyWith(LogShift value, $Res Function(LogShift) then) =
      _$LogShiftCopyWithImpl<$Res, LogShift>;
  @useResult
  $Res call({String? id, @JsonKey(name: 'shift_type') String shiftType});
}

/// @nodoc
class _$LogShiftCopyWithImpl<$Res, $Val extends LogShift>
    implements $LogShiftCopyWith<$Res> {
  _$LogShiftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogShift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? shiftType = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      shiftType: null == shiftType
          ? _value.shiftType
          : shiftType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogShiftImplCopyWith<$Res>
    implements $LogShiftCopyWith<$Res> {
  factory _$$LogShiftImplCopyWith(
          _$LogShiftImpl value, $Res Function(_$LogShiftImpl) then) =
      __$$LogShiftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, @JsonKey(name: 'shift_type') String shiftType});
}

/// @nodoc
class __$$LogShiftImplCopyWithImpl<$Res>
    extends _$LogShiftCopyWithImpl<$Res, _$LogShiftImpl>
    implements _$$LogShiftImplCopyWith<$Res> {
  __$$LogShiftImplCopyWithImpl(
      _$LogShiftImpl _value, $Res Function(_$LogShiftImpl) _then)
      : super(_value, _then);

  /// Create a copy of LogShift
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? shiftType = null,
  }) {
    return _then(_$LogShiftImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      shiftType: null == shiftType
          ? _value.shiftType
          : shiftType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LogShiftImpl implements _LogShift {
  const _$LogShiftImpl(
      {this.id, @JsonKey(name: 'shift_type') required this.shiftType});

  factory _$LogShiftImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogShiftImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'shift_type')
  final String shiftType;

  @override
  String toString() {
    return 'LogShift(id: $id, shiftType: $shiftType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogShiftImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shiftType, shiftType) ||
                other.shiftType == shiftType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, shiftType);

  /// Create a copy of LogShift
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogShiftImplCopyWith<_$LogShiftImpl> get copyWith =>
      __$$LogShiftImplCopyWithImpl<_$LogShiftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogShiftImplToJson(
      this,
    );
  }
}

abstract class _LogShift implements LogShift {
  const factory _LogShift(
          {final String? id,
          @JsonKey(name: 'shift_type') required final String shiftType}) =
      _$LogShiftImpl;

  factory _LogShift.fromJson(Map<String, dynamic> json) =
      _$LogShiftImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'shift_type')
  String get shiftType;

  /// Create a copy of LogShift
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogShiftImplCopyWith<_$LogShiftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
