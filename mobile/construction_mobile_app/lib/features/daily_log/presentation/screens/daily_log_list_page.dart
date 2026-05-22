import 'package:flutter/material.dart';
// ignore_for_file: avoid_print
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/daily_log.dart';
import '../controllers/daily_log_controller.dart';
import '../widgets/daily_log_ui.dart';
import '../../../project/presentation/providers/project_provider.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_filter_chips.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/state_widgets.dart';

const _kAllFilterValue = '__all__';

class DailyLogListPage extends ConsumerStatefulWidget {
  final String projectId;

  const DailyLogListPage({super.key, required this.projectId});

  @override
  ConsumerState<DailyLogListPage> createState() => _DailyLogListPageState();
}

class _DailyLogListPageState extends ConsumerState<DailyLogListPage> {
  String? _filterStatus;
  DateTime? _dateFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.projectId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Project not selected. Please select a project first.'),
              backgroundColor: AppColors.error,
            ),
          );
          context.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(projectLogsProvider(widget.projectId));
    final role = ref.watch(currentProjectRoleProvider);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    if (widget.projectId.isEmpty) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Daily Logs'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 36,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Project not selected',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Please select a project to view daily logs.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: AppColors.secondaryTextFor(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: 'Go to Projects',
                    onPressed: () => context.push(RouteNames.projects),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final filterChips = _buildFilterChipsForRole(role);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Daily Logs'),
        actions: [
          IconButton(
            icon: Icon(
              _dateFilter == null
                  ? Icons.calendar_month_rounded
                  : Icons.event_busy_rounded,
            ),
            onPressed: _pickOrClearDate,
            tooltip: _dateFilter == null ? 'Filter by date' : 'Clear date',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: logsAsync.when(
        data: (logList) {
          final filteredLogs = _filteredLogs(logList);
          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(projectLogsProvider(widget.projectId).future),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 940),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _FilterAndSummaryBar(
                        filterChips: filterChips,
                        filterStatus: _filterStatus ?? _kAllFilterValue,
                        onFilterChanged: (value) {
                          setState(() => _filterStatus =
                              value == _kAllFilterValue ? null : value);
                        },
                        logList: logList,
                        searchQuery: _searchQuery,
                        onSearchChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                    ),
                    if (filteredLogs.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _filterStatus != null
                            ? _FilteredEmptyState(filterStatus: _filterStatus!)
                            : EmptyState(
                                title: logList.isEmpty
                                    ? 'No daily logs yet'
                                    : 'No logs match filters',
                                message: logList.isEmpty
                                    ? 'Daily logs are created within assigned tasks. Go to Tasks to create daily logs.'
                                    : 'Try adjusting the selected status filter.',
                                icon: Icons.description_rounded,
                                action: null,
                              ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xxl,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final log = filteredLogs[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md),
                                child: _AnimatedLogCard(
                                  index: index,
                                  log: log,
                                  role: role,
                                  projectId: widget.projectId,
                                ),
                              );
                            },
                            childCount: filteredLogs.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => _CompactLoadingList(),
        error: (err, stack) => ErrorState(
          title: 'Couldn\'t load daily logs',
          message: err.toString().length > 100
              ? 'Failed to load daily logs. Please try again.'
              : err.toString(),
          action: AppButton(
            text: 'Retry',
            icon: Icons.refresh_rounded,
            size: AppButtonSize.medium,
            onPressed: () =>
                ref.invalidate(projectLogsProvider(widget.projectId)),
          ),
        ),
      ),
      // Daily log creation is now only available within task details
      // Remove the FAB to make this list view-only
    );
  }

  List<AppFilterChip> _buildFilterChipsForRole(String? role) {
    final effectiveRole = role == 'owner' ? 'project_manager' : role;

    switch (effectiveRole) {
      case 'site_engineer':
        return const [
          AppFilterChip(label: 'All', value: _kAllFilterValue),
          AppFilterChip(label: 'Draft', value: 'draft'),
          AppFilterChip(label: 'Submitted', value: 'submitted'),
          AppFilterChip(label: 'Rejected', value: 'rejected'),
          AppFilterChip(label: 'Approved', value: 'pm_approved'),
        ];
      case 'consultant':
        return const [
          AppFilterChip(label: 'All', value: _kAllFilterValue),
          AppFilterChip(label: 'Needs Review', value: 'submitted'),
          AppFilterChip(label: 'Approved by Me', value: 'consultant_approved'),
          AppFilterChip(label: 'PM Approved', value: 'pm_approved'),
        ];
      case 'project_manager':
        return const [
          AppFilterChip(label: 'All', value: _kAllFilterValue),
          AppFilterChip(label: 'Pending Review', value: 'submitted'),
          AppFilterChip(label: 'Needs Approval', value: 'consultant_approved'),
          AppFilterChip(label: 'Approved', value: 'pm_approved'),
          AppFilterChip(label: 'Rejected', value: 'rejected'),
        ];
      default:
        return const [
          AppFilterChip(label: 'All', value: _kAllFilterValue),
          AppFilterChip(label: 'Draft', value: 'draft'),
          AppFilterChip(label: 'Submitted', value: 'submitted'),
          AppFilterChip(label: 'Consultant Approved', value: 'consultant_approved'),
          AppFilterChip(label: 'Approved', value: 'pm_approved'),
          AppFilterChip(label: 'Rejected', value: 'rejected'),
        ];
    }
  }

  List<DailyLog> _filteredLogs(List<DailyLog> logs) {
    var result = logs;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((log) {
        final weather = log.weather?.toLowerCase() ?? '';
        return weather.contains(query) ||
            log.shifts.any((shift) => shift.shiftType.toLowerCase().contains(query)) ||
            log.labor.any((labor) => labor.workerType.toLowerCase().contains(query)) ||
            log.materials.any((material) => material.name.toLowerCase().contains(query)) ||
            log.equipment.any((equipment) => equipment.name.toLowerCase().contains(query));
      }).toList();
    }

    // Status filter
    final byStatus = _filterStatus == null
        ? result
        : result.where((l) => l.status == _filterStatus).toList();

    if (_dateFilter == null) {
      return byStatus;
    }
    return byStatus.where((log) {
      return log.date.year == _dateFilter!.year &&
          log.date.month == _dateFilter!.month &&
          log.date.day == _dateFilter!.day;
    }).toList();
  }

  Future<void> _pickOrClearDate() async {
    if (_dateFilter != null) {
      setState(() => _dateFilter = null);
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateFilter = picked);
  }
}

// ─── Filter + Summary ────────────────────────────────────────────────────────

class _FilterAndSummaryBar extends StatelessWidget {
  final List<AppFilterChip> filterChips;
  final String? filterStatus;
  final ValueChanged<String?> onFilterChanged;
  final List<DailyLog> logList;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _FilterAndSummaryBar({
    required this.filterChips,
    required this.filterStatus,
    required this.onFilterChanged,
    required this.logList,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final draftCount = logList.where((l) => l.status == 'draft').length;
    final submittedCount = logList.where((l) => l.status == 'submitted').length;
    final approvedCount =
        logList.where((l) => l.status == 'pm_approved').length;
    final rejectedCount = logList.where((l) => l.status == 'rejected').length;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderFor(brightness)),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              style: AppTextStyles.bodyMd.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search daily logs...',
                hintStyle: AppTextStyles.bodyMuted.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                        onPressed: () => onSearchChanged(''),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Filter chips
          ScrollConfiguration(
            behavior: _HideScrollbarBehavior(),
            child: AppFilterChips(
              chips: filterChips,
              selectedValue: filterStatus,
              onSelected: onFilterChanged,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Summary chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SummaryChip(
                  label: 'Draft',
                  value: draftCount,
                  color: AppColors.statusDraft,
                ),
                const SizedBox(width: AppSpacing.sm),
                _SummaryChip(
                  label: 'Submitted',
                  value: submittedCount,
                  color: AppColors.statusSubmitted,
                ),
                const SizedBox(width: AppSpacing.sm),
                _SummaryChip(
                  label: 'Approved',
                  value: approvedCount,
                  color: AppColors.statusApproved,
                ),
                const SizedBox(width: AppSpacing.sm),
                _SummaryChip(
                  label: 'Rejected',
                  value: rejectedCount,
                  color: AppColors.statusRejected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        '$value $label',
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HideScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

// ─── Filtered Empty ──────────────────────────────────────────────────────────

class _FilteredEmptyState extends StatelessWidget {
  final String filterStatus;

  const _FilteredEmptyState({required this.filterStatus});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_rounded,
              color: AppColors.secondaryTextFor(brightness),
              size: 40,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No logs found',
              style: AppTextStyles.sectionTitle.copyWith(
                color: brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try adjusting the selected status filter.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated Log Card ───────────────────────────────────────────────────────

class _AnimatedLogCard extends ConsumerStatefulWidget {
  final int index;
  final DailyLog log;
  final String? role;
  final String projectId;

  const _AnimatedLogCard({
    required this.index,
    required this.log,
    required this.role,
    required this.projectId,
  });

  @override
  ConsumerState<_AnimatedLogCard> createState() => _AnimatedLogCardState();
}

class _AnimatedLogCardState extends ConsumerState<_AnimatedLogCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    // Stagger by index
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSwipeApprove =
        (widget.role == 'project_manager' ||
            widget.role == 'owner') &&
        widget.log.status == 'submitted' &&
        widget.log.id != null;

    final card = FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: _LogCard(log: widget.log),
      ),
    );

    if (!canSwipeApprove) return card;

    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Dismissible(
          key: ValueKey('daily-log-${widget.log.id}'),
          direction: DismissDirection.startToEnd,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: AppRadius.large,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Approve this log?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await ref
                  .read(dailyLogControllerProvider.notifier)
                  .reviewLog(widget.log.id!, true);
              ref.invalidate(projectLogsProvider(widget.projectId));
            }

            return false;
          },
          child: _LogCard(log: widget.log),
        ),
      ),
    );
  }
}

// ─── Log Card ────────────────────────────────────────────────────────────────

class _LogCard extends StatelessWidget {
  final DailyLog log;

  const _LogCard({required this.log});

  String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'submitted':
        return 'Submitted';
      case 'consultant_approved':
        return 'Consultant Approved';
      case 'pm_approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'draft':
        return AppColors.statusDraft;
      case 'submitted':
        return AppColors.statusSubmitted;
      case 'consultant_approved':
        return AppColors.statusConsultantApproved;
      case 'pm_approved':
        return AppColors.statusApproved;
      case 'rejected':
        return AppColors.statusRejected;
      default:
        return AppColors.statusDraft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final isRejected = log.status == 'rejected';
    final statusColor = _statusColor(log.status);
    final statusLabel = _statusLabel(log.status);
    final hasWeather = log.weather != null && log.weather!.trim().isNotEmpty;
    final hasRejectionReason = isRejected &&
        log.rejectionReason != null &&
        log.rejectionReason!.trim().isNotEmpty;
    final syncLower = log.syncStatus.toLowerCase();
    final showSyncChip = syncLower == 'pending' ||
        syncLower == 'pending_create' ||
        syncLower == 'failed' ||
        syncLower == 'sync_failed';

    return Container(
      decoration: isRejected
          ? const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.error, width: 3),
              ),
            )
          : null,
      padding: isRejected ? const EdgeInsets.only(left: 3) : null,
      child: AppCard(
        onTap: () {
          if (log.id != null) {
            context.push('${RouteNames.dailyLogs}/${log.id}');
          }
        },
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Date + Status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppColors.secondaryTextFor(brightness),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        formatLogDate(log.date),
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.24)),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.badge.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            // Row 2: Meta pills (weather, sync)
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (hasWeather)
                  _MetaPill(
                    icon: Icons.wb_sunny_outlined,
                    label: log.weather!.trim(),
                    labelPrefix: 'Condition: ',
                  )
                else
                  const _MetaPill(
                    icon: Icons.wb_sunny_outlined,
                    label: 'No site condition',
                  ),
                if (showSyncChip) ...[
                  _SyncChip(syncStatus: log.syncStatus),
                ],
              ],
            ),
            // Row 3: Notes preview
            const SizedBox(height: AppSpacing.sm),
            Text(
              log.notes.trim().isEmpty
                  ? 'No notes added'
                  : log.notes.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.secondaryTextFor(brightness),
                fontSize: 13,
              ),
            ),
            // Row 4: Rejection reason
            if (hasRejectionReason) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: AppRadius.small,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        log.rejectionReason!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Meta Pill ───────────────────────────────────────────────────────────────

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? labelPrefix;

  const _MetaPill({
    required this.icon,
    required this.label,
    this.labelPrefix,
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
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondaryTextFor(brightness)),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              labelPrefix != null ? '$labelPrefix$label' : label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryTextFor(brightness),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sync Chip ───────────────────────────────────────────────────────────────

class _SyncChip extends StatelessWidget {
  final String syncStatus;

  const _SyncChip({required this.syncStatus});

  @override
  Widget build(BuildContext context) {
    final status = syncStatus.toLowerCase();
    final isFailed = status == 'failed' || status == 'sync_failed';
    final color = isFailed ? AppColors.error : AppColors.warning;
    final label = isFailed ? 'Sync Failed' : 'Pending Sync';
    final icon = isFailed
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
            label,
            style: AppTextStyles.badge.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Compact Loading ─────────────────────────────────────────────────────────

class _CompactLoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => const AppCard(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LoadingSkeleton(
                  width: 120,
                  height: 18,
                  borderRadius: AppRadius.sm,
                ),
                Spacer(),
                LoadingSkeleton(
                  width: 80,
                  height: 24,
                  borderRadius: AppRadius.chip,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            LoadingSkeleton(
              width: double.infinity,
              height: 14,
              borderRadius: AppRadius.sm,
            ),
            SizedBox(height: AppSpacing.sm),
            LoadingSkeleton(
              width: double.infinity,
              height: 28,
              borderRadius: AppRadius.sm,
            ),
          ],
        ),
      ),
    );
  }
}
