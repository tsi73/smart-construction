// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncQueueItemImpl _$$SyncQueueItemImplFromJson(Map<String, dynamic> json) =>
    _$SyncQueueItemImpl(
      localId: (json['localId'] as num?)?.toInt(),
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      action: $enumDecode(_$SyncActionEnumMap, json['action']),
      status: $enumDecode(_$SyncStatusEnumMap, json['status']),
      payload: json['payload'] as Map<String, dynamic>,
      lastError: json['lastError'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SyncQueueItemImplToJson(_$SyncQueueItemImpl instance) =>
    <String, dynamic>{
      'localId': instance.localId,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'action': _$SyncActionEnumMap[instance.action]!,
      'status': _$SyncStatusEnumMap[instance.status]!,
      'payload': instance.payload,
      'lastError': instance.lastError,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$SyncActionEnumMap = {
  SyncAction.create: 'create',
  SyncAction.update: 'update',
  SyncAction.delete: 'delete',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.failed: 'failed',
  SyncStatus.synced: 'synced',
};
