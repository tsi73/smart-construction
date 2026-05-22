import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/ethiopia_formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/role_guard.dart';
import '../../domain/entities/daily_log.dart';
import '../controllers/daily_log_controller.dart';
import '../widgets/daily_log_ui.dart';
import '../../../project/presentation/providers/project_provider.dart';

class DailyLogDetailPage extends ConsumerWidget {
  final String logId;

  const DailyLogDetailPage({super.key, required this.logId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logAsync = ref.watch(dailyLogDetailProvider(logId));
    final role = ref.watch(currentProjectRoleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Daily Log Details'),
        actions: [
          logAsync.maybeWhen(
            data: (log) => IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Share Summary',
              onPressed: () => Share.share(_buildShareSummary(log)),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: logAsync.when(
        data: (log) => _LogDetailContent(log: log, role: role),
        loading: () => const DailyLogLoadingList(),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppCard(
              child: Text(
                'Error: $err',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildShareSummary(DailyLog log) {
    final totalCost = log.labor.fold(0.0, (sum, item) => sum + item.cost) +
        log.materials.fold(0.0, (sum, item) => sum + item.cost) +
        log.equipment.fold(0.0, (sum, item) => sum + item.cost);

    return '''
Daily Site Report – ${DateFormat('dd MMM yyyy').format(log.date)}
Project: ${log.projectId}
Status: ${log.status}
Weather: ${log.weather ?? 'N/A'}
Notes: ${log.notes}
Labor entries: ${log.labor.length}
Materials entries: ${log.materials.length}
Equipment entries: ${log.equipment.length}
Total Cost: ETB ${totalCost.toStringAsFixed(2)}''';
  }
}

class _LogDetailContent extends ConsumerWidget {
  final DailyLog log;
  final String? role;

  const _LogDetailContent({required this.log, this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (log.status == 'rejected') ...[
                    _RejectedLogCard(log: log),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _StatusHeader(log: log),
                  const SizedBox(height: AppSpacing.md),
                  _ApprovalTimeline(log: log),
                  if (log.labor.isNotEmpty ||
                      log.materials.isNotEmpty ||
                      log.equipment.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _CostSummaryCard(log: log),
                  ],
                  if (log.rejectionReason != null &&
                      log.rejectionReason!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _RejectionCard(reason: log.rejectionReason!.trim()),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _BasicInfoCard(log: log),
                  const SizedBox(height: AppSpacing.md),
                  DailyLogSection(
                    title: 'Shift',
                    icon: Icons.schedule_rounded,
                    emptyText: 'No shifts recorded.',
                    children: [
                      for (final shift in log.shifts)
                        _ResourceLine(title: shift.shiftType),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DailyLogSection(
                    title: 'Labor',
                    icon: Icons.groups_rounded,
                    emptyText: 'No labor recorded.',
                    children: [
                      for (final item in log.labor)
                        _ResourceLine(
                          title: item.workerType,
                          subtitle:
                              '${item.hoursWorked} hrs - ETB ${item.cost.toStringAsFixed(2)}',
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DailyLogSection(
                    title: 'Materials',
                    icon: Icons.inventory_2_rounded,
                    emptyText: 'No materials recorded.',
                    children: [
                      for (final item in log.materials)
                        _ResourceLine(
                          title: item.name,
                          subtitle:
                              '${item.quantity} ${item.unit} - ETB ${item.cost.toStringAsFixed(2)}',
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DailyLogSection(
                    title: 'Equipment',
                    icon: Icons.precision_manufacturing_rounded,
                    emptyText: 'No equipment recorded.',
                    children: [
                      for (final item in log.equipment)
                        _ResourceLine(
                          title: item.name,
                          subtitle:
                              '${item.hoursUsed} hrs - ETB ${item.cost.toStringAsFixed(2)}',
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (log.status == 'draft') ...[
                    _DraftActions(log: log),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _ActionButtons(log: log, role: role),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RejectedLogCard extends StatelessWidget {
  final DailyLog log;

  const _RejectedLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'This log was rejected',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          if (log.rejectionReason != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Reason: ${log.rejectionReason}',
              style: AppTextStyles.bodyMuted,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Create Revised Log',
            icon: Icons.refresh_rounded,
            onPressed: () => context.push(
              '${RouteNames.dailyLogs}/new?taskId=${log.taskId ?? ''}',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Submit a new corrected log for review',
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DraftActions extends ConsumerWidget {
  final DailyLog log;

  const _DraftActions({required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(dailyLogControllerProvider).isLoading;

    if (log.id == null) return const SizedBox.shrink();

    return RoleGuard(
      allowedRoles: const ['site_engineer'],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 420;
          final buttons = [
            AppButton(
              text: 'Edit & Submit',
              icon: Icons.edit_rounded,
              isOutline: true,
              onPressed: () => _showEditDraftDialog(context),
            ),
            AppButton(
              text: 'Submit for Review',
              icon: Icons.send_rounded,
              isLoading: isLoading,
              onPressed: () => _submitDraft(context, ref),
            ),
          ];

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < buttons.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  buttons[i],
                ],
              ],
            );
          }

          return Row(
            children: [
              for (int i = 0; i < buttons.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                Expanded(child: buttons[i]),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showEditDraftDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Draft'),
        content: const Text(
          'This will open a new log form. Your draft is saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push(
                '${RouteNames.dailyLogs}/new?taskId=${log.taskId ?? ''}',
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDraft(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    // Validate before submission
    String? validationError;

    // Check required fields
    if (log.notes.trim().isEmpty) {
      validationError = l10n.validationError;
    } else if (log.shifts.isEmpty) {
      validationError = l10n.validationErrorShift;
    }

    // Validate labor entries if any exist
    if (validationError == null) {
      for (int i = 0; i < log.labor.length; i++) {
        final labor = log.labor[i];
        if (labor.workerType.trim().isEmpty) {
          validationError = l10n.validationErrorLaborType(i + 1);
          break;
        }
        if (labor.hoursWorked <= 0) {
          validationError = l10n.validationErrorLaborHours(i + 1);
          break;
        }
        if (labor.cost < 0) {
          validationError = l10n.validationErrorLaborCost(i + 1);
          break;
        }
      }
    }

    // Validate material entries if any exist
    if (validationError == null) {
      for (int i = 0; i < log.materials.length; i++) {
        final material = log.materials[i];
        if (material.name.trim().isEmpty) {
          validationError = l10n.validationErrorMaterialName(i + 1);
          break;
        }
        if (material.quantity <= 0) {
          validationError = l10n.validationErrorMaterialQuantity(i + 1);
          break;
        }
        if (material.unit.trim().isEmpty) {
          validationError = l10n.validationErrorMaterialUnit(i + 1);
          break;
        }
        if (material.cost < 0) {
          validationError = l10n.validationErrorMaterialCost(i + 1);
          break;
        }
      }
    }

    // Validate equipment entries if any exist
    if (validationError == null) {
      for (int i = 0; i < log.equipment.length; i++) {
        final equipment = log.equipment[i];
        if (equipment.name.trim().isEmpty) {
          validationError = l10n.validationErrorEquipmentName(i + 1);
          break;
        }
        if (equipment.hoursUsed <= 0) {
          validationError = l10n.validationErrorEquipmentHours(i + 1);
          break;
        }
        if (equipment.cost < 0) {
          validationError = l10n.validationErrorEquipmentCost(i + 1);
          break;
        }
      }
    }

    // Validate shift entries
    if (validationError == null) {
      for (int i = 0; i < log.shifts.length; i++) {
        final shift = log.shifts[i];
        if (shift.shiftType.trim().isEmpty) {
          validationError = l10n.validationErrorShiftType(i + 1);
          break;
        }
      }
    }

    if (validationError != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    await ref.read(dailyLogControllerProvider.notifier).submitLog(log.id!);
    if (!context.mounted) return;

    ref.invalidate(dailyLogDetailProvider(log.id!));
    ref.invalidate(projectLogsProvider(log.projectId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.submitLog)),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final DailyLog log;

  const _StatusHeader({required this.log});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  formatLogDate(log.date),
                  style: AppTextStyles.screenTitle.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DailyLogStatusBadge(status: log.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _HeaderMeta(
                icon: Icons.cloud_queue_rounded,
                text: log.weather?.trim().isNotEmpty == true
                    ? log.weather!.trim()
                    : 'No site conditions',
              ),
              if (log.taskId != null && log.taskId!.trim().isNotEmpty)
                const _HeaderMeta(
                  icon: Icons.assignment_rounded,
                  text: 'Task linked',
                ),
              if (log.createdBy != null && log.createdBy!.trim().isNotEmpty)
                _HeaderMeta(
                  icon: Icons.person_outline_rounded,
                  text: log.createdBy!.trim(),
                ),
              SyncStatusBadge(syncStatus: log.syncStatus),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApprovalTimeline extends StatelessWidget {
  final DailyLog log;

  const _ApprovalTimeline({required this.log});

  @override
  Widget build(BuildContext context) {
    final status = log.status;
    final submitted = _isAtLeast(status, 'submitted');
    final officeApproved = _isAtLeast(status, 'office_approved');
    final consultantApproved = _isAtLeast(status, 'consultant_approved');
    final pmApproved =
        _isAtLeast(status, 'pm_approved') || status == 'approved';

    return DailyLogSection(
      title: 'Approval Timeline',
      icon: Icons.timeline_rounded,
      children: [
        TimelineStep(
          label: 'Draft',
          complete: true,
          active: status == 'draft',
        ),
        TimelineStep(
          label: 'Submitted',
          complete: submitted,
          active: status == 'submitted',
        ),
        TimelineStep(
          label: 'Office Review',
          complete: officeApproved,
          active: status == 'office_approved',
        ),
        TimelineStep(
          label: 'Consultant Approval',
          complete: consultantApproved,
          active: status == 'consultant_approved',
        ),
        TimelineStep(
          label: 'PM Final Approval',
          complete: pmApproved,
          active: pmApproved,
          isLast: true,
        ),
      ],
    );
  }

  bool _isAtLeast(String status, String step) {
    final order = [
      'draft',
      'submitted',
      'office_approved',
      'consultant_approved',
      'pm_approved'
    ];
    final current = status == 'approved' ? 'pm_approved' : status;
    return order.indexOf(current) >= order.indexOf(step);
  }
}

class _RejectionCard extends StatelessWidget {
  final String reason;

  const _RejectionCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      border: BorderSide(color: AppColors.error.withValues(alpha: 0.45)),
      color: AppColors.error.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rejection Reason',
            style: AppTextStyles.cardTitle.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(reason, style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }
}

class _BasicInfoCard extends StatelessWidget {
  final DailyLog log;

  const _BasicInfoCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final notes = log.notes.trim();

    return DailyLogSection(
      title: 'Basic Info',
      icon: Icons.article_rounded,
      children: [
        _ResourceLine(
          title: 'Site Conditions',
          subtitle: log.weather?.trim().isNotEmpty == true
              ? log.weather!.trim()
              : '--',
        ),
        const SizedBox(height: AppSpacing.sm),
        _ResourceLine(
          title: 'Notes',
          subtitle: notes.isEmpty ? 'No notes recorded.' : notes,
        ),
      ],
    );
  }
}

class _HeaderMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lightMutedSurface,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondaryTextFor(brightness)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceLine extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _ResourceLine({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 18, color: AppColors.accentBlue),
          const SizedBox(width: AppSpacing.sm),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  final DailyLog log;
  final String? role;

  const _ActionButtons({required this.log, this.role});

  void _refreshProviders(WidgetRef ref) {
    // Refresh the detail provider to show updated status
    ref.invalidate(dailyLogDetailProvider(log.id!));
    // If we have the project ID, refresh the list provider too
    final currentProject = ref.read(currentProjectProvider);
    if (currentProject != null && currentProject['id'] != null) {
      ref.invalidate(projectLogsProvider(currentProject['id']));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(dailyLogControllerProvider).isLoading;

    if (log.id == null) return const SizedBox.shrink();

    // Site engineer: can resubmit rejected logs
    if (log.status == 'rejected') {
      return RoleGuard(
        allowedRoles: const ['site_engineer'],
        child: AppButton(
          text: 'Submit Log',
          icon: Icons.upload_rounded,
          isLoading: isLoading,
          onPressed: () => _confirm(
            context,
            title: 'Submit Log',
            message: 'Submit this daily log for approval?',
            actionLabel: 'Submit',
            onConfirm: () => ref
                .read(dailyLogControllerProvider.notifier)
                .submitLog(log.id!),
            onSuccess: () => _refreshProviders(ref),
          ),
        ),
      );
    }

    // Consultant and PM: can approve (submitted) and reject
    if (log.status == 'submitted') {
      return RoleGuard(
        allowedRoles: const [
          'consultant',
          'project_manager',
          'owner'
        ],
        child: _ApprovalActions(
          isLoading: isLoading,
          approveText: 'Approve',
          approveRoles: const ['consultant'],
          rejectRoles: const [
            'consultant',
            'project_manager',
            'owner'
          ],
          onApprove: () => _confirm(
            context,
            title: 'Approve Log',
            message: 'Approve this daily log for consultant review?',
            actionLabel: 'Approve',
            onConfirm: () => ref
                .read(dailyLogControllerProvider.notifier)
                .reviewLog(log.id!, true),
            onSuccess: () => _refreshProviders(ref),
          ),
          onReject: () => _showRejectSheet(context, ref),
        ),
      );
    }

    // Consultant: can approve (office_approved) and reject
    if (log.status == 'office_approved') {
      return RoleGuard(
        allowedRoles: const ['consultant', 'project_manager', 'owner'],
        child: _ApprovalActions(
          isLoading: isLoading,
          approveText: 'Consultant Approve',
          approveRoles: const ['consultant'],
          rejectRoles: const [
            'consultant',
            'project_manager',
            'owner'
          ],
          onApprove: () => _confirm(
            context,
            title: 'Approve Log',
            message: 'Approve this daily log as consultant?',
            actionLabel: 'Approve',
            onConfirm: () => ref
                .read(dailyLogControllerProvider.notifier)
                .approveLog(log.id!, false),
            onSuccess: () => _refreshProviders(ref),
          ),
          onReject: () => _showRejectSheet(context, ref),
        ),
      );
    }

    // Project manager / owner: final approve (consultant_approved) and reject
    if (log.status == 'consultant_approved') {
      return RoleGuard(
        allowedRoles: const ['project_manager', 'owner'],
        child: _ApprovalActions(
          isLoading: isLoading,
          approveText: 'Final Approve',
          approveRoles: const ['project_manager', 'owner'],
          rejectRoles: const [
            'consultant',
            'project_manager',
            'owner'
          ],
          onApprove: () => _confirm(
            context,
            title: 'Approve Log',
            message: 'Give final PM approval for this daily log?',
            actionLabel: 'Approve',
            onConfirm: () => ref
                .read(dailyLogControllerProvider.notifier)
                .approveLog(log.id!, true),
            onSuccess: () => _refreshProviders(ref),
          ),
          onReject: () => _showRejectSheet(context, ref),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
    required Future<void> Function() onConfirm,
    required VoidCallback onSuccess,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(message, style: AppTextStyles.bodyMuted),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: actionLabel,
                onPressed: () async {
                  await onConfirm();
                  if (context.mounted) {
                    Navigator.pop(context);
                    onSuccess();
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: 'Cancel',
                isOutline: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectSheet(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Reject Log', style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Rejection Reason',
                hint: 'Enter reason for rejection...',
                controller: reasonController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: 'Reject Log',
                isDanger: true,
                onPressed: () async {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) return;
                  await ref
                      .read(dailyLogControllerProvider.notifier)
                      .rejectLog(log.id!, reason);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _refreshProviders(ref);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostSummaryCard extends StatelessWidget {
  final DailyLog log;

  const _CostSummaryCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final laborCost = log.labor.fold(0.0, (sum, l) => sum + l.cost);
    final matCost = log.materials.fold(0.0, (sum, m) => sum + m.cost);
    final eqCost = log.equipment.fold(0.0, (sum, e) => sum + e.cost);
    final total = laborCost + matCost + eqCost;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Cost Summary', style: AppTextStyles.sectionTitle),
          const SizedBox(height: AppSpacing.md),
          _CostRow(label: 'Labor', amount: laborCost),
          _CostRow(label: 'Materials', amount: matCost),
          _CostRow(label: 'Equipment', amount: eqCost),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                EthiopiaFormatters.formatCurrency(total),
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.constructProBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final double amount;

  const _CostRow({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMuted),
          Text(
            EthiopiaFormatters.formatCurrency(amount),
            style: AppTextStyles.label,
          ),
        ],
      ),
    );
  }
}

class _ApprovalActions extends ConsumerWidget {
  final bool isLoading;
  final String approveText;
  final List<String> approveRoles;
  final List<String> rejectRoles;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalActions({
    required this.isLoading,
    required this.approveText,
    required this.approveRoles,
    required this.rejectRoles,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canApprove = isRoleAllowed(ref, approveRoles);
    final canReject = isRoleAllowed(ref, rejectRoles);

    if (!canApprove && !canReject) return const SizedBox.shrink();

    final approveBtn = AppButton(
      text: approveText,
      isLoading: isLoading,
      onPressed: onApprove,
    );
    final rejectBtn = AppButton(
      text: 'Reject Log',
      isDanger: true,
      isLoading: isLoading,
      onPressed: onReject,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 420;
        final buttons = <Widget>[
          if (canReject) rejectBtn,
          if (canApprove) approveBtn,
        ];

        if (buttons.isEmpty) return const SizedBox.shrink();

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < buttons.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                buttons[i],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.md),
              Expanded(child: buttons[i]),
            ],
          ],
        );
      },
    );
  }
}
