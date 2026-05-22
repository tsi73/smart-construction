import 'dart:convert';
import 'app_local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncItem {
  final int? localId;
  final String? serverId;
  final String entityType;
  final String operationType;
  final String? projectId;
  final String? taskId;
  final Map<String, dynamic> payload;
  final String status;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;

  SyncItem({
    this.localId,
    this.serverId,
    required this.entityType,
    required this.operationType,
    this.projectId,
    this.taskId,
    required this.payload,
    required this.status,
    this.attemptCount = 0,
    this.lastAttemptAt,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'local_id': localId,
      'server_id': serverId,
      'entity_type': entityType,
      'operation_type': operationType,
      'project_id': projectId,
      'task_id': taskId,
      'payload_json': jsonEncode(payload),
      'status': status,
      'attempt_count': attemptCount,
      'last_attempt_at': lastAttemptAt?.toIso8601String(),
      'last_error': lastError,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SyncItem.fromMap(Map<String, dynamic> map) {
    return SyncItem(
      localId: map['local_id'],
      serverId: map['server_id'],
      entityType: map['entity_type'] ?? '',
      operationType: map['operation_type'] ?? '',
      projectId: map['project_id'],
      taskId: map['task_id'],
      payload:
          map['payload_json'] != null ? jsonDecode(map['payload_json']) : {},
      status: map['status'] ?? 'pending',
      attemptCount: map['attempt_count'] ?? 0,
      lastAttemptAt: map['last_attempt_at'] != null
          ? DateTime.parse(map['last_attempt_at'])
          : null,
      lastError: map['last_error'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }
}

abstract class SyncQueueDataSource {
  Future<int> addItem(SyncItem item);
  Future<List<SyncItem>> getPendingItems();
  Future<void> updateItem(SyncItem item);
  Future<void> deleteItem(int localId);
}

class SyncQueueDataSourceImpl implements SyncQueueDataSource {
  final AppLocalStorage _storage;

  SyncQueueDataSourceImpl(this._storage);

  @override
  Future<int> addItem(SyncItem item) async {
    return await _storage.addToSyncQueue(item.toMap());
  }

  @override
  Future<List<SyncItem>> getPendingItems() async {
    final List<Map<String, dynamic>> maps =
        await _storage.getPendingSyncItems();
    return maps.map((m) => SyncItem.fromMap(m)).toList();
  }

  @override
  Future<void> updateItem(SyncItem item) async {
    await _storage.updateSyncItem(item.toMap());
  }

  @override
  Future<void> deleteItem(int localId) async {
    await _storage.deleteSyncItem(localId);
  }
}

final syncQueueDataSourceProvider = Provider<SyncQueueDataSource>((ref) {
  return SyncQueueDataSourceImpl(ref.watch(appLocalStorageProvider));
});
