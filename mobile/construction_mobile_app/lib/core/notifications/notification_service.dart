import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'package:construction_mobile_app/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:construction_mobile_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:construction_mobile_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:construction_mobile_app/core/network/dio_client.dart';

enum NotificationType {
  // Daily Log lifecycle
  logSubmitted,
  logConsultantApproved,
  logPmApproved,
  logRejected,

  // Task events
  taskAssigned,
  taskStatusChanged,

  // Team events
  memberAdded,
  invitationReceived,

  // Budget events
  budgetAlert,

  // Prediction events
  delayRiskDetected,

  // System
  syncFailure,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final String? projectId;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final String? taskId;
  final String? logId;
  final String? actionRoute;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.projectId,
    this.metadata,
    this.isRead = false,
    this.taskId,
    this.logId,
    this.actionRoute,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    String? projectId,
    Map<String, dynamic>? metadata,
    bool? isRead,
    String? taskId,
    String? logId,
    String? actionRoute,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      projectId: projectId ?? this.projectId,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      taskId: taskId ?? this.taskId,
      logId: logId ?? this.logId,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }

  factory AppNotification.fromMessageResponse(Map<String, dynamic> json) {
    final content = (json['content'] as String?) ?? '';
    final type = _typeFromContent(content);

    return AppNotification(
      id: (json['id'] as String?) ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: _titleFromType(type),
      message: content,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isRead: (json['is_read'] as bool?) ?? false,
    );
  }

  static NotificationType _typeFromContent(String content) {
    final lower = content.toLowerCase();
    if (lower.contains('submitted')) {
      return NotificationType.logSubmitted;
    }
    if (lower.contains('consultant') && lower.contains('approv')) {
      return NotificationType.logConsultantApproved;
    }
    if (lower.contains('pm') && lower.contains('approv')) {
      return NotificationType.logPmApproved;
    }
    if (lower.contains('reject')) {
      return NotificationType.logRejected;
    }
    if (lower.contains('assigned')) {
      return NotificationType.taskAssigned;
    }
    if (lower.contains('status') && lower.contains('chang')) {
      return NotificationType.taskStatusChanged;
    }
    if (lower.contains('added') || lower.contains('member')) {
      return NotificationType.memberAdded;
    }
    if (lower.contains('invitation') || lower.contains('invited')) {
      return NotificationType.invitationReceived;
    }
    if (lower.contains('budget')) {
      return NotificationType.budgetAlert;
    }
    if (lower.contains('delay') || lower.contains('risk')) {
      return NotificationType.delayRiskDetected;
    }
    if (lower.contains('sync') && lower.contains('fail')) {
      return NotificationType.syncFailure;
    }
    return NotificationType.syncFailure;
  }

  static String _titleFromType(NotificationType type) {
    switch (type) {
      case NotificationType.logSubmitted:
        return 'Log Submitted';
      case NotificationType.logConsultantApproved:
        return 'Consultant Approved';
      case NotificationType.logPmApproved:
        return 'PM Approved';
      case NotificationType.logRejected:
        return 'Log Rejected';
      case NotificationType.taskAssigned:
        return 'Task Assigned';
      case NotificationType.taskStatusChanged:
        return 'Task Status Changed';
      case NotificationType.memberAdded:
        return 'Member Added';
      case NotificationType.invitationReceived:
        return 'Invitation Received';
      case NotificationType.budgetAlert:
        return 'Budget Alert';
      case NotificationType.delayRiskDetected:
        return 'Delay Risk Detected';
      case NotificationType.syncFailure:
        return 'Sync Failed';
    }
  }
}

class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationService extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationService(this._repository) : super(const NotificationState());

  Future<void> fetchFromBackend() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getNotifications();
    result.fold(
      (failure) {
        if (kDebugMode) {
          debugPrint(
              'NotificationService: fetchFromBackend failed: ${failure.message}');
        }
        state = state.copyWith(isLoading: false);
      },
      (backendNotifications) {
        // Merge: backend notifications replace existing ones with same id,
        // local-only notifications (no backend match) are preserved
        final existingLocal = state.notifications.where(
          (n) => !backendNotifications.any((bn) => bn.id == n.id),
        );
        final merged = [...backendNotifications, ...existingLocal]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final unread = merged.where((n) => !n.isRead).length;
        state = NotificationState(
          notifications: merged,
          isLoading: false,
          unreadCount: unread,
        );
      },
    );
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);

    // Backend call (fire-and-forget)
    _repository.markAsRead(id);
  }

  void markAllRead() {
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated, unreadCount: 0);

    // Mark each on backend
    for (final n in state.notifications.where((n) => !n.isRead)) {
      _repository.markAsRead(n.id);
    }
  }

  void addLocal({
    required NotificationType type,
    required String title,
    required String message,
    String? projectId,
    String? taskId,
    String? logId,
    String? actionRoute,
    Map<String, dynamic>? metadata,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      message: message,
      createdAt: DateTime.now(),
      projectId: projectId,
      metadata: metadata,
      isRead: false,
      taskId: taskId,
      logId: logId,
      actionRoute: actionRoute,
    );

    final updated = [notification, ...state.notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);

    if (kDebugMode) {
      debugPrint('NotificationService: Added local notification - $title');
    }
  }

  void clearNotification(String id) {
    final updated = state.notifications.where((n) => n.id != id).toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
  }

  void clearNotifications() {
    state = const NotificationState();
  }

  void clearProjectNotifications(String projectId) {
    final updated =
        state.notifications.where((n) => n.projectId != projectId).toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
  }
}

final notificationServiceProvider =
    StateNotifierProvider<NotificationService, NotificationState>((ref) {
  final remoteDataSource =
      NotificationRemoteDataSourceImpl(ref.watch(dioProvider));
  final repository = NotificationRepositoryImpl(remoteDataSource);
  return NotificationService(repository);
});
