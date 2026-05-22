import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/entities/task.dart';
import '../controllers/task_controller.dart';
import '../../../team/domain/entities/project_member.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/animated_page_section.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../project/presentation/providers/project_provider.dart';
import '../../../team/presentation/controllers/team_controller.dart';

class TaskListPage extends ConsumerStatefulWidget {
  final String projectId;

  const TaskListPage({super.key, required this.projectId});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  String _filter = 'all';
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
                  Text('No project selected. Please select a project first.'),
              backgroundColor: AppColors.error,
            ),
          );
          context.pop();
        }
      });
    }
  }

  /// Normalize a DateTime to date-only (strip time component).
  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  bool _isDueToday(Task task) {
    if (task.endDate == null) return false;
    return _dateOnly(task.endDate!) == _dateOnly(DateTime.now());
  }

  bool _isDelayed(Task task) {
    if (task.status == 'completed') return false;
    if (task.endDate == null) return false;
    return _dateOnly(task.endDate!).isBefore(_dateOnly(DateTime.now()));
  }

  List<Task> _applyFilters(
    List<Task> tasks,
    String? currentUserId,
    Map<String, ProjectMember> memberLookup,
  ) {
    var visible = tasks;

    switch (_filter) {
      case 'my_tasks':
        visible = currentUserId == null || currentUserId.isEmpty
            ? <Task>[]
            : visible.where((t) => t.assignedTo == currentUserId).toList();
        break;
      case 'due_today':
        visible = visible.where((t) => _isDueToday(t)).toList();
        break;
      case 'delayed':
        visible = visible.where((t) => _isDelayed(t)).toList();
        break;
      case 'pending':
        visible = visible.where((t) => t.status == 'pending').toList();
        break;
      case 'in_progress':
        visible = visible.where((t) => t.status == 'in_progress').toList();
        break;
      case 'completed':
        visible = visible.where((t) => t.status == 'completed').toList();
        break;
      case 'all':
      default:
        break;
    }

    // Search filter: match task name, description, assignee full name, assignee email
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      visible = visible.where((t) {
        if (t.name.toLowerCase().contains(q)) return true;
        if (t.description != null && t.description!.toLowerCase().contains(q)) {
          return true;
        }
        if (t.assignedTo != null && memberLookup.containsKey(t.assignedTo)) {
          final member = memberLookup[t.assignedTo]!;
          if (member.fullName.toLowerCase().contains(q)) return true;
          if (member.email.toLowerCase().contains(q)) return true;
        }
        return false;
      }).toList();
    }

    return visible;
  }

  String? _assignedName(
      Map<String, ProjectMember> memberLookup, String? userId) {
    if (userId == null || userId.isEmpty) return null;
    return memberLookup[userId]?.fullName;
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));
    final currentUserId = ref.watch(authProvider).user?['id']?.toString();
    final role = ref.watch(currentProjectRoleProvider);
    final canCreate = role == 'project_manager' || role == 'owner';
    final l10n = AppLocalizations.of(context)!;

    // Build member lookup map for assignee name resolution
    final teamState = ref.watch(teamControllerProvider(widget.projectId));
    final memberLookup = <String, ProjectMember>{};
    for (final m in teamState.members) {
      memberLookup[m.userId] = m;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tasks),
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final visibleTasks =
              _applyFilters(tasks, currentUserId, memberLookup);

          return RefreshIndicator(
            onRefresh: () =>
                ref.refresh(projectTasksProvider(widget.projectId).future),
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                ResponsiveContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedPageSection(
                        child: _TaskSearchBar(
                          query: _searchQuery,
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AnimatedPageSection(
                        delay: const Duration(milliseconds: 60),
                        child: _TaskFilterChips(
                          selected: _filter,
                          onSelected: (v) => setState(() => _filter = v),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (tasks.isEmpty)
                        EmptyState(
                          title: 'No tasks yet',
                          message: 'Create your first task to start tracking work.',
                          icon: Icons.assignment_rounded,
                          action: canCreate
                              ? AppButton(
                                  text: '+ Create Task',
                                  size: AppButtonSize.medium,
                                  onPressed: () => context.push(
                                    '${RouteNames.tasks}/create?projectId=${widget.projectId}',
                                  ),
                                )
                              : null,
                        )
                      else if (visibleTasks.isEmpty)
                        const EmptyState(
                          title: 'No tasks found',
                          message: 'Try adjusting your search or filters.',
                          icon: Icons.filter_list_off_rounded,
                        )
                      else
                        CardStagger(
                          children: [
                            for (final task in visibleTasks)
                              _CompactTaskCard(
                                task: task,
                                assignedName: _assignedName(
                                    memberLookup, task.assignedTo),
                                isDelayed: _isDelayed(task),
                                isDueToday: _isDueToday(task),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => ResponsiveContent(child: _TaskLoading()),
        error: (err, stack) {
          final errorMessage = err.toString();
          final isParsingError =
              errorMessage.contains('type') && errorMessage.contains('Null');
          final isNetworkError =
              errorMessage.toLowerCase().contains('network') ||
                  errorMessage.toLowerCase().contains('connection') ||
                  errorMessage.toLowerCase().contains('socket');

          return ErrorState(
            title: isParsingError ? 'Data Error' : l10n.error,
            message: isParsingError
                ? 'Unable to load task data. Please try again.'
                : isNetworkError
                    ? 'Network error. Please check your connection.'
                    : errorMessage.length > 100
                        ? 'Failed to load tasks. Please try again.'
                        : errorMessage,
            action: TextButton.icon(
              onPressed: () =>
                  ref.invalidate(projectTasksProvider(widget.projectId)),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          );
        },
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => context.push(
                '${RouteNames.tasks}/create?projectId=${widget.projectId}',
              ),
              backgroundColor: AppColors.brandBlue,
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }
}

// ─── Filter Chips ───────────────────────────────────────────────────────────

class _TaskFilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _TaskFilterChips({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final filters = [
      ('all', 'All', Icons.list_rounded),
      ('my_tasks', 'My Tasks', Icons.person_rounded),
      ('due_today', 'Due Today', Icons.today_rounded),
      ('delayed', 'Delayed', Icons.warning_amber_rounded),
      ('pending', 'Pending', Icons.schedule_rounded),
      ('in_progress', 'In Progress', Icons.autorenew_rounded),
      ('completed', 'Completed', Icons.check_circle_outline_rounded),
    ];

    return SizedBox(
      height: 40,
      child: ScrollConfiguration(
        behavior: _NoScrollbarBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = selected == filter.$1;

            final bgColor = isSelected
                ? AppColors.brandBlue
                : isDark
                    ? AppColors.darkElevatedCard
                    : AppColors.lightSurface;
            final borderColor = isSelected
                ? AppColors.brandBlue
                : AppColors.borderFor(brightness);
            final textColor = isSelected
                ? Colors.white
                : AppColors.secondaryTextFor(brightness);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: InkWell(
                onTap: () => onSelected(filter.$1),
                borderRadius: BorderRadius.circular(AppRadius.chip),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(filter.$3, size: 16, color: textColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        filter.$2,
                        style: AppTextStyles.label.copyWith(
                          color: textColor,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ScrollBehavior that hides scrollbars and overscroll glow.
class _NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}

// ─── Compact Task Card ──────────────────────────────────────────────────────

class _CompactTaskCard extends StatelessWidget {
  final Task task;
  final String? assignedName;
  final bool isDelayed;
  final bool isDueToday;

  const _CompactTaskCard({
    required this.task,
    required this.assignedName,
    required this.isDelayed,
    required this.isDueToday,
  });

  String _statusLabel(AppLocalizations l10n) {
    return switch (task.status) {
      'pending' => l10n.pending,
      'in_progress' => l10n.inProgress,
      'completed' => l10n.completed,
      _ => task.status.replaceAll('_', ' '),
    };
  }

  Color _leftBorderColor() {
    if (task.status == 'completed') return AppColors.success;
    if (isDelayed) return AppColors.error;
    if (isDueToday) return AppColors.warning;
    return AppColors.constructProBlue;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final displayAssignee = assignedName ?? 'Unassigned';
    final assigneeInitial =
        assignedName != null && assignedName!.trim().isNotEmpty
            ? assignedName!.trim()[0].toUpperCase()
            : '?';
    final borderColor = _leftBorderColor();

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: AppCard(
        onTap: () => context.push('${RouteNames.tasks}/${task.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: avatar + name + chevron
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Assignee avatar
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    assigneeInitial,
                    style: const TextStyle(
                      color: AppColors.brandBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task name
                      Text(
                        task.name.isNotEmpty ? task.name : 'Untitled task',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Assignee name
                      Text(
                        displayAssignee,
                        style: AppTextStyles.caption.copyWith(
                          color: assignedName == null
                              ? AppColors.secondaryTextFor(brightness)
                              : isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.mutedTextFor(brightness),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Status badge + due indicator
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusBadge(
                  status: task.status,
                  label: _statusLabel(l10n),
                ),
                if (isDelayed)
                  const _DueChip(
                    text: 'Overdue',
                    color: AppColors.error,
                  )
                else if (isDueToday)
                  const _DueChip(
                    text: 'Due today',
                    color: AppColors.warning,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Progress bar
            _ProgressLine(task: task),
            const SizedBox(height: AppSpacing.sm),
            // Date row
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                if (task.startDate != null)
                  _MetaItem(
                    icon: Icons.play_arrow_rounded,
                    text: DateFormat('MMM d, yyyy')
                        .format(task.startDate!),
                  ),
                if (task.endDate != null)
                  _MetaItem(
                    icon: Icons.flag_rounded,
                    text: DateFormat('MMM d, yyyy')
                        .format(task.endDate!),
                  ),
                if (task.endDate == null)
                  const _MetaItem(
                    icon: Icons.flag_rounded,
                    text: 'No due date',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Due Chip ────────────────────────────────────────────────────────────────

class _DueChip extends StatelessWidget {
  final String text;
  final Color color;

  const _DueChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high_rounded, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            text.toUpperCase(),
            style: AppTextStyles.badge.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Line ──────────────────────────────────────────────────────────

class _ProgressLine extends StatelessWidget {
  final Task task;

  const _ProgressLine({required this.task});

  @override
  Widget build(BuildContext context) {
    final progress = task.progressPercentage.clamp(0.0, 100.0).toDouble();
    final value = progress / 100;
    final color = _progressColor();

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor:
                  Colors.grey.withValues(alpha: 0.15),
              color: color,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${progress.round()}%',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryTextFor(Theme.of(context).brightness),
          ),
        ),
      ],
    );
  }

  Color _progressColor() {
    final progress = task.progressPercentage;
    if (progress >= 80) return AppColors.success;
    if (progress >= 40) return AppColors.warning;
    if (progress < 40 &&
        task.endDate != null &&
        task.endDate!.isBefore(DateTime.now()) &&
        task.status != 'completed') {
      return AppColors.error;
    }
    return AppColors.constructProBlue;
  }
}

// ─── Meta Item ──────────────────────────────────────────────────────────────

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.mutedTextFor(brightness)),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryTextFor(brightness),
          ),
        ),
      ],
    );
  }
}

// ─── Search Bar ─────────────────────────────────────────────────────────────

class _TaskSearchBar extends StatefulWidget {
  final String query;
  final ValueChanged<String> onChanged;

  const _TaskSearchBar({required this.query, required this.onChanged});

  @override
  State<_TaskSearchBar> createState() => _TaskSearchBarState();
}

class _TaskSearchBarState extends State<_TaskSearchBar> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final hasFocus = _focusNode.hasFocus;

    final borderCol = hasFocus
        ? AppColors.accentBlue.withValues(alpha: 0.6)
        : AppColors.borderFor(brightness);
    final shadowCol = hasFocus
        ? AppColors.focusGlowFor(brightness)
        : Colors.black.withValues(alpha: isDark ? 0 : 0.03);

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevatedCard : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: hasFocus ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: shadowCol,
            blurRadius: hasFocus ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: AppTextStyles.bodyMd.copyWith(
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: AppTextStyles.bodyMd.copyWith(
            color: AppColors.secondaryTextFor(brightness),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: hasFocus
                ? AppColors.accentBlue
                : AppColors.mutedTextFor(brightness),
            size: 22,
          ),
          suffixIcon: widget.query.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppColors.mutedTextFor(brightness),
                    size: 20,
                  ),
                  onPressed: () => widget.onChanged(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

// ─── Loading State ──────────────────────────────────────────────────────────

class _TaskLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LoadingSkeleton(
            width: double.infinity, height: 54, borderRadius: 20),
        const SizedBox(height: AppSpacing.md),
        const LoadingSkeleton(
            width: double.infinity, height: 40, borderRadius: 20),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < 4; i++) ...[
          const LoadingSkeleton(
              width: double.infinity, height: 180, borderRadius: 18),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
