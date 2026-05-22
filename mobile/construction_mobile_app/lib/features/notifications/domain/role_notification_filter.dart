import '../../../../core/notifications/notification_service.dart';

class RoleNotificationFilter {
  static List<AppNotification> filter(
      List<AppNotification> notifications, String role) {
    final allowedTypes = _allowedTypesForRole(role);
    return notifications.where((n) => allowedTypes.contains(n.type)).toList();
  }

  static Set<NotificationType> _allowedTypesForRole(String role) {
    switch (role) {
      case 'site_engineer':
        return {
          NotificationType.logSubmitted,
          NotificationType.logPmApproved,
          NotificationType.logRejected,
          NotificationType.taskAssigned,
          NotificationType.memberAdded,
          NotificationType.syncFailure,
        };
      case 'consultant':
        return {
          NotificationType.logSubmitted,
          NotificationType.memberAdded,
          NotificationType.syncFailure,
        };
      case 'project_manager':
        return {
          NotificationType.logConsultantApproved,
          NotificationType.taskAssigned,
          NotificationType.taskStatusChanged,
          NotificationType.budgetAlert,
          NotificationType.delayRiskDetected,
          NotificationType.memberAdded,
          NotificationType.invitationReceived,
          NotificationType.syncFailure,
        };
      case 'owner':
      default:
        return NotificationType.values.toSet();
    }
  }
}
