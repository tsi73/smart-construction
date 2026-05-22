import 'package:construction_mobile_app/features/daily_log/presentation/controllers/daily_log_controller.dart';
import 'package:construction_mobile_app/features/task/presentation/controllers/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/project_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import 'dashboard_widgets.dart';

class ProjectManagerDashboardBody extends ConsumerWidget {
  const ProjectManagerDashboardBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(currentProjectProvider);
    final projectId = (project?['id'] ?? '').toString();
    final tasks = ref.watch(projectTasksProvider(projectId));
    final logs = ref.watch(projectLogsProvider(projectId));
    final taskList = tasks.valueOrNull;
    final logList = logs.valueOrNull;

    final openTasks = countTasks(
      taskList,
      (task) => task.status != 'completed',
    );
    final overdueTasks = countTasks(
      taskList,
      (task) => task.status == 'overdue' || task.status == 'incomplete',
    );
    // Safer delayed: not completed AND endDate before today
    final delayedTasks = countTasks(
      taskList,
      (task) =>
          task.status != 'completed' &&
          task.endDate != null &&
          task.endDate!.isBefore(DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          )),
    );
    final effectiveDelayed = overdueTasks > 0 ? overdueTasks : delayedTasks;
    final pendingApprovals = countLogs(
      logList,
      (log) =>
          log.status == 'submitted' ||
          log.status == 'pm_pending' ||
          log.status == 'consultant_pending',
    );
    final pendingSync = countLogs(
      logList,
      (log) => log.syncStatus != 'synced',
    );
    final tasksDueToday = countTasks(
      taskList,
      (task) => task.endDate != null && _isToday(task.endDate!),
    );
    final submittedLogs = countLogs(
      logList,
      (log) => log.status == 'submitted',
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
              label: 'Due Today',
              value: tasksLoading ? '--' : dashboardCount(tasksDueToday),
              color: AppColors.accentAmber,
            ),
            SnapshotMetric(
              icon: Icons.warning_amber_rounded,
              label: 'Delayed',
              value: tasksLoading ? '--' : dashboardCount(effectiveDelayed),
              color: effectiveDelayed > 0
                  ? AppColors.accentRed
                  : AppColors.accentGreen,
            ),
            SnapshotMetric(
              icon: Icons.pending_actions_rounded,
              label: 'Pending Approval',
              value: logsLoading ? '--' : dashboardCount(pendingApprovals),
              color: pendingApprovals > 0
                  ? AppColors.accentAmber
                  : AppColors.accentGreen,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Action Required
        ActionRequiredCard(
          allClear: pendingApprovals == 0 &&
              effectiveDelayed == 0 &&
              pendingSync == 0,
          items: [
            if (pendingApprovals > 0)
              ActionItem(
                icon: Icons.pending_actions_rounded,
                label: 'Pending approvals',
                count: pendingApprovals,
                color: AppColors.accentAmber,
              ),
            if (effectiveDelayed > 0)
              ActionItem(
                icon: Icons.warning_rounded,
                label: 'Delayed tasks',
                count: effectiveDelayed,
                color: AppColors.accentRed,
              ),
            if (pendingSync > 0)
              ActionItem(
                icon: Icons.sync_problem_rounded,
                label: 'Pending sync',
                count: pendingSync,
                color: AppColors.accentOrange,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Today's Focus
        TodayFocusCard(
          items: [
            FocusItem(
              icon: Icons.today_rounded,
              text:
                  '$tasksDueToday task${tasksDueToday != 1 ? 's' : ''} due today',
              color: tasksDueToday > 0
                  ? AppColors.accentBlue
                  : AppColors.accentGreen,
            ),
            FocusItem(
              icon: Icons.description_rounded,
              text:
                  '$submittedLogs submitted log${submittedLogs != 1 ? 's' : ''}',
              color: submittedLogs > 0
                  ? AppColors.accentAmber
                  : AppColors.accentGreen,
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
