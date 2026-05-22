// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Task _$TaskFromJson(Map<String, dynamic> json) {
  return _Task.fromJson(json);
}

/// @nodoc
mixin _$Task {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'project_id')
  String get projectId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, in_progress, completed
  @JsonKey(name: 'progress_percentage')
  double get progressPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'assigned_to')
  String? get assignedTo => throw _privateConstructorUsedError;
  @JsonKey(name: 'planned_duration_days')
  int? get plannedDurationDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'actual_cost')
  double? get actualCost => throw _privateConstructorUsedError;
  @JsonKey(name: 'planned_cost')
  double? get plannedCost => throw _privateConstructorUsedError;
  @JsonKey(name: 'dependencies')
  List<TaskDependency> get dependencies => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'project_id') String projectId,
      String name,
      String? description,
      String status,
      @JsonKey(name: 'progress_percentage') double progressPercentage,
      @JsonKey(name: 'start_date') DateTime? startDate,
      @JsonKey(name: 'end_date') DateTime? endDate,
      @JsonKey(name: 'assigned_to') String? assignedTo,
      @JsonKey(name: 'planned_duration_days') int? plannedDurationDays,
      @JsonKey(name: 'actual_cost') double? actualCost,
      @JsonKey(name: 'planned_cost') double? plannedCost,
      @JsonKey(name: 'dependencies') List<TaskDependency> dependencies,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? projectId = null,
    Object? name = null,
    Object? description = freezed,
    Object? status = null,
    Object? progressPercentage = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? assignedTo = freezed,
    Object? plannedDurationDays = freezed,
    Object? actualCost = freezed,
    Object? plannedCost = freezed,
    Object? dependencies = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String?,
      plannedDurationDays: freezed == plannedDurationDays
          ? _value.plannedDurationDays
          : plannedDurationDays // ignore: cast_nullable_to_non_nullable
              as int?,
      actualCost: freezed == actualCost
          ? _value.actualCost
          : actualCost // ignore: cast_nullable_to_non_nullable
              as double?,
      plannedCost: freezed == plannedCost
          ? _value.plannedCost
          : plannedCost // ignore: cast_nullable_to_non_nullable
              as double?,
      dependencies: null == dependencies
          ? _value.dependencies
          : dependencies // ignore: cast_nullable_to_non_nullable
              as List<TaskDependency>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
          _$TaskImpl value, $Res Function(_$TaskImpl) then) =
      __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'project_id') String projectId,
      String name,
      String? description,
      String status,
      @JsonKey(name: 'progress_percentage') double progressPercentage,
      @JsonKey(name: 'start_date') DateTime? startDate,
      @JsonKey(name: 'end_date') DateTime? endDate,
      @JsonKey(name: 'assigned_to') String? assignedTo,
      @JsonKey(name: 'planned_duration_days') int? plannedDurationDays,
      @JsonKey(name: 'actual_cost') double? actualCost,
      @JsonKey(name: 'planned_cost') double? plannedCost,
      @JsonKey(name: 'dependencies') List<TaskDependency> dependencies,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
      : super(_value, _then);

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? projectId = null,
    Object? name = null,
    Object? description = freezed,
    Object? status = null,
    Object? progressPercentage = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? assignedTo = freezed,
    Object? plannedDurationDays = freezed,
    Object? actualCost = freezed,
    Object? plannedCost = freezed,
    Object? dependencies = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progressPercentage: null == progressPercentage
          ? _value.progressPercentage
          : progressPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String?,
      plannedDurationDays: freezed == plannedDurationDays
          ? _value.plannedDurationDays
          : plannedDurationDays // ignore: cast_nullable_to_non_nullable
              as int?,
      actualCost: freezed == actualCost
          ? _value.actualCost
          : actualCost // ignore: cast_nullable_to_non_nullable
              as double?,
      plannedCost: freezed == plannedCost
          ? _value.plannedCost
          : plannedCost // ignore: cast_nullable_to_non_nullable
              as double?,
      dependencies: null == dependencies
          ? _value._dependencies
          : dependencies // ignore: cast_nullable_to_non_nullable
              as List<TaskDependency>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskImpl implements _Task {
  const _$TaskImpl(
      {required this.id,
      @JsonKey(name: 'project_id') required this.projectId,
      required this.name,
      this.description,
      required this.status,
      @JsonKey(name: 'progress_percentage') this.progressPercentage = 0.0,
      @JsonKey(name: 'start_date') this.startDate,
      @JsonKey(name: 'end_date') this.endDate,
      @JsonKey(name: 'assigned_to') this.assignedTo,
      @JsonKey(name: 'planned_duration_days') this.plannedDurationDays,
      @JsonKey(name: 'actual_cost') this.actualCost,
      @JsonKey(name: 'planned_cost') this.plannedCost,
      @JsonKey(name: 'dependencies')
      final List<TaskDependency> dependencies = const [],
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : _dependencies = dependencies;

  factory _$TaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'project_id')
  final String projectId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String status;
// pending, in_progress, completed
  @override
  @JsonKey(name: 'progress_percentage')
  final double progressPercentage;
  @override
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @JsonKey(name: 'assigned_to')
  final String? assignedTo;
  @override
  @JsonKey(name: 'planned_duration_days')
  final int? plannedDurationDays;
  @override
  @JsonKey(name: 'actual_cost')
  final double? actualCost;
  @override
  @JsonKey(name: 'planned_cost')
  final double? plannedCost;
  final List<TaskDependency> _dependencies;
  @override
  @JsonKey(name: 'dependencies')
  List<TaskDependency> get dependencies {
    if (_dependencies is EqualUnmodifiableListView) return _dependencies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dependencies);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Task(id: $id, projectId: $projectId, name: $name, description: $description, status: $status, progressPercentage: $progressPercentage, startDate: $startDate, endDate: $endDate, assignedTo: $assignedTo, plannedDurationDays: $plannedDurationDays, actualCost: $actualCost, plannedCost: $plannedCost, dependencies: $dependencies, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progressPercentage, progressPercentage) ||
                other.progressPercentage == progressPercentage) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.plannedDurationDays, plannedDurationDays) ||
                other.plannedDurationDays == plannedDurationDays) &&
            (identical(other.actualCost, actualCost) ||
                other.actualCost == actualCost) &&
            (identical(other.plannedCost, plannedCost) ||
                other.plannedCost == plannedCost) &&
            const DeepCollectionEquality()
                .equals(other._dependencies, _dependencies) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      projectId,
      name,
      description,
      status,
      progressPercentage,
      startDate,
      endDate,
      assignedTo,
      plannedDurationDays,
      actualCost,
      plannedCost,
      const DeepCollectionEquality().hash(_dependencies),
      createdAt,
      updatedAt);

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskImplToJson(
      this,
    );
  }
}

abstract class _Task implements Task {
  const factory _Task(
      {required final String id,
      @JsonKey(name: 'project_id') required final String projectId,
      required final String name,
      final String? description,
      required final String status,
      @JsonKey(name: 'progress_percentage') final double progressPercentage,
      @JsonKey(name: 'start_date') final DateTime? startDate,
      @JsonKey(name: 'end_date') final DateTime? endDate,
      @JsonKey(name: 'assigned_to') final String? assignedTo,
      @JsonKey(name: 'planned_duration_days') final int? plannedDurationDays,
      @JsonKey(name: 'actual_cost') final double? actualCost,
      @JsonKey(name: 'planned_cost') final double? plannedCost,
      @JsonKey(name: 'dependencies') final List<TaskDependency> dependencies,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$TaskImpl;

  factory _Task.fromJson(Map<String, dynamic> json) = _$TaskImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'project_id')
  String get projectId;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get status; // pending, in_progress, completed
  @override
  @JsonKey(name: 'progress_percentage')
  double get progressPercentage;
  @override
  @JsonKey(name: 'start_date')
  DateTime? get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'assigned_to')
  String? get assignedTo;
  @override
  @JsonKey(name: 'planned_duration_days')
  int? get plannedDurationDays;
  @override
  @JsonKey(name: 'actual_cost')
  double? get actualCost;
  @override
  @JsonKey(name: 'planned_cost')
  double? get plannedCost;
  @override
  @JsonKey(name: 'dependencies')
  List<TaskDependency> get dependencies;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaskDependency _$TaskDependencyFromJson(Map<String, dynamic> json) {
  return _TaskDependency.fromJson(json);
}

/// @nodoc
mixin _$TaskDependency {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'depends_on_task_id')
  String get dependsOnTaskId => throw _privateConstructorUsedError;
  @JsonKey(name: 'depends_on_task_name')
  String? get dependsOnTaskName => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TaskDependency to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaskDependency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskDependencyCopyWith<TaskDependency> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskDependencyCopyWith<$Res> {
  factory $TaskDependencyCopyWith(
          TaskDependency value, $Res Function(TaskDependency) then) =
      _$TaskDependencyCopyWithImpl<$Res, TaskDependency>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'depends_on_task_id') String dependsOnTaskId,
      @JsonKey(name: 'depends_on_task_name') String? dependsOnTaskName,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class _$TaskDependencyCopyWithImpl<$Res, $Val extends TaskDependency>
    implements $TaskDependencyCopyWith<$Res> {
  _$TaskDependencyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaskDependency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dependsOnTaskId = null,
    Object? dependsOnTaskName = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dependsOnTaskId: null == dependsOnTaskId
          ? _value.dependsOnTaskId
          : dependsOnTaskId // ignore: cast_nullable_to_non_nullable
              as String,
      dependsOnTaskName: freezed == dependsOnTaskName
          ? _value.dependsOnTaskName
          : dependsOnTaskName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskDependencyImplCopyWith<$Res>
    implements $TaskDependencyCopyWith<$Res> {
  factory _$$TaskDependencyImplCopyWith(_$TaskDependencyImpl value,
          $Res Function(_$TaskDependencyImpl) then) =
      __$$TaskDependencyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'depends_on_task_id') String dependsOnTaskId,
      @JsonKey(name: 'depends_on_task_name') String? dependsOnTaskName,
      @JsonKey(name: 'created_at') DateTime? createdAt});
}

/// @nodoc
class __$$TaskDependencyImplCopyWithImpl<$Res>
    extends _$TaskDependencyCopyWithImpl<$Res, _$TaskDependencyImpl>
    implements _$$TaskDependencyImplCopyWith<$Res> {
  __$$TaskDependencyImplCopyWithImpl(
      _$TaskDependencyImpl _value, $Res Function(_$TaskDependencyImpl) _then)
      : super(_value, _then);

  /// Create a copy of TaskDependency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dependsOnTaskId = null,
    Object? dependsOnTaskName = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$TaskDependencyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dependsOnTaskId: null == dependsOnTaskId
          ? _value.dependsOnTaskId
          : dependsOnTaskId // ignore: cast_nullable_to_non_nullable
              as String,
      dependsOnTaskName: freezed == dependsOnTaskName
          ? _value.dependsOnTaskName
          : dependsOnTaskName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskDependencyImpl implements _TaskDependency {
  const _$TaskDependencyImpl(
      {required this.id,
      @JsonKey(name: 'depends_on_task_id') required this.dependsOnTaskId,
      @JsonKey(name: 'depends_on_task_name') this.dependsOnTaskName,
      @JsonKey(name: 'created_at') this.createdAt});

  factory _$TaskDependencyImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskDependencyImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'depends_on_task_id')
  final String dependsOnTaskId;
  @override
  @JsonKey(name: 'depends_on_task_name')
  final String? dependsOnTaskName;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'TaskDependency(id: $id, dependsOnTaskId: $dependsOnTaskId, dependsOnTaskName: $dependsOnTaskName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskDependencyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dependsOnTaskId, dependsOnTaskId) ||
                other.dependsOnTaskId == dependsOnTaskId) &&
            (identical(other.dependsOnTaskName, dependsOnTaskName) ||
                other.dependsOnTaskName == dependsOnTaskName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, dependsOnTaskId, dependsOnTaskName, createdAt);

  /// Create a copy of TaskDependency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskDependencyImplCopyWith<_$TaskDependencyImpl> get copyWith =>
      __$$TaskDependencyImplCopyWithImpl<_$TaskDependencyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskDependencyImplToJson(
      this,
    );
  }
}

abstract class _TaskDependency implements TaskDependency {
  const factory _TaskDependency(
      {required final String id,
      @JsonKey(name: 'depends_on_task_id')
      required final String dependsOnTaskId,
      @JsonKey(name: 'depends_on_task_name') final String? dependsOnTaskName,
      @JsonKey(name: 'created_at')
      final DateTime? createdAt}) = _$TaskDependencyImpl;

  factory _TaskDependency.fromJson(Map<String, dynamic> json) =
      _$TaskDependencyImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'depends_on_task_id')
  String get dependsOnTaskId;
  @override
  @JsonKey(name: 'depends_on_task_name')
  String? get dependsOnTaskName;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of TaskDependency
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskDependencyImplCopyWith<_$TaskDependencyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
