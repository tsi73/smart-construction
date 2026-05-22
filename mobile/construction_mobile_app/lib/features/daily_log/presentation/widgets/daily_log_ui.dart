import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/daily_log.dart';

class DailyLogStatusBadge extends StatelessWidget {
  final String status;

  const DailyLogStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      status: status,
      label: status.replaceAll('_', ' '),
    );
  }
}

class SyncStatusBadge extends StatelessWidget {
  final String syncStatus;

  const SyncStatusBadge({super.key, required this.syncStatus});

  @override
  Widget build(BuildContext context) {
    final status = syncStatus.toLowerCase();
    if (status == 'synced') return const SizedBox.shrink();

    final color = status == 'failed' || status == 'sync_failed'
        ? AppColors.error
        : AppColors.warning;
    final icon = status == 'failed' || status == 'sync_failed'
        ? Icons.sync_problem_rounded
        : Icons.sync_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.small,
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: AppTextStyles.badge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class DailyLogSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? emptyText;

  const DailyLogSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  borderRadius: AppRadius.small,
                ),
                child: Icon(icon, color: AppColors.accentBlue, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (children.isEmpty)
            Text(
              emptyText ?? 'No entries recorded.',
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.secondaryTextFor(brightness),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

class TimelineStep extends StatelessWidget {
  final String label;
  final bool complete;
  final bool active;
  final bool isLast;
  final Widget? subtitle;

  const TimelineStep({
    super.key,
    required this.label,
    required this.complete,
    required this.active,
    this.isLast = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = complete || active
        ? AppColors.accentBlue
        : AppColors.mutedTextFor(brightness);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    color.withValues(alpha: complete || active ? 0.16 : 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.42)),
              ),
              child: complete
                  ? Icon(Icons.check_rounded, size: 15, color: color)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28 + (subtitle != null ? 20.0 : 0.0),
                color: color.withValues(alpha: 0.24),
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      AppTextStyles.label.copyWith(color: color, fontSize: 13),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  subtitle!,
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DailyLogLoadingList extends StatelessWidget {
  const DailyLogLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _skeleton(context, double.infinity, 18),
            const SizedBox(height: AppSpacing.md),
            _skeleton(context, 180, 14),
            const SizedBox(height: AppSpacing.sm),
            _skeleton(context, double.infinity, 44),
          ],
        ),
      ),
    );
  }

  Widget _skeleton(BuildContext context, double width, double height) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightMutedSurface,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

String formatLogDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

String statusLabel(String status) => status.replaceAll('_', ' ');

int countLogsByStatus(List<DailyLog> logs, String status) {
  return logs.where((log) => log.status == status).length;
}
