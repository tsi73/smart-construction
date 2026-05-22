import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../core/storage/sync_queue_data_source.dart';
import '../../../../core/storage/sync_queue_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/status_badge.dart';

class SyncQueuePage extends ConsumerWidget {
  const SyncQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pendingItemsAsync = ref.watch(syncQueueItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.syncQueue),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: l10n.syncNow,
            onPressed: () async {
              await ref.read(syncQueueRepositoryProvider).processQueue();
              ref.invalidate(syncQueueItemsProvider);
            },
          ),
        ],
      ),
      body: pendingItemsAsync.when(
        data: (items) => ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveContent(
              maxWidth: 860,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: l10n.syncQueue,
                    subtitle: l10n.syncQueueSubtitle,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (kIsWeb) ...[
                    _LimitedModeBanner(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _SyncSummary(items: items),
                  const SizedBox(height: AppSpacing.xl),
                  if (items.isEmpty)
                    EmptyState(
                      title: l10n.syncQueueEmpty,
                      message: l10n.syncQueueEmptyMessage,
                      icon: Icons.cloud_done_outlined,
                    )
                  else
                    for (final item in items) _SyncItemCard(item: item),
                ],
              ),
            ),
          ],
        ),
        loading: () => const ResponsiveContent(
          maxWidth: 860,
          child: _SyncLoading(),
        ),
        error: (_, __) => ErrorState(
          title: l10n.syncQueueUnavailable,
          message: l10n.syncQueueUnavailableMessage,
          action: SizedBox(
            width: 160,
            child: AppButton(
              text: l10n.retry,
              size: AppButtonSize.medium,
              onPressed: () => ref.invalidate(syncQueueItemsProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _LimitedModeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      color: AppColors.statusPendingSync.withValues(alpha: 0.08),
      border: BorderSide(
        color: AppColors.statusPendingSync.withValues(alpha: 0.24),
      ),
      shadow: const [],
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.statusPendingSync),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              l10n.browserSyncLimitedMessage,
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.statusPendingSync,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncSummary extends StatelessWidget {
  final List<SyncItem> items;

  const _SyncSummary({required this.items});

  @override
  Widget build(BuildContext context) {
    final failed = items.where((item) => item.status == 'failed').length;
    final synced = items.where((item) => item.status == 'synced').length;
    final pending = items.length - failed - synced;
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _SummaryChip(
          label: l10n.pending,
          value: pending.toString(),
          icon: Icons.schedule_rounded,
          color: AppColors.statusPendingSync,
        ),
        _SummaryChip(
          label: l10n.failed,
          value: failed.toString(),
          icon: Icons.error_outline_rounded,
          color: AppColors.error,
        ),
        _SummaryChip(
          label: l10n.synced,
          value: synced.toString(),
          icon: Icons.cloud_done_outlined,
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppCard(
      shadow: const [],
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(color: color),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncItemCard extends ConsumerWidget {
  final SyncItem item;

  const _SyncItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final brightness = Theme.of(context).brightness;
    final statusColor = _statusColor(item.status);
    final createdLabel = DateFormat.yMMMd().format(item.createdAt);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.medium,
                ),
                child: Icon(_statusIcon(item.status),
                    color: statusColor, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _entityLabel(item.entityType),
                      style: AppTextStyles.cardTitle.copyWith(
                        color: brightness == Brightness.dark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _operationLabel(item.operationType, l10n),
                      style: AppTextStyles.bodyMuted.copyWith(
                        color: AppColors.secondaryTextFor(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                status: item.status,
                label: _statusLabel(item.status, l10n),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaPill(icon: Icons.today_rounded, label: createdLabel),
              _MetaPill(
                icon: Icons.repeat_rounded,
                label: l10n.attempts(item.attemptCount),
              ),
            ],
          ),
          if (item.lastError != null && item.lastError!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: AppRadius.medium,
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.18)),
              ),
              child: Text(
                l10n.syncItemFailedMessage,
                style: AppTextStyles.bodyMuted.copyWith(color: AppColors.error),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              if (item.status == 'failed') ...[
                Expanded(
                  child: AppButton(
                    text: l10n.retry,
                    icon: Icons.refresh_rounded,
                    size: AppButtonSize.medium,
                    onPressed: () async {
                      await ref
                          .read(syncQueueRepositoryProvider)
                          .processQueue();
                      ref.invalidate(syncQueueItemsProvider);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: AppButton(
                  text: l10n.delete,
                  icon: Icons.delete_outline_rounded,
                  size: AppButtonSize.medium,
                  isOutline: true,
                  isDanger: true,
                  onPressed: () async {
                    if (item.localId != null) {
                      await ref
                          .read(syncQueueDataSourceProvider)
                          .deleteItem(item.localId!);
                      ref.invalidate(syncQueueItemsProvider);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'failed':
        return AppColors.error;
      case 'synced':
        return AppColors.success;
      case 'syncing':
        return AppColors.accentBlue;
      default:
        return AppColors.statusPendingSync;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'failed':
        return Icons.error_outline_rounded;
      case 'synced':
        return Icons.cloud_done_outlined;
      case 'syncing':
        return Icons.sync_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'failed':
        return l10n.failed;
      case 'synced':
        return l10n.synced;
      case 'syncing':
        return l10n.sync;
      default:
        return l10n.pending;
    }
  }

  String _operationLabel(String operation, AppLocalizations l10n) {
    switch (operation) {
      case 'create':
        return l10n.creatingRecord;
      case 'update':
        return l10n.updatingRecord;
      default:
        return operation;
    }
  }

  String _entityLabel(String entityType) {
    return entityType
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({
    required this.icon,
    required this.label,
  });

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
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.mutedTextFor(brightness)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncLoading extends StatelessWidget {
  const _SyncLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LoadingSkeleton(
            width: double.infinity, height: 76, borderRadius: 16),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < 4; i++) ...[
          const LoadingSkeleton(
              width: double.infinity, height: 144, borderRadius: 16),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

final syncQueueItemsProvider = FutureProvider<List<SyncItem>>((ref) async {
  final repo = ref.watch(syncQueueRepositoryProvider);
  final result = await repo.getPendingItems();
  return result.fold((failure) => throw failure, (items) => items);
});
