import 'package:construction_mobile_app/features/daily_log/presentation/controllers/daily_log_controller.dart';
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

class ConsultantDashboardBody extends ConsumerWidget {
  const ConsultantDashboardBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(currentProjectProvider);
    final projectId = (project?['id'] ?? '').toString();
    final tasks = ref.watch(projectTasksProvider(projectId));
    final logs = ref.watch(projectLogsProvider(projectId));
    final taskList = tasks.valueOrNull;
    final logList = logs.valueOrNull;
    final submitted = countLogs(logList, (log) => log.status == 'submitted');
    final approved = countLogs(
      logList,
      (log) => log.status == 'consultant_approved' || log.status == 'approved',
    );
    final rejected = countLogs(logList, (log) => log.status == 'rejected');
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
        // Primary CTA: Review Submitted Logs
        DashboardPrimaryCta(
          icon: Icons.rate_review_rounded,
          label: 'Review Submitted Logs',
          onTap: () => context.push(RouteNames.dailyLogs),
          accentColor: AppColors.statusConsultantApproved,
        ),
        const SizedBox(height: AppSpacing.md),
        // Today Snapshot
        TodaySnapshotCard(
          metrics: [
            SnapshotMetric(
              icon: Icons.pending_actions_rounded,
              label: 'Awaiting Review',
              value: logsLoading ? '--' : dashboardCount(submitted),
              color:
                  submitted > 0 ? AppColors.accentAmber : AppColors.accentGreen,
            ),
            SnapshotMetric(
              icon: Icons.verified_rounded,
              label: 'Recently Reviewed',
              value: logsLoading ? '--' : dashboardCount(approved),
              color: AppColors.accentGreen,
            ),
            SnapshotMetric(
              icon: Icons.cancel_rounded,
              label: 'Rejected',
              value: logsLoading ? '--' : dashboardCount(rejected),
              color: rejected > 0 ? AppColors.accentRed : AppColors.accentGreen,
            ),
            SnapshotMetric(
              icon: Icons.speed_rounded,
              label: 'Task Progress',
              value: tasksLoading ? '--' : taskSummary(taskList),
              color: AppColors.accentBlue,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Action Required
        ActionRequiredCard(
          allClear: submitted == 0 && rejected == 0,
          items: [
            if (submitted > 0)
              ActionItem(
                icon: Icons.pending_actions_rounded,
                label: 'Submitted logs awaiting review',
                count: submitted,
                color: AppColors.accentAmber,
              ),
            if (rejected > 0)
              ActionItem(
                icon: Icons.cancel_rounded,
                label: 'Rejected logs',
                count: rejected,
                color: AppColors.accentRed,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Today's Focus
        TodayFocusCard(
          items: [
            FocusItem(
              icon: Icons.pending_actions_rounded,
              text:
                  '$submitted log${submitted != 1 ? 's' : ''} awaiting review',
              color:
                  submitted > 0 ? AppColors.accentAmber : AppColors.accentGreen,
            ),
            FocusItem(
              icon: Icons.verified_rounded,
              text: '$approved recently reviewed',
              color: AppColors.accentGreen,
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
