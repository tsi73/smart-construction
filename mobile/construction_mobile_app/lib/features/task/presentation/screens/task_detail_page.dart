import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/task.dart';
import '../controllers/task_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../project/presentation/providers/project_provider.dart';

class TaskDetailPage extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final role = ref.watch(currentProjectRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  ref.invalidate(taskDetailProvider(widget.taskId));
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 18),
                    SizedBox(width: AppSpacing.sm),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: taskAsync.when(
        data: (task) => _TaskDetailContent(task: task, role: role),
        loading: () =>
            ResponsiveContent(child: _TaskDetailLoading()),
        error: (err, stack) => ErrorState(
          title: 'Error',
          message: err.toString(),
          action: TextButton.icon(
            onPressed: () =>
                ref.invalidate(taskDetailProvider(widget.taskId)),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ),
      ),
    );
  }
}

// ─── Main Content ────────────────────────────────────────────────────────────

class _TaskDetailContent extends ConsumerStatefulWidget {
  final Task task;
  final String? role;

  const _TaskDetailContent({required this.task, this.role});

  @override
  ConsumerState<_TaskDetailContent> createState() =>
      _TaskDetailContentState();
}

class _TaskDetailContentState extends ConsumerState<_TaskDetailContent> {
  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final role = widget.role;

    return RefreshIndicator(
      onRefresh: () =>
          ref.refresh(taskDetailProvider(widget.task.id).future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl + 80,
        ),
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _TaskHeader(task: task),
              const SizedBox(height: AppSpacing.lg),

              // Summary card
              _SummaryCard(task: task),
              const SizedBox(height: AppSpacing.lg),

              // Schedule Analysis card
              _ScheduleAnalysisCard(
                task: task,
                getScheduleAnalysis: _getScheduleAnalysis,
                getScheduleAnalysisColor: _getScheduleAnalysisColor,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Progress section
              _ProgressSection(task: task),
              const SizedBox(height: AppSpacing.lg),

              // Dependencies section
              _DependenciesSection(taskId: task.id),
              const SizedBox(height: AppSpacing.lg),

              // Field Notes (comments) section
              _TaskCommentsSection(taskId: task.id),
              const SizedBox(height: AppSpacing.xl),

              // Create Daily Log button (for site engineers)
              if (_canCreateDailyLog(role))
                AppButton(
                  text: 'Create Daily Log',
                  icon: Icons.note_add_rounded,
                  isOutline: true,
                  onPressed: () => _createDailyLog(context, task),
                ),

              const SizedBox(height: AppSpacing.md),

              // Mark Complete button (if eligible)
              if (task.status != 'completed' &&
                  _canMarkComplete(role))
                AppButton(
                  text: 'Mark as Complete',
                  icon: Icons.check_circle_rounded,
                  onPressed: () => _showMarkCompleteDialog(context, task),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Schedule Analysis ──────────────────────────────────────────────────────

  String _getScheduleAnalysis(Task task) {
    if (task.startDate == null || task.endDate == null) {
      return 'No schedule set';
    }
    final totalDays = task.endDate!.difference(task.startDate!).inDays;
    if (totalDays <= 0) return 'Invalid schedule';
    final elapsedDays =
        DateTime.now().difference(task.startDate!).inDays.clamp(0, totalDays);
    final timeElapsedPercent = (elapsedDays / totalDays * 100).round();
    final progressPercent = task.progressPercentage.round();
    final variance = progressPercent - timeElapsedPercent;
    if (task.status == 'completed') return 'Completed';
    if (variance >= 10) return 'Ahead of schedule (+$variance%)';
    if (variance >= -10) {
      return 'On track ($timeElapsedPercent% time elapsed, $progressPercent% done)';
    }
    return 'Behind schedule ($variance% — $timeElapsedPercent% time elapsed but only $progressPercent% done)';
  }

  Color _getScheduleAnalysisColor(String analysis) {
    if (analysis.contains('Ahead') || analysis.contains('On track') || analysis == 'Completed') {
      return AppColors.success;
    }
    if (analysis.contains('Behind')) return AppColors.error;
    return AppColors.statusDraft;
  }

  // ── Mark Complete ─────────────────────────────────────────────────────────

  bool _canMarkComplete(String? role) {
    if (role == null) return false;
    final r = role.toLowerCase();
    return r == 'project_manager' || r == 'owner' || r == 'site_engineer';
  }

  bool _canCreateDailyLog(String? role) {
    if (role == null) return false;
    final r = role.toLowerCase();
    return r == 'site_engineer';
  }

  void _createDailyLog(BuildContext context, Task task) {
    // Get the current project from the provider
    final currentProject = ref.read(currentProjectProvider);
    if (currentProject == null || currentProject['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project not found. Please select a project first.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.push('${RouteNames.dailyLogs}/new?taskId=${task.id}');
  }

  void _showMarkCompleteDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark this task as complete?'),
        content: const Text(
          'This will set progress to 100% and status to completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await ref
                  .read(taskControllerProvider.notifier)
                  .updateTaskProgress(widget.task.id, 100.0);
              await ref
                  .read(taskControllerProvider.notifier)
                  .updateTaskStatus(widget.task.id, 'completed');
              ref.invalidate(taskDetailProvider(widget.task.id));
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Task marked as complete'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

// ─── Task Header ─────────────────────────────────────────────────────────────

class _TaskHeader extends StatelessWidget {
  final Task task;
  const _TaskHeader({required this.task});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                task.name,
                style: AppTextStyles.screenTitle.copyWith(
                  color: brightness == Brightness.dark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            StatusBadge(
              status: task.status,
              label: _statusLabel(task.status),
            ),
          ],
        ),
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(task.description!, style: AppTextStyles.bodyMuted),
        ],
      ],
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}

// ─── Summary Card ────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final Task task;
  const _SummaryCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dateFormat = DateFormat('dd MMM yyyy');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details', style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primaryTextFor(brightness)),),
          const SizedBox(height: AppSpacing.md),
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Start Date',
            value: task.startDate != null
                ? dateFormat.format(task.startDate!)
                : 'Not set',
            brightness: brightness,
          ),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            icon: Icons.event_rounded,
            label: 'End Date',
            value: task.endDate != null
                ? dateFormat.format(task.endDate!)
                : 'Not set',
            brightness: brightness,
          ),
          if (task.plannedDurationDays != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.timelapse_rounded,
              label: 'Planned Duration',
              value: '${task.plannedDurationDays} days',
              brightness: brightness,
            ),
          ],
          if (task.assignedTo != null && task.assignedTo!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.person_rounded,
              label: 'Assigned To',
              value: task.assignedTo!,
              brightness: brightness,
            ),
          ],
          if (task.plannedCost != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.attach_money_rounded,
              label: 'Planned Cost',
              value: 'ETB ${task.plannedCost!.toStringAsFixed(2)}',
              brightness: brightness,
            ),
          ],
          if (task.actualCost != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.payments_rounded,
              label: 'Actual Cost',
              value: 'ETB ${task.actualCost!.toStringAsFixed(2)}',
              brightness: brightness,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Brightness brightness;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryTextFor(brightness)),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTextStyles.bodyMuted),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Schedule Analysis Card ──────────────────────────────────────────────────

class _ScheduleAnalysisCard extends StatelessWidget {
  final Task task;
  final String Function(Task) getScheduleAnalysis;
  final Color Function(String) getScheduleAnalysisColor;

  const _ScheduleAnalysisCard({
    required this.task,
    required this.getScheduleAnalysis,
    required this.getScheduleAnalysisColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final analysis = getScheduleAnalysis(task);
    final color = getScheduleAnalysisColor(analysis);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Schedule Analysis', style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primaryTextFor(brightness)),),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              analysis,
              style: AppTextStyles.bodyMd.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Section ────────────────────────────────────────────────────────

class _ProgressSection extends ConsumerStatefulWidget {
  final Task task;
  const _ProgressSection({required this.task});

  @override
  ConsumerState<_ProgressSection> createState() =>
      _ProgressSectionState();
}

class _ProgressSectionState extends ConsumerState<_ProgressSection> {
  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final brightness = Theme.of(context).brightness;
    final progress = task.progressPercentage.clamp(0.0, 100.0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress', style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primaryTextFor(brightness)),),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                    backgroundColor: brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progressColor(progress),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${progress.round()}%',
                style: AppTextStyles.label.copyWith(
                  color: _progressColor(progress),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showProgressUpdateSheet(context),
              child: const Text('Update Progress'),
            ),
          ),
        ],
      ),
    );
  }

  Color _progressColor(double progress) {
    if (progress >= 100) return AppColors.success;
    if (progress >= 50) return AppColors.accentBlue;
    if (progress > 0) return AppColors.warning;
    return AppColors.statusDraft;
  }

  void _showProgressUpdateSheet(BuildContext context) {
    double sliderValue = widget.task.progressPercentage.clamp(0.0, 100.0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Update Progress',
                      style: AppTextStyles.sectionTitle),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          min: 0,
                          max: 100,
                          divisions: 20,
                          value: sliderValue,
                          onChanged: (v) =>
                              setSheetState(() => sliderValue = v),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${sliderValue.round()}%',
                        style: AppTextStyles.label,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: 'Save Progress',
                    onPressed: () {
                      ref
                          .read(taskControllerProvider.notifier)
                          .updateTaskProgress(
                              widget.task.id, sliderValue);
                      ref.invalidate(
                          taskDetailProvider(widget.task.id));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Progress updated'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Dependencies Section ────────────────────────────────────────────────────

class _DependenciesSection extends ConsumerWidget {
  final String taskId;
  const _DependenciesSection({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depsAsync = ref.watch(taskDependenciesProvider(taskId));
    final brightness = Theme.of(context).brightness;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dependencies', style: AppTextStyles.sectionTitle.copyWith(color: AppColors.primaryTextFor(brightness)),),
          const SizedBox(height: AppSpacing.md),
          depsAsync.when(
            data: (deps) {
              if (deps.isEmpty) {
                return Text(
                  'No dependencies',
                  style: AppTextStyles.bodyMuted,
                );
              }
              return Column(
                children: deps
                    .map((dep) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.link_rounded,
                            size: 20,
                            color: AppColors.secondaryTextFor(brightness),
                          ),
                          title: Text(
                            dep.dependsOnTaskName ??
                                dep.dependsOnTaskId,
                            style: AppTextStyles.bodyMd,
                          ),
                        ))
                    .toList(),
              );
            },
            loading: () => const SizedBox(
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => Text(
              'Could not load dependencies',
              style: AppTextStyles.bodyMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Task Comments Section (Field Notes) ─────────────────────────────────────

class _TaskCommentsSection extends StatefulWidget {
  final String taskId;
  const _TaskCommentsSection({required this.taskId});

  @override
  State<_TaskCommentsSection> createState() =>
      _TaskCommentsSectionState();
}

class _TaskCommentsSectionState extends State<_TaskCommentsSection> {
  List<Map<String, dynamic>> _comments = [];
  bool _showAll = false;
  bool _isLoading = true;
  final _commentController = TextEditingController();

  static const int _visibleCount = 5;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('task_comments_${widget.taskId}');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        setState(() {
          _comments = list
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        });
      } catch (_) {
        // Corrupted data — start fresh
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveComments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'task_comments_${widget.taskId}',
      jsonEncode(_comments),
    );
  }

  void _addComment(String author) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add({
        'text': text,
        'author': author,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _commentController.clear();
      // Auto-expand when adding a comment so the user sees it
      _showAll = true;
    });
    _saveComments();
  }

  @override
  Widget build(BuildContext context) {
    final visibleComments = _showAll
        ? _comments
        : _comments.take(_visibleCount).toList();
    final hasMore = _comments.length > _visibleCount;

    // We need the author name from auth. Since this is a StatefulWidget
    // without Riverpod, we read it via a Consumer wrapper at the call site
    // or use a simple workaround. Here we'll use a Builder with Consumer.
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Field Notes',
            subtitle: 'Visible only on this device',
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isLoading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_comments.isEmpty)
            Text(
              'No notes yet. Add one below.',
              style: AppTextStyles.bodyMuted,
            )
          else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleComments.length,
              itemBuilder: (context, index) {
                final comment = visibleComments[index];
                final author =
                    comment['author'] as String? ?? 'Me';
                final timestamp =
                    comment['timestamp'] as String? ?? '';
                String formattedTime = '';
                if (timestamp.isNotEmpty) {
                  try {
                    final dt = DateTime.parse(timestamp);
                    formattedTime =
                        DateFormat('dd MMM, HH:mm').format(dt);
                  } catch (_) {
                    formattedTime = timestamp;
                  }
                }
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xs,
                  ),
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        AppColors.accentBlue.withValues(alpha: 0.12),
                    child: Text(
                      author.isNotEmpty
                          ? author[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                  title: Text(comment['text'] as String? ?? '',
                      style: AppTextStyles.bodyMd),
                  subtitle: Text(
                    '$author · $formattedTime',
                    style: AppTextStyles.caption,
                  ),
                );
              },
            ),
            if (hasMore && !_showAll)
              TextButton(
                onPressed: () => setState(() => _showAll = true),
                child: Text(
                  'Show more (${_comments.length - _visibleCount} more)',
                ),
              ),
            if (_showAll && _comments.length > _visibleCount)
              TextButton(
                onPressed: () => setState(() => _showAll = false),
                child: const Text('Show less'),
              ),
          ],
          const SizedBox(height: AppSpacing.sm),
          // Input row — needs ref for author name
          _CommentInputRow(
            controller: _commentController,
            onSend: (author) => _addComment(author),
          ),
        ],
      ),
    );
  }
}

/// Small ConsumerWidget so we can read the auth provider for the author name.
class _CommentInputRow extends ConsumerWidget {
  final TextEditingController controller;
  final void Function(String author) onSend;

  const _CommentInputRow({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final author =
        ref.watch(authProvider).user?['full_name'] as String? ?? 'Me';

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Add a note...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(author),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: () => onSend(author),
          icon: const Icon(Icons.send_rounded),
          color: AppColors.accentBlue,
        ),
      ],
    );
  }
}

// ─── Loading Skeleton ────────────────────────────────────────────────────────

class _TaskDetailLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          LoadingSkeleton(width: double.infinity, height: 28),
          SizedBox(height: AppSpacing.lg),
          LoadingSkeleton(width: double.infinity, height: 180),
          SizedBox(height: AppSpacing.lg),
          LoadingSkeleton(width: double.infinity, height: 120),
          SizedBox(height: AppSpacing.lg),
          LoadingSkeleton(width: double.infinity, height: 100),
        ],
      ),
    );
  }
}
