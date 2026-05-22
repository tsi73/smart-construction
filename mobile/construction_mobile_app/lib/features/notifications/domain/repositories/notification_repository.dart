import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/notifications/notification_service.dart'
    show AppNotification;

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(String id);
}
