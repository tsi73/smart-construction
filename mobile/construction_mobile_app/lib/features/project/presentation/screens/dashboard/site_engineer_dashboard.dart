import 'package:construction_mobile_app/core/network/network_info.dart';
import 'package:construction_mobile_app/features/daily_log/presentation/controllers/daily_log_controller.dart'
    show projectLogsProvider;
import 'package:construction_mobile_app/features/task/presentation/controllers/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/project_provider.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import 'dashboard_widgets.dart';

class SiteEngineerDashboardBody extends ConsumerWidget {
  const SiteEngineerDashboardBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(currentProjectProvider);
    final projectId = (project?['id'] ?? '').toString();
    final tasks = ref.watch(projectTasksProvider(projectId));
    final logs = ref.watch(projectLogsProvider(projectId));
    final network = ref.watch(networkStatusProvider);
    final taskList = tasks.valueOrNull;
    final logList = logs.valueOrNull;
    final isOffline = network.valueOrNull == NetworkStatus.offline;
    final today = DateTime.now();
    final todaysLogs = countLogs(
      logList,
      (log) =>
          log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day,
    );
    final pendingSync = countLogs(logList, (log) => log.syncStatus != 'synced');
    final rejectedLogs = countLogs(logList, (log) => log.status == 'rejected');
    final openTasks = countTasks(
      taskList,
      (task) => task.status != 'completed',
    );
    final siteCondition = logList != null && logList.isNotEmpty
        ? latestSiteConditions(logList)
        : null;

    final user = ref.watch(authProvider).user;
    final fullName = user?['full_name']?.toString() ?? '';
    final firstName = fullName.split(' ').firstOrNull ?? 'there';

    // Latest update text
    String? latestUpdateText;
    String? latestUpdateSub;
    if (logList != null && logList.isNotEmpty) {
      final sorted = [...logList]..sort((a, b) => b.date.compareTo(a.date));
      final latest = sorted.first;
      latestUpdateText = 'Latest log ${latest.status.replaceAll('_', ' ')}';
      latestUpdateSub =
          '${DateFormat('MMM d').format(latest.date)} · ${latest.status.replaceAll('_', ' ')}';
    } else if (taskList != null && taskList.isNotEmpty) {
      latestUpdateText = '${taskList.length} tasks tracked';
    }

    final tasksLoading = tasks.isLoading;
    final logsLoading = logs.isLoading;

    return DashboardContent(
      children: [
        GreetingBanner(firstName: firstName),
        const SizedBox(height: AppSpacing.md),
        // Rejected logs warning (folded into Action Required if present)
        if (rejectedLogs > 0) ...[
          DashboardPrimaryCta(
            icon: Icons.error_outline_rounded,
            label:
                '$rejectedLogs rejected log${rejectedLogs > 1 ? 's' : ''} — View',
            onTap: () => context.push(RouteNames.dailyLogs),
            accentColor: AppColors.accentRed,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.md),
        // Today Snapshot
        TodaySnapshotCard(
          metrics: [
            SnapshotMetric(
              icon: Icons.assignment_rounded,
              label: 'Open Tasks',
              value: tasksLoading ? '--' : dashboardCount(openTasks),
              color: AppColors.accentBlue,
            ),
            SnapshotMetric(
              icon: Icons.today_rounded,
              label: "Today's Log",
              value: logsLoading ? '--' : dashboardCount(todaysLogs),
              color: todaysLogs > 0
                  ? AppColors.accentGreen
                  : AppColors.accentAmber,
            ),
            SnapshotMetric(
              icon: Icons.cancel_rounded,
              label: 'Rejected Logs',
              value: logsLoading ? '--' : dashboardCount(rejectedLogs),
              color: rejectedLogs > 0
                  ? AppColors.accentRed
                  : AppColors.accentGreen,
            ),
            SnapshotMetric(
              icon: Icons.sync_rounded,
              label: 'Pending Sync',
              value: logsLoading ? '--' : dashboardCount(pendingSync),
              color: pendingSync > 0
                  ? AppColors.accentAmber
                  : AppColors.accentGreen,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Action Required
        ActionRequiredCard(
          allClear: rejectedLogs == 0 && pendingSync == 0,
          items: [
            if (rejectedLogs > 0)
              ActionItem(
                icon: Icons.cancel_rounded,
                label: 'Rejected logs',
                count: rejectedLogs,
                color: AppColors.accentRed,
              ),
            if (pendingSync > 0)
              ActionItem(
                icon: Icons.sync_problem_rounded,
                label: 'Pending sync',
                count: pendingSync,
                color: AppColors.accentAmber,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Today's Focus
        TodayFocusCard(
          items: [
            FocusItem(
              icon: Icons.edit_note_rounded,
              text: todaysLogs > 0
                  ? "Today's log submitted"
                  : 'No log submitted today',
              color: todaysLogs > 0
                  ? AppColors.accentGreen
                  : AppColors.accentAmber,
            ),
            FocusItem(
              icon:
                  isOffline ? Icons.wifi_off_rounded : Icons.cloud_done_rounded,
              text: isOffline
                  ? 'Offline — drafts saved locally'
                  : 'Online — sync available',
              color: isOffline ? AppColors.accentAmber : AppColors.accentGreen,
            ),
            if (siteCondition != null)
              FocusItem(
                icon: Icons.cloud_queue_rounded,
                text: 'Site: $siteCondition',
                color: AppColors.accentBlue,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Latest Updates
        LatestUpdatesCard(
          updateText: latestUpdateText,
          subtitle: latestUpdateSub,
        ),
      ],
    );
  }
}
