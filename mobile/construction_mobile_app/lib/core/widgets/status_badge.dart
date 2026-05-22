import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.badge.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
      case 'task_pending':
      case 'pending':
        return AppColors.statusDraft;
      case 'submitted':
        return AppColors.statusSubmitted;
      case 'consultant_approved':
        return AppColors.statusConsultantApproved;
      case 'approved':
      case 'pm_approved':
        return AppColors.statusApproved;
      case 'rejected':
        return AppColors.statusRejected;
      case 'pending_sync':
        return AppColors.statusPendingSync;
      case 'sync_failed':
      case 'failed':
        return AppColors.statusSyncFailed;
      case 'offline':
        return AppColors.statusOffline;
      case 'in_progress':
        return AppColors.statusTaskInProgress;
      case 'completed':
        return AppColors.statusTaskCompleted;
      default:
        return AppColors.statusDraft;
    }
  }
}
