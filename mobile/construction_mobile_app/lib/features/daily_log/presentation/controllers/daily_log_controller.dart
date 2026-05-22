import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:construction_mobile_app/features/daily_log/domain/entities/daily_log.dart';
import 'package:construction_mobile_app/features/daily_log/domain/repositories/daily_log_repository.dart';
import 'package:construction_mobile_app/features/daily_log/data/datasources/daily_log_remote_data_source.dart';
import 'package:construction_mobile_app/features/daily_log/data/datasources/daily_log_local_data_source.dart';
import 'package:construction_mobile_app/features/daily_log/data/repositories/daily_log_repository_impl.dart';
import 'package:construction_mobile_app/core/network/network_info.dart';
import 'package:construction_mobile_app/core/storage/sync_queue_repository.dart';
import 'package:construction_mobile_app/core/notifications/notification_service.dart';
import 'package:construction_mobile_app/core/routing/route_names.dart';

final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  return DailyLogRepositoryImpl(
    ref.watch(dailyLogRemoteDataSourceProvider),
    ref.watch(dailyLogLocalDataSourceProvider),
    ref.watch(syncQueueRepositoryProvider),
    ref.watch(networkInfoProvider),
  );
});

final projectLogsProvider =
    FutureProvider.family<List<DailyLog>, String>((ref, projectId) async {
  final repository = ref.watch(dailyLogRepositoryProvider);
  final result = await repository.getProjectLogs(projectId);
  return result.fold((l) => throw l.message, (r) => r);
});

final dailyLogDetailProvider =
    FutureProvider.family<DailyLog, String>((ref, logId) async {
  final repository = ref.watch(dailyLogRepositoryProvider);
  final result = await repository.getDailyLog(logId);
  return result.fold((l) => throw l.message, (r) => r);
});

class DailyLogController extends StateNotifier<AsyncValue<DailyLog?>> {
  final DailyLogRepository _repository;
  final Ref _ref;

  DailyLogController(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createLog(DailyLog log) async {
    state = const AsyncValue.loading();
    final result = await _repository.createDailyLog(log);
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) {
        // Notification handled by submitLog; createLog just saves a draft
        return AsyncValue.data(r);
      },
    );
  }

  Future<void> submitLog(String logId) async {
    state = const AsyncValue.loading();
    final result = await _repository.submitDailyLog(logId);
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) {
        _ref.read(notificationServiceProvider.notifier).addLocal(
              type: NotificationType.logSubmitted,
              title: 'Log Submitted',
              message:
                  'Your daily log has been submitted and is pending review.',
              logId: logId,
              actionRoute: '${RouteNames.dailyLogs}/$logId',
            );
        return const AsyncValue.data(null);
      },
    );
  }

  Future<void> reviewLog(String logId, bool approved) async {
    state = const AsyncValue.loading();
    final result = await _repository.reviewDailyLog(logId, approved);
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) {
        if (approved) {
          _ref.read(notificationServiceProvider.notifier).addLocal(
                type: NotificationType.logConsultantApproved,
                title: 'Consultant Approved',
                message: 'Daily log has been approved by the consultant.',
                logId: logId,
                actionRoute: '${RouteNames.dailyLogs}/$logId',
              );
        }
        return const AsyncValue.data(null);
      },
    );
  }

  Future<void> approveLog(String logId, bool isPm) async {
    state = const AsyncValue.loading();
    final result = isPm
        ? await _repository.pmApprove(logId)
        : await _repository.consultantApprove(logId);
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) {
        if (isPm) {
          _ref.read(notificationServiceProvider.notifier).addLocal(
                type: NotificationType.logPmApproved,
                title: 'PM Approved',
                message: 'You have fully approved the daily log.',
                logId: logId,
                actionRoute: '${RouteNames.dailyLogs}/$logId',
              );
        }
        return const AsyncValue.data(null);
      },
    );
  }

  Future<void> rejectLog(String logId, String reason) async {
    state = const AsyncValue.loading();
    final result = await _repository.rejectDailyLog(logId, reason);
    state = result.fold(
      (l) => AsyncValue.error(l.message, StackTrace.current),
      (r) {
        _ref.read(notificationServiceProvider.notifier).addLocal(
              type: NotificationType.logRejected,
              title: 'Log Rejected',
              message: 'Daily log has been rejected. Reason: $reason',
              logId: logId,
              actionRoute: '${RouteNames.dailyLogs}/$logId',
            );
        return const AsyncValue.data(null);
      },
    );
  }
}

final dailyLogControllerProvider =
    StateNotifierProvider<DailyLogController, AsyncValue<DailyLog?>>((ref) {
  return DailyLogController(ref.watch(dailyLogRepositoryProvider), ref);
});
