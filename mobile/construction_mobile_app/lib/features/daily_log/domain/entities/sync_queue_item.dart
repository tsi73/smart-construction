import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_queue_item.freezed.dart';
part 'sync_queue_item.g.dart';

enum SyncAction { create, update, delete }

enum SyncStatus { pending, failed, synced }

@freezed
class SyncQueueItem with _$SyncQueueItem {
  const factory SyncQueueItem({
    int? localId,
    required String entityType, // e.g., 'daily_log'
    required String entityId, // local_id for new ones, server_id for updates
    required SyncAction action,
    required SyncStatus status,
    required Map<String, dynamic> payload,
    String? lastError,
    required DateTime createdAt,
  }) = _SyncQueueItem;

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueItemFromJson(json);
}
