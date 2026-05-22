import 'package:construction_mobile_app/features/daily_log/domain/entities/daily_log.dart';
import 'package:construction_mobile_app/features/task/domain/entities/task.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/ethiopia_formatters.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/role_badge.dart';
import '../../../../../core/widgets/stat_card.dart';

class DashboardContent extends StatelessWidget {
  final List<Widget> children;

  const DashboardContent({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            isWide ? AppSpacing.xxl : AppSpacing.lg,
            AppSpacing.lg,
            isWide ? AppSpacing.xxl : AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}

class DashboardProjectHeader extends StatelessWidget {
  final Map<String, dynamic>? project;
  final String roleLabel;
  final Color roleColor;
  final IconData icon;

  const DashboardProjectHeader({
    super.key,
    required this.project,
    required this.roleLabel,
    required this.roleColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final projectName = _text(project?['name']) ?? 'Project Dashboard';
    final location = _text(project?['location']);
    final status = _text(project?['status']);
    final progress = projectProgress(project);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.doubleExtraLarge,
        border: Border.all(color: AppColors.borderFor(brightness)),
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF08111A), Color(0xFF0B1B2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.14),
                  borderRadius: AppRadius.medium,
                  border: Border.all(
                    color: AppColors.accentBlue.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(icon, color: AppColors.accentBlue),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        RoleBadge(label: roleLabel, color: roleColor),
                        if (status != null)
                          _HeaderPill(text: status.replaceAll('_', ' ')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (location != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.secondaryTextFor(brightness),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    location,
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: AppColors.secondaryTextFor(brightness),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AnimatedProgressBar(progress: progress),
        ],
      ),
    );
  }
}

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle.copyWith(
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: AppTextStyles.bodyMuted.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
          ),
        ],
      ],
    );
  }
}

class DashboardStatGrid extends StatelessWidget {
  final List<StatCard> cards;

  const DashboardStatGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1000 ? 4 : (width >= 620 ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: width < 380 ? 1.05 : 1.2,
          children: cards,
        );
      },
    );
  }
}

class DashboardActionGrid extends StatelessWidget {
  final List<DashboardAction> actions;

  const DashboardActionGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 900 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: width < 420 ? 2.2 : 2.8,
          children: [
            for (final action in actions) DashboardActionCard(action: action),
          ],
        );
      },
    );
  }
}

class DashboardAction {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const DashboardAction({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

class DashboardActionCard extends StatelessWidget {
  final DashboardAction action;

  const DashboardActionCard({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppCard(
      onTap: action.onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              borderRadius: AppRadius.small,
            ),
            child: Icon(action.icon, color: AppColors.accentBlue, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              action.label,
              style: AppTextStyles.label.copyWith(
                color: brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const DashboardInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.color = AppColors.accentBlue,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.small,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardOfflineBanner extends StatelessWidget {
  const DashboardOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.14),
        border: Border(
          bottom: BorderSide(color: AppColors.warning.withValues(alpha: 0.28)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.warning, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Offline mode. Cached data may be shown until sync resumes.',
              style: AppTextStyles.label.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String text;

  const _HeaderPill({required this.text});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.1),
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.24)),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.badge.copyWith(
          color: brightness == Brightness.dark
              ? AppColors.darkTextSecondary
              : AppColors.accentBlueStrong,
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final color = iconColor ?? AppColors.accentBlue;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.medium,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class QuickActionsGrid extends StatelessWidget {
  final List<QuickActionItem> actions;

  const QuickActionsGrid({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 600 ? 4 : (width >= 400 ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.0,
          children: [
            for (final action in actions)
              QuickActionCard(
                icon: action.icon,
                label: action.label,
                onTap: action.onTap,
                iconColor: action.iconColor,
              ),
          ],
        );
      },
    );
  }
}

class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });
}

String dashboardCount(Object? value) => value == null ? '--' : value.toString();

double projectProgress(Map<String, dynamic>? project) {
  final value = project?['progress_percentage'] ?? project?['progress'];
  if (value is num) return value.toDouble().clamp(0, 100).toDouble();
  if (value is String) {
    return (double.tryParse(value) ?? 0).clamp(0, 100).toDouble();
  }
  return 0;
}

String projectStatus(Map<String, dynamic>? project) {
  return _text(project?['status'])?.replaceAll('_', ' ') ?? '--';
}

String budgetSnapshot(Map<String, dynamic>? project) {
  final value = project?['total_budget'] ?? project?['contract_value'];
  if (value is num) {
    return EthiopiaFormatters.formatCurrencyCompact(value.toDouble());
  }
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      return EthiopiaFormatters.formatCurrencyCompact(parsed);
    }
  }
  return '--';
}

String taskSummary(List<Task>? tasks) {
  if (tasks == null) return '--';
  final completed = tasks.where((task) => task.status == 'completed').length;
  return '$completed / ${tasks.length}';
}

String dailyLogSummary(List<DailyLog>? logs) {
  if (logs == null) return '--';
  final submitted = logs.where((log) => log.status == 'submitted').length;
  return '$submitted / ${logs.length} submitted';
}

String latestSiteConditions(List<DailyLog>? logs) {
  if (logs == null || logs.isEmpty) return 'No site conditions logged yet.';
  final sorted = [...logs]..sort((a, b) => b.date.compareTo(a.date));
  final latest = sorted.first;
  final date = DateFormat('MMM d').format(latest.date);
  final weather = _text(latest.weather);
  final notes = _text(latest.notes);
  if (weather != null && notes != null) return '$date: $weather - $notes';
  if (weather != null) return '$date: $weather';
  if (notes != null) return '$date: $notes';
  return '$date: Latest log has no conditions.';
}

int countTasks(List<Task>? tasks, bool Function(Task task) test) {
  if (tasks == null) return 0;
  return tasks.where(test).length;
}

int countLogs(List<DailyLog>? logs, bool Function(DailyLog log) test) {
  if (logs == null) return 0;
  return logs.where(test).length;
}

List<DashboardAction> commonLogTaskActions(BuildContext context) {
  return [
    DashboardAction(
      icon: Icons.description_rounded,
      label: 'Open Logs',
      onTap: () => context.push(RouteNames.dailyLogs),
    ),
    DashboardAction(
      icon: Icons.assignment_rounded,
      label: 'Open Tasks',
      onTap: () => context.push(RouteNames.tasks),
    ),
  ];
}

void showProjectInfoSheet(
  BuildContext context,
  Map<String, dynamic>? project, {
  String? role,
}) {
  final brightness = Theme.of(context).brightness;
  final isDark = brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Info',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoRow(label: 'Name', value: _text(project?['name']) ?? '--'),
              _InfoRow(label: 'Status', value: projectStatus(project)),
              _InfoRow(
                label: 'Location',
                value: _text(project?['location']) ?? '--',
              ),
              if (_canSeeBudget(role))
                _InfoRow(label: 'Budget', value: budgetSnapshot(project)),
            ],
          ),
        ),
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.secondaryTextFor(brightness),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.label.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

String? _text(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

/// Returns true if the given role is allowed to see budget information.
/// Allowed roles: owner, project_manager.
bool _canSeeBudget(String? role) {
  const allowed = ['owner', 'project_manager'];
  final effectiveRole = role == 'owner' ? 'project_manager' : role;
  return allowed.contains(role) || allowed.contains(effectiveRole);
}

void showProjectOverviewSheet(
  BuildContext context,
  Map<String, dynamic>? project, {
  String? role,
}) {
  final brightness = Theme.of(context).brightness;
  final isDark = brightness == Brightness.dark;
  final progress = projectProgress(project);

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Overview',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoRow(label: 'Status', value: projectStatus(project)),
              _InfoRow(
                label: 'Location',
                value: _text(project?['location']) ?? '--',
              ),
              if (_canSeeBudget(role))
                _InfoRow(
                  label: 'Budget',
                  value: budgetSnapshot(project),
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Overall Progress',
                      style: AppTextStyles.label.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${progress.round()}%',
                    style: AppTextStyles.label.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (progress / 100).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightMutedSurface,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showActionRequiredSheet(
  BuildContext context, {
  int pendingApprovals = 0,
  int overdueTasks = 0,
  int pendingSync = 0,
  int pendingInvitations = 0,
}) {
  final brightness = Theme.of(context).brightness;
  final isDark = brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Action Required',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ActionItem(
                icon: Icons.pending_actions_rounded,
                label: 'Logs Awaiting Approval',
                count: pendingApprovals,
                color: AppColors.statusSubmitted,
              ),
              const SizedBox(height: AppSpacing.md),
              _ActionItem(
                icon: Icons.warning_rounded,
                label: 'Overdue/Incomplete Tasks',
                count: overdueTasks,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.md),
              _ActionItem(
                icon: Icons.sync_problem_rounded,
                label: 'Failed Sync Items',
                count: pendingSync,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              _ActionItem(
                icon: Icons.mail_outline_rounded,
                label: 'Pending Invitations',
                count: pendingInvitations,
                color: AppColors.info,
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showTodaysFocusSheet(
  BuildContext context, {
  int tasksDueToday = 0,
  int submittedLogs = 0,
  int pendingApprovals = 0,
  String? siteCondition,
}) {
  final brightness = Theme.of(context).brightness;
  final isDark = brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Focus",
                style: AppTextStyles.sectionTitle.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ActionItem(
                icon: Icons.today_rounded,
                label: 'Tasks Due Today',
                count: tasksDueToday,
                color: AppColors.accentBlue,
              ),
              const SizedBox(height: AppSpacing.md),
              _ActionItem(
                icon: Icons.description_rounded,
                label: 'Submitted Logs',
                count: submittedLogs,
                color: AppColors.success,
              ),
              const SizedBox(height: AppSpacing.md),
              _ActionItem(
                icon: Icons.pending_actions_rounded,
                label: 'Pending Approvals',
                count: pendingApprovals,
                color: AppColors.statusSubmitted,
              ),
              const SizedBox(height: AppSpacing.md),
              if (siteCondition != null) ...[
                Text(
                  'Latest Site Condition',
                  style: AppTextStyles.label.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  siteCondition,
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                ),
              ] else
                Text(
                  'No site conditions logged yet.',
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

void showKeyMetricsSheet(
  BuildContext context, {
  int overallProgress = 0,
  String budgetSpent = '--',
  int tasksDone = 0,
  int dailyLogs = 0,
  int teamMembers = 0,
  int pendingApprovals = 0,
  String? role,
}) {
  final brightness = Theme.of(context).brightness;
  final isDark = brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Key Metrics',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _MetricRow(
                label: 'Overall Progress',
                value: '$overallProgress%',
                color: AppColors.accentBlue,
              ),
              const SizedBox(height: AppSpacing.md),
              if (_canSeeBudget(role))
                _MetricRow(
                  label: 'Budget Spent',
                  value: budgetSpent,
                  color: AppColors.success,
                ),
              if (_canSeeBudget(role)) const SizedBox(height: AppSpacing.md),
              _MetricRow(
                label: 'Tasks Done',
                value: tasksDone.toString(),
                color: AppColors.info,
              ),
              const SizedBox(height: AppSpacing.md),
              _MetricRow(
                label: 'Daily Logs',
                value: dailyLogs.toString(),
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.md),
              _MetricRow(
                label: 'Team Members',
                value: teamMembers.toString(),
                color: AppColors.constructProBlue,
              ),
              const SizedBox(height: AppSpacing.md),
              _MetricRow(
                label: 'Pending Approvals',
                value: pendingApprovals.toString(),
                color: AppColors.statusSubmitted,
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showLatestUpdatesSheet(
  BuildContext context,
  List<String> updates,
) {
  final brightness = Theme.of(context).brightness;
  final isDark = brightness == Brightness.dark;

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Latest Updates',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (updates.isEmpty)
                Text(
                  'No recent updates.',
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                )
              else
                ...updates.take(3).map((update) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        update,
                        style: AppTextStyles.label.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    )),
            ],
          ),
        ),
      );
    },
  );
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.small,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.small,
          ),
          child: Text(
            count.toString(),
            style: AppTextStyles.label.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─── Premium Widgets ────────────────────────────────────────────────────────

/// Full-width KPI card with gradient background, large number, icon watermark,
/// and optional trend indicator.
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;
  final bool trendUp;
  final String? trendLabel;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.gradientStart = AppColors.brandBlueDark,
    this.gradientEnd = AppColors.brandBlue,
    this.trendUp = true,
    this.trendLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.glowBlue,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark icon
          Positioned(
            right: -4,
            top: -4,
            child: Icon(
              icon,
              size: 64,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              if (trendLabel != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      trendUp
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 16,
                      color:
                          trendUp ? AppColors.accentGreen : AppColors.accentRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trendLabel!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trendUp
                            ? AppColors.accentGreen
                            : AppColors.accentRed,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated progress bar with gradient fill and capsule shape.
class AnimatedProgressBar extends StatefulWidget {
  final double progress; // 0..100
  final double height;
  final bool showPercentage;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    this.showPercentage = true,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final value = (widget.progress / 100).clamp(0, 1).toDouble() *
                  _animation.value;
              return ClipRRect(
                borderRadius: BorderRadius.circular(widget.height / 2),
                child: Stack(
                  children: [
                    Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightMutedSurface,
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: widget.height,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3B82F6),
                              Color(0xFF06B6D4),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(widget.height / 2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.showPercentage) ...[
          const SizedBox(width: AppSpacing.md),
          Text(
            '${widget.progress.round()}%',
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact greeting banner with blue gradient and Ethiopian date.
class GreetingBanner extends StatelessWidget {
  final String firstName;

  const GreetingBanner({super.key, required this.firstName});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final ethDate = EthiopiaFormatters.formatEthiopianDate(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandBlueDark, AppColors.brandBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: AppColors.glowBlue,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $firstName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ethDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.wb_sunny_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick action button with icon, label, and press scale animation.
class QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.reverse();
  void _onTapUp(TapUpDetails _) => _scaleController.forward();
  void _onTapCancel() => _scaleController.forward();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final color = widget.iconColor ?? AppColors.accentBlue;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderFor(brightness),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: AppTextStyles.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row of 4 quick action buttons.
class QuickActionRow extends StatelessWidget {
  final List<QuickActionButton> actions;

  const QuickActionRow({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    final count = actions.length.clamp(1, 4);
    return Row(
      children: [
        for (int i = 0; i < count; i++) ...[
          Expanded(child: actions[i]),
          if (i < count - 1) const SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }
}

// ─── Daily Command Center Widgets ──────────────────────────────────────────

/// Primary CTA card for the dashboard home.
/// Compact full-width action button with icon and label.
class DashboardPrimaryCta extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accentColor;

  const DashboardPrimaryCta({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.accentColor,
  });

  @override
  State<DashboardPrimaryCta> createState() => _DashboardPrimaryCtaState();
}

class _DashboardPrimaryCtaState extends State<DashboardPrimaryCta>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.reverse();
  void _onTapUp(TapUpDetails _) => _scaleController.forward();
  void _onTapCancel() => _scaleController.forward();

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.accentBlue;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, Color.lerp(accent, Colors.white, 0.15)!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single metric item for the Today Snapshot grid.
class SnapshotMetric {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const SnapshotMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.accentBlue,
  });
}

/// Compact grid of snapshot metrics (2 columns).
class TodaySnapshotCard extends StatelessWidget {
  final List<SnapshotMetric> metrics;
  final bool isLoading;

  const TodaySnapshotCard({
    super.key,
    required this.metrics,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Snapshot',
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.8,
            children: metrics.map((m) => _SnapshotMetricTile(metric: m)).toList(),
          ),
        ],
      ),
    );
  }
}

class _SnapshotMetricTile extends StatelessWidget {
  final SnapshotMetric metric;

  const _SnapshotMetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: metric.color.withValues(alpha: 0.06),
        borderRadius: AppRadius.small,
      ),
      child: Row(
        children: [
          Icon(metric.icon, size: 16, color: metric.color),
          const SizedBox(width: AppSpacing.xs + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.value,
                  style: AppTextStyles.label.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  metric.label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryTextFor(
                        Theme.of(context).brightness),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact Action Required card.
/// Shows a list of action items or an all-clear state.
class ActionRequiredCard extends StatelessWidget {
  final List<ActionItem> items;
  final bool allClear;

  const ActionRequiredCard({
    super.key,
    required this.items,
    this.allClear = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allClear ? Icons.check_circle_rounded : Icons.priority_high_rounded,
                size: 16,
                color: allClear ? AppColors.accentGreen : AppColors.accentAmber,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                allClear ? 'All clear' : 'Needs attention',
                style: AppTextStyles.label.copyWith(
                  color: allClear ? AppColors.accentGreen : AppColors.accentAmber,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (allClear)
            Text(
              'No urgent items pending',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryTextFor(Theme.of(context).brightness),
              ),
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: AppRadius.small,
                        ),
                        child: Icon(item.icon, size: 14, color: item.color),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: AppRadius.small,
                        ),
                        child: Text(
                          item.count.toString(),
                          style: AppTextStyles.badge.copyWith(
                            color: item.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class ActionItem {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const ActionItem({
    required this.icon,
    required this.label,
    required this.count,
    this.color = AppColors.accentAmber,
  });
}

/// Compact Today's Focus card.
class TodayFocusCard extends StatelessWidget {
  final List<FocusItem> items;

  const TodayFocusCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Focus',
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (items.isEmpty)
            Text(
              'Nothing specific due today',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryTextFor(Theme.of(context).brightness),
              ),
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 14, color: item.color),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          item.text,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class FocusItem {
  final IconData icon;
  final String text;
  final Color color;

  const FocusItem({
    required this.icon,
    required this.text,
    this.color = AppColors.accentBlue,
  });
}

/// Compact Latest Updates card.
class LatestUpdatesCard extends StatelessWidget {
  final String? updateText;
  final String? subtitle;

  const LatestUpdatesCard({
    super.key,
    this.updateText,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasUpdate = updateText != null && updateText!.isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasUpdate ? Icons.update_rounded : Icons.info_outline_rounded,
                size: 14,
                color: AppColors.mutedTextFor(Theme.of(context).brightness),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                'Latest Updates',
                style: AppTextStyles.label.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasUpdate ? updateText! : 'No recent updates',
            style: AppTextStyles.caption.copyWith(
              color: hasUpdate
                  ? (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)
                  : AppColors.mutedTextFor(Theme.of(context).brightness),
              fontSize: 12,
            ),
          ),
          if (subtitle != null && hasUpdate) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.mutedTextFor(Theme.of(context).brightness),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
