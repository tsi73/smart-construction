import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/project_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/animated_page_section.dart';
import '../../../../core/widgets/blueprint_background.dart';
import '../../../../core/widgets/state_widgets.dart';

class ProjectListPage extends ConsumerStatefulWidget {
  const ProjectListPage({super.key});

  @override
  ConsumerState<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends ConsumerState<ProjectListPage> {
  String _searchQuery = '';
  String? _statusFilter; // null = All

  static const _statusFilters = [
    _StatusFilter(value: null, label: 'All'),
    _StatusFilter(value: 'in_progress', label: 'Active'),
    _StatusFilter(value: 'planning', label: 'Planning'),
    _StatusFilter(value: 'on_hold', label: 'On Hold'),
    _StatusFilter(value: 'completed', label: 'Completed'),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.invalidate(projectsProvider);
      ref.read(currentProjectProvider.notifier).state = null;
      ref.read(currentProjectRoleProvider.notifier).state = null;
      ref.read(isCurrentProjectOwnerProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: BlueprintBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 760 : double.infinity),
              child: CustomScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  // Header
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? AppSpacing.xxl : AppSpacing.lg,
                      AppSpacing.lg,
                      isWide ? AppSpacing.xxl : AppSpacing.lg,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AnimatedPageSection(
                        child: _GreetingHeader(
                          userName: user?['full_name']?.toString(),
                        ),
                      ),
                    ),
                  ),
                  // Search
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? AppSpacing.xxl : AppSpacing.lg,
                      AppSpacing.md,
                      isWide ? AppSpacing.xxl : AppSpacing.lg,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AnimatedPageSection(
                        delay: const Duration(milliseconds: 60),
                        child: _SearchField(
                          query: _searchQuery,
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                    ),
                  ),
                  // Filter chips
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? AppSpacing.xxl : AppSpacing.lg,
                      AppSpacing.md,
                      isWide ? AppSpacing.xxl : AppSpacing.lg,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AnimatedPageSection(
                        delay: const Duration(milliseconds: 120),
                        child: _StatusFilterRow(
                          filters: _statusFilters,
                          selectedValue: _statusFilter,
                          onSelected: (v) => setState(() => _statusFilter = v),
                        ),
                      ),
                    ),
                  ),
                  // Projects content
                  projectsAsync.when(
                    data: (projects) {
                      final filtered = _applyFilters(projects, user);
                      final isTotalEmpty = projects.isEmpty;
                      final hasNoUser = user == null || user['id'] == null;

                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          isWide ? AppSpacing.xxl : AppSpacing.lg,
                          AppSpacing.lg,
                          isWide ? AppSpacing.xxl : AppSpacing.lg,
                          AppSpacing.xxl,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section header
                              _ProjectsSectionHeader(
                                count: filtered.length,
                                onCreate: () => context.push('${RouteNames.projects}/new'),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              if (hasNoUser)
                                _EmptyState(
                                  isTotalEmpty: false,
                                  onCreate: () => context.push('${RouteNames.projects}/new'),
                                )
                              else if (filtered.isEmpty)
                                _EmptyState(
                                  isTotalEmpty: isTotalEmpty,
                                  onCreate: () => context.push('${RouteNames.projects}/new'),
                                )
                              else
                                CardStagger(
                                  baseDelay: const Duration(milliseconds: 50),
                                  duration: const Duration(milliseconds: 400),
                                  children: [
                                    for (final project in filtered) ...[
                                      _ProjectCard(project: project),
                                      const SizedBox(height: AppSpacing.md),
                                    ],
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        isWide ? AppSpacing.xxl : AppSpacing.lg,
                        AppSpacing.lg,
                        isWide ? AppSpacing.xxl : AppSpacing.lg,
                        AppSpacing.xxl,
                      ),
                      sliver: SliverToBoxAdapter(child: _LoadingState()),
                    ),
                    error: (err, stack) => SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        isWide ? AppSpacing.xxl : AppSpacing.lg,
                        AppSpacing.lg,
                        isWide ? AppSpacing.xxl : AppSpacing.lg,
                        AppSpacing.xxl,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _ErrorState(
                          message: err.toString(),
                          onRetry: () => ref.invalidate(projectsProvider),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> projects,
    Map<String, dynamic>? user,
  ) {
    var result = projects;

    // Strict client-side filtering: only show projects where user is owner or has a role
    if (user != null && user['id'] != null) {
      final currentUserId = user['id'].toString();
      result = result.where((p) {
        final ownerId = p['owner_id']?.toString();
        final role = p['role']?.toString();

        // User must be either the owner OR have a role (meaning they're a member)
        final isOwner = ownerId == currentUserId;
        final isMember = role != null && role.isNotEmpty;

        if (kDebugMode) {
          debugPrint('Project: ${p['name']}, owner_id: $ownerId, role: $role, isOwner: $isOwner, isMember: $isMember');
        }

        return isOwner || isMember;
      }).toList();
    } else {
      // If no user or user ID, show empty list
      result = [];
    }

    // Status filter
    if (_statusFilter != null) {
      result = result.where((p) => p['status']?.toString() == _statusFilter).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        final name = p['name']?.toString().toLowerCase() ?? '';
        final location = p['location']?.toString().toLowerCase() ?? '';
        final client = p['client'] is Map
            ? p['client']['name']?.toString().toLowerCase() ?? ''
            : '';
        return name.contains(q) || location.contains(q) || client.contains(q);
      }).toList();
    }

    return result;
  }
}

// ── Data helpers ──────────────────────────────────────────────────────

class _StatusFilter {
  final String? value;
  final String label;
  const _StatusFilter({this.value, required this.label});
}

String? _textValue(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

double _progressValue(Map<String, dynamic> project) {
  final value = project['progress_percentage'] ?? project['progress'];
  if (value is num) return value.toDouble().clamp(0, 100).toDouble();
  if (value is String) return (double.tryParse(value) ?? 0).clamp(0, 100).toDouble();
  return 0;
}

String _statusLabel(String status) {
  return switch (status) {
    'planning' => 'Planning',
    'in_progress' => 'Active',
    'completed' => 'Completed',
    'on_hold' => 'On Hold',
    _ => 'Unknown',
  };
}

Color _statusColor(String status) {
  return switch (status) {
    'planning' => const Color(0xFF6366F1), // indigo
    'in_progress' => const Color(0xFF10B981), // green/teal
    'completed' => AppColors.success,
    'on_hold' => const Color(0xFFF59E0B), // amber
    _ => AppColors.statusDraft,
  };
}

String _dateRange(Map<String, dynamic> project) {
  final startRaw = _textValue(project['planned_start_date']);
  final endRaw = _textValue(project['planned_end_date']);
  final start = startRaw != null ? DateTime.tryParse(startRaw) : null;
  final end = endRaw != null ? DateTime.tryParse(endRaw) : null;

  if (start != null && end != null) {
    return '${DateFormat('MMM yyyy').format(start)} - ${DateFormat('MMM yyyy').format(end)}';
  }
  if (start != null) return 'Starts ${DateFormat('MMM yyyy').format(start)}';
  if (end != null) return 'Due ${DateFormat('MMM yyyy').format(end)}';
  return 'Schedule not set';
}

// ── Greeting Header ──────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String? userName;
  const _GreetingHeader({this.userName});

  String _firstName() {
    if (userName == null || userName!.trim().isEmpty) return 'there';
    return userName!.split(' ').firstOrNull ?? 'there';
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brandBlueDark, AppColors.brandBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
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
                  '${_greeting()}, ${_firstName()}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onPressed: () => context.push(RouteNames.settings),
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

// ── Search Field ──────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final String query;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.query, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return TextField(
      onChanged: onChanged,
      style: AppTextStyles.bodyMd.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Search projects...',
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        hintStyle: AppTextStyles.bodyMuted.copyWith(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 22,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  size: 20,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
                onPressed: () => onChanged(''),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

// ── Status Filter Row ────────────────────────────────────────────────

class _StatusFilterRow extends StatelessWidget {
  final List<_StatusFilter> filters;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;
  const _StatusFilterRow({
    required this.filters,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final f = filters[index];
            final isSelected = f.value == selectedValue;
            return _FilterChip(
              label: f.label,
              isSelected: isSelected,
              onTap: () => onSelected(f.value),
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentBlue : AppColors.accentBlueStrong;

    final bgColor = isSelected
        ? accent
        : (isDark ? AppColors.darkElevatedCard : AppColors.lightSurface);
    final borderColor = isSelected
        ? accent
        : AppColors.borderFor(brightness);
    final textColor = isSelected
        ? Colors.white
        : AppColors.secondaryTextFor(brightness);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Projects Section Header ──────────────────────────────────────────

class _ProjectsSectionHeader extends StatelessWidget {
  final int count;
  final VoidCallback onCreate;
  const _ProjectsSectionHeader({required this.count, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projects',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$count ${count == 1 ? 'project' : 'projects'} available',
                style: AppTextStyles.bodyMuted.copyWith(
                  color: AppColors.secondaryTextFor(brightness),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _CreateButton(onPressed: onCreate),
      ],
    );
  }
}

class _CreateButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _CreateButton({required this.onPressed});

  @override
  State<_CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<_CreateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentBlue : AppColors.accentBlueStrong;

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
      ),
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) { _scaleController.reverse(); widget.onPressed(); },
        onTapCancel: () => _scaleController.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'Create',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Project Card ──────────────────────────────────────────────────────

class _ProjectCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> project;
  const _ProjectCard({required this.project});

  @override
  ConsumerState<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends ConsumerState<_ProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: _progressValue(widget.project),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    // Animate progress bar after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final p = widget.project;

    final name = _textValue(p['name']) ?? 'Untitled project';
    final status = _textValue(p['status']) ?? 'planning';
    final location = _textValue(p['location']) ?? 'Location not set';
    final dateText = _dateRange(p);
    final progress = _progressValue(p);
    final statusLabel = _statusLabel(status);
    final statusClr = _statusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderFor(brightness)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: isDark ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openProject(context, ref, p),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: name + status chip
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.cardTitle.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _StatusChip(label: statusLabel, color: statusClr),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Location
                    _MetaRow(icon: Icons.location_on_outlined, text: location),
                    const SizedBox(height: AppSpacing.sm),
                    // Date range
                    _MetaRow(icon: Icons.calendar_today_outlined, text: dateText),
                    const SizedBox(height: AppSpacing.lg),
                    // Progress bar + arrow
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, _) {
                              final val = (_progressAnimation.value / 100).clamp(0.0, 1.0);
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkSurface
                                            : AppColors.lightMutedSurface,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: val,
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '${progress.round()}% complete',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mutedTextFor(brightness),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.accentBlue,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _openProject(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> project,
  ) async {
    ref.read(currentProjectProvider.notifier).state = project;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final membersResult = await ref
          .read(projectRepositoryProvider)
          .getProjectMembers(project['id']);
      final currentUser = ref.read(authProvider).user;

      if (context.mounted) Navigator.pop(context);

      membersResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load project role: ${failure.message}')),
          );
        },
        (members) {
          final memberIndex = members.indexWhere(
            (m) => m['user_id'] == currentUser?['id'],
          );

          if (memberIndex == -1) {
            ref.read(currentProjectRoleProvider.notifier).state = null;
            ref.read(isCurrentProjectOwnerProvider.notifier).state = false;
          } else {
            final member = members[memberIndex];
            String role = member['role'] ?? '';
            ref.read(currentProjectRoleProvider.notifier).state =
                role.isEmpty ? null : role;
            ref.read(isCurrentProjectOwnerProvider.notifier).state =
                role == 'owner';
          }

          if (context.mounted) context.push(RouteNames.projectDashboard);
        },
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// ── Status Chip ───────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(color: color),
      ),
    );
  }
}

// ── Meta Row ──────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.mutedTextFor(brightness)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isTotalEmpty;
  final VoidCallback onCreate;
  const _EmptyState({required this.isTotalEmpty, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTotalEmpty ? Icons.domain_add_outlined : Icons.search_off_rounded,
              color: AppColors.accentBlue,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isTotalEmpty ? 'No projects yet' : 'No projects found',
            style: AppTextStyles.sectionTitle.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isTotalEmpty
                ? 'Create your first construction project to get started.'
                : 'Try adjusting your search or filters.',
            style: AppTextStyles.bodyMuted.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
            textAlign: TextAlign.center,
          ),
          if (isTotalEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 220,
              child: AppButton(
                text: '+ Create Project',
                icon: Icons.add_rounded,
                onPressed: onCreate,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Loading State ────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header placeholder
        Row(
          children: [
            Container(
              width: 120,
              height: 22,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightMutedSurface,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Spacer(),
            Container(
              width: 80,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < 3; i++) ...[
          Container(
            width: double.infinity,
            height: 180,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard
                  : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.borderFor(Theme.of(context).brightness),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: LoadingSkeleton(width: double.infinity, height: 18)),
                      SizedBox(width: AppSpacing.md),
                      LoadingSkeleton(width: 76, height: 24, borderRadius: 999),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  LoadingSkeleton(width: 180, height: 14),
                  SizedBox(height: AppSpacing.sm),
                  LoadingSkeleton(width: 140, height: 14),
                  SizedBox(height: AppSpacing.lg),
                  LoadingSkeleton(width: double.infinity, height: 6, borderRadius: 999),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Error State ──────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Couldn\'t load projects',
            style: AppTextStyles.cardTitle.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.bodyMuted.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: 180,
            child: AppButton(
              text: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}
