import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../domain/entities/task.dart';

import '../controllers/task_controller.dart'

    show taskControllerProvider, projectTasksProvider;

import '../../../team/domain/entities/project_member.dart';

import '../../../team/presentation/controllers/team_controller.dart'

    show teamControllerProvider;

import '../../../project/presentation/providers/project_provider.dart'

    show currentProjectProvider;

import '../../../../core/routing/route_names.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_radius.dart';

import '../../../../core/theme/app_spacing.dart';

import '../../../../core/theme/app_text_styles.dart';

import '../../../../core/widgets/app_button.dart';

import '../../../../core/widgets/app_card.dart';

import '../../../../core/widgets/app_text_field.dart';

import '../../../../core/widgets/app_bottom_sheet.dart';

import '../../../../core/widgets/app_segmented_tabs.dart';

import '../../../../core/widgets/responsive_content.dart';

import '../../../../core/widgets/section_header.dart';

import '../../../../core/widgets/role_badge.dart';



class TaskCreationPage extends ConsumerStatefulWidget {

  final String projectId;



  const TaskCreationPage({super.key, required this.projectId});



  @override

  ConsumerState<TaskCreationPage> createState() => _TaskCreationPageState();

}



class _TaskCreationPageState extends ConsumerState<TaskCreationPage> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _durationController = TextEditingController();

  late PageController _pageController;

  int _currentPage = 0;



  DateTime? _startDate;

  DateTime? _endDate;

  String _status = 'pending';

  String? _assignedToMemberId;

  int? _plannedDuration;

  final List<String> _selectedDependencyIds = [];

  bool _isSaving = false;



  @override

  void initState() {

    super.initState();

    _pageController = PageController();

  }



  @override

  void dispose() {

    _nameController.dispose();

    _descriptionController.dispose();

    _durationController.dispose();

    _pageController.dispose();

    super.dispose();

  }



  int? _calculateDuration() {

    if (_startDate != null && _endDate != null) {

      return _endDate!.difference(_startDate!).inDays;

    }

    return null;

  }



  Future<void> _selectDate(BuildContext context, bool isStartDate) async {

    final picked = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2020),

      lastDate: DateTime(2030),

    );

    if (picked != null) {

      setState(() {

        if (isStartDate) {

          _startDate = picked;

          if (_endDate != null && _endDate!.isBefore(_startDate!)) {

            _endDate = null;

          }

        } else {

          _endDate = picked;

        }

        _plannedDuration = _calculateDuration();

        if (_plannedDuration != null && _plannedDuration! > 0) {

          _durationController.text = _plannedDuration.toString();

        }

      });

    }

  }



  String? _validateDates() {

    if (_startDate == null) {

      return 'Start date is required';

    }

    if (_endDate == null) {

      return 'End date is required';

    }

    if (_endDate!.isBefore(_startDate!)) {

      return 'End date cannot be before start date';

    }

    return null;

  }



  void _showMemberSelector(List<ProjectMember> members) {

    final assignableMembers = members.where((member) {

      final role = member.role.toLowerCase();

      if (role == 'consultant') return false;

      return true;

    }).toList();



    assignableMembers.sort((a, b) {

      final roleOrder = {

        'site_engineer': 0,

        'project_manager': 2,

        'owner': 2,

      };

      final aRole = a.role.toLowerCase();

      final bRole = b.role.toLowerCase();

      final aOrder = roleOrder[aRole] ?? 3;

      final bOrder = roleOrder[bRole] ?? 3;

      return aOrder.compareTo(bOrder);

    });



    final brightness = Theme.of(context).brightness;

    final isDark = brightness == Brightness.dark;



    showAppBottomSheet(

      context: context,

      isScrollControlled: true,

      builder: (context) => AppBottomSheet(

        title: 'Assign To',

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Container(

              height: 48,

              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),

              child: InkWell(

                onTap: () {

                  setState(() => _assignedToMemberId = null);

                  Navigator.pop(context);

                },

                borderRadius: AppRadius.medium,

                child: Row(

                  children: [

                    CircleAvatar(

                      backgroundColor:

                          AppColors.accentBlue.withValues(alpha: 0.12),

                      child: const Icon(

                        Icons.person_outline_rounded,

                        color: AppColors.accentBlue,

                        size: 20,

                      ),

                    ),

                    const SizedBox(width: AppSpacing.md),

                    Expanded(

                      child: Text(

                        'Unassigned',

                        style: AppTextStyles.bodyMd.copyWith(

                          color: isDark

                              ? AppColors.darkTextPrimary

                              : AppColors.lightTextPrimary,

                        ),

                      ),

                    ),

                    if (_assignedToMemberId == null)

                      const Icon(

                        Icons.check_circle,

                        color: AppColors.success,

                        size: 20,

                      ),

                  ],

                ),

              ),

            ),

            const Divider(height: 1),

            Flexible(

              child: ListView(

                shrinkWrap: true,

                children: assignableMembers.map((member) {

                  return Container(

                    height: 48,

                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),

                    child: InkWell(

                      onTap: () {

                        setState(() => _assignedToMemberId = member.userId);

                        Navigator.pop(context);

                      },

                      borderRadius: AppRadius.medium,

                      child: Row(

                        children: [

                          CircleAvatar(

                            backgroundColor:

                                AppColors.accentBlue.withValues(alpha: 0.12),

                            child: Text(

                              member.fullName.isNotEmpty

                                  ? member.fullName[0].toUpperCase()

                                  : member.email[0].toUpperCase(),

                              style: AppTextStyles.label.copyWith(

                                color: AppColors.accentBlue,

                              ),

                            ),

                          ),

                          const SizedBox(width: AppSpacing.md),

                          Expanded(

                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,

                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [

                                Text(

                                  member.fullName,

                                  style: AppTextStyles.bodyMd.copyWith(

                                    color: isDark

                                        ? AppColors.darkTextPrimary

                                        : AppColors.lightTextPrimary,

                                  ),

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                ),

                                Text(

                                  member.email,

                                  style: AppTextStyles.caption.copyWith(

                                    color: AppColors.secondaryTextFor(brightness),

                                  ),

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                ),

                              ],

                            ),

                          ),

                          const SizedBox(width: AppSpacing.sm),

                          RoleBadge(

                            label: member.role,

                            color: _getRoleColor(member.role),

                          ),

                          const SizedBox(width: AppSpacing.sm),

                          if (_assignedToMemberId == member.userId)

                            const Icon(

                              Icons.check_circle,

                              color: AppColors.success,

                              size: 20,

                            ),

                        ],

                      ),

                    ),

                  );

                }).toList(),

              ),

            ),

          ],

        ),

      ),

    );

  }



  void _showDependencySelector(List<Task> availableTasks) {

    final selectableTasks = availableTasks.where((task) {

      return !_selectedDependencyIds.contains(task.id);

    }).toList();



    final brightness = Theme.of(context).brightness;

    final isDark = brightness == Brightness.dark;



    showAppBottomSheet(

      context: context,

      isScrollControlled: true,

      builder: (context) => AppBottomSheet(

        title: 'Select Dependency',

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Flexible(

              child: selectableTasks.isEmpty

                  ? Container(

                      padding: const EdgeInsets.all(AppSpacing.xl),

                      child: Column(

                        mainAxisSize: MainAxisSize.min,

                        children: [

                          Icon(

                            Icons.task_alt_rounded,

                            size: 48,

                            color: AppColors.secondaryTextFor(brightness),

                          ),

                          const SizedBox(height: AppSpacing.md),

                          Text(

                            'No other tasks available',

                            style: AppTextStyles.bodyMuted.copyWith(

                              color: AppColors.secondaryTextFor(brightness),

                            ),

                          ),

                        ],

                      ),

                    )

                  : ListView(

                      shrinkWrap: true,

                      children: selectableTasks.map((task) {

                        return Container(

                          height: 48,

                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),

                          child: InkWell(

                            onTap: () {

                              setState(() {

                                _selectedDependencyIds.add(task.id);

                              });

                              Navigator.pop(context);

                            },

                            borderRadius: AppRadius.medium,

                            child: Row(

                              children: [

                                const Icon(

                                  Icons.add_circle_outline,

                                  color: AppColors.accentBlue,

                                  size: 20,

                                ),

                                const SizedBox(width: AppSpacing.md),

                                Expanded(

                                  child: Column(

                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [

                                      Text(

                                        task.name,

                                        style: AppTextStyles.bodyMd.copyWith(

                                          color: isDark

                                              ? AppColors.darkTextPrimary

                                              : AppColors.lightTextPrimary,

                                        ),

                                        maxLines: 1,

                                        overflow: TextOverflow.ellipsis,

                                      ),

                                      if (task.description != null)

                                        Text(

                                          task.description!,

                                          style: AppTextStyles.caption.copyWith(

                                            color: AppColors.secondaryTextFor(brightness),

                                          ),

                                          maxLines: 1,

                                          overflow: TextOverflow.ellipsis,

                                        ),

                                    ],

                                  ),

                                ),

                                const SizedBox(width: AppSpacing.sm),

                                Icon(

                                  Icons.chevron_right,

                                  color: AppColors.secondaryTextFor(brightness),

                                  size: 20,

                                ),

                              ],

                            ),

                          ),

                        );

                      }).toList(),

                    ),

            ),

          ],

        ),

      ),

    );

  }



  Color _getRoleColor(String role) {

    switch (role.toLowerCase()) {

      case 'project_manager':

      case 'owner':

        return AppColors.accentBlueStrong;

      case 'site_engineer':

        return AppColors.warning;

      case 'consultant':

        return AppColors.info;

      default:

        return AppColors.success;

    }

  }



  Future<void> _createTask() async {

    if (!_formKey.currentState!.validate()) return;



    final dateError = _validateDates();

    if (dateError != null) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(dateError),

          backgroundColor: AppColors.error,

        ),

      );

      return;

    }



    if (widget.projectId.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text('Project ID not found. Please select a project first.'),

          backgroundColor: AppColors.error,

        ),

      );

      return;

    }



    setState(() => _isSaving = true);



    try {

      final data = {

        'name': _nameController.text.trim(),

        'description': _descriptionController.text.trim(),

        'status': _status,

        'start_date': _startDate?.toIso8601String(),

        'end_date': _endDate?.toIso8601String(),

        'assigned_to': _assignedToMemberId,

        'planned_duration_days': _plannedDuration,

      };



      await ref.read(taskControllerProvider.notifier).createTask(

            widget.projectId,

            data,

          );



      await Future.delayed(const Duration(milliseconds: 100));



      final controllerState = ref.read(taskControllerProvider);



      if (mounted) {

        if (controllerState.hasError) {

          final error = controllerState.error.toString();

          ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(

              content: Text(_getErrorMessage(error)),

              backgroundColor: AppColors.error,

            ),

          );

        } else if (controllerState.hasValue && controllerState.value != null) {

          final createdTask = controllerState.value!;



          if (createdTask.id.isNotEmpty && _selectedDependencyIds.isNotEmpty) {

            for (final depId in _selectedDependencyIds) {

              await ref

                  .read(taskControllerProvider.notifier)

                  .addTaskDependency(createdTask.id, depId);

            }

          }



          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

              content: Text('Task created successfully'),

              backgroundColor: AppColors.success,

            ),

          );

          ref.invalidate(projectTasksProvider(widget.projectId));

          ref.invalidate(currentProjectProvider);

          if (context.mounted) {

            context.pop();

          }

          if (createdTask.id.isNotEmpty && context.mounted) {

            context.push('${RouteNames.tasks}/${createdTask.id}');

          }

        } else {

          ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

              content: Text('Task created successfully'),

              backgroundColor: AppColors.success,

            ),

          );

          ref.invalidate(projectTasksProvider(widget.projectId));

          ref.invalidate(currentProjectProvider);

          context.pop();

        }

      }

    } finally {

      if (mounted) {

        setState(() => _isSaving = false);

      }

    }

  }



  String _getErrorMessage(String error) {

    if (error.contains('422') || error.contains('validation')) {

      return 'Invalid task data. Please check your inputs.';

    }

    if (error.contains('403') || error.contains('401')) {

      return 'You don\'t have permission to create tasks.';

    }

    if (error.toLowerCase().contains('network') ||

        error.toLowerCase().contains('connection')) {

      return 'Network error. Please check your internet connection.';

    }

    if (error.contains('400')) {

      return 'Bad request. Please check your inputs.';

    }

    return 'Failed to create task. Please try again.';

  }



  @override

  Widget build(BuildContext context) {

    final teamState = ref.watch(teamControllerProvider(widget.projectId));

    final tasksAsync = ref.watch(projectTasksProvider(widget.projectId));

    final brightness = Theme.of(context).brightness;

    final isDark = brightness == Brightness.dark;



    final selectedMember = teamState.members.firstWhere(

      (m) => m.userId == _assignedToMemberId,

      orElse: () => ProjectMember(

        id: '',

        projectId: widget.projectId,

        userId: '',

        fullName: '',

        email: '',

        role: '',

      ),

    );



    final availableTasks = tasksAsync.value ?? [];





    return Scaffold(

      appBar: AppBar(

        title: const Text('Create Task'),

        centerTitle: false,

      ),

      body: Stack(

        children: [

          Form(

            key: _formKey,

            child: PageView(

              controller: _pageController,

              onPageChanged: (page) {

                setState(() => _currentPage = page);

              },

              children: [

                // Slide 1: Task Details

                _buildTaskDetailsSlide(isDark),



                // Slide 2: Schedule

                _buildScheduleSlide(isDark),



                // Slide 3: Assignment

                _buildAssignmentSlide(selectedMember, isDark),



                // Slide 4: Dependencies

                _buildDependenciesSlide(availableTasks, isDark),

              ],

            ),

          ),

          if (_isSaving)

            Container(

              color: Colors.black.withValues(alpha: 0.5),

              child: const Center(

                child: CircularProgressIndicator(

                  color: AppColors.constructProBlue,

                ),

              ),

            ),

        ],

      ),

      bottomNavigationBar: _buildBottomNavigation(isDark),

    );

  }



  Widget _buildTaskDetailsSlide(bool isDark) {

    return SingleChildScrollView(

      padding: const EdgeInsets.fromLTRB(

        AppSpacing.lg,

        AppSpacing.lg,

        AppSpacing.lg,

        200,

      ),

      child: ResponsiveContent(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SectionHeader(

              title: 'Task Details',

              subtitle: 'Enter the basic task information',

            ),

            const SizedBox(height: AppSpacing.lg),

            AppCard(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    'Task Details',

                    style: AppTextStyles.sectionTitle.copyWith(

                      color: isDark

                          ? AppColors.darkTextPrimary

                          : AppColors.lightTextPrimary,

                    ),

                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(

                    controller: _nameController,

                    label: 'Task Name',

                    hint: 'Enter task name',

                    validator: (value) {

                      if (value == null || value.trim().isEmpty) {

                        return 'Task name is required';

                      }

                      return null;

                    },

                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(

                    controller: _descriptionController,

                    label: 'Description',

                    hint: 'Enter task description',

                    maxLines: 4,

                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(

                    'Status',

                    style: AppTextStyles.label.copyWith(

                      color: AppColors.secondaryTextFor(Brightness.values[isDark ? 0 : 1]),

                    ),

                  ),

                  const SizedBox(height: AppSpacing.sm),

                  AppSegmentedTabs(

                    tabs: const [

                      AppSegmentedTab(

                        label: 'Pending',

                        icon: Icons.pending_outlined,

                      ),

                      AppSegmentedTab(

                        label: 'In Progress',

                        icon: Icons.play_arrow_outlined,

                      ),

                      AppSegmentedTab(

                        label: 'Completed',

                        icon: Icons.check_circle_outline,

                      ),

                    ],

                    selectedIndex: _status == 'pending'

                        ? 0

                        : _status == 'in_progress'

                            ? 1

                            : 2,

                    onSelected: (index) {

                      setState(() {

                        _status = index == 0

                            ? 'pending'

                            : index == 1

                                ? 'in_progress'

                                : 'completed';

                      });

                    },

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildScheduleSlide(bool isDark) {

    return SingleChildScrollView(

      padding: const EdgeInsets.fromLTRB(

        AppSpacing.lg,

        AppSpacing.lg,

        AppSpacing.lg,

        200,

      ),

      child: ResponsiveContent(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SectionHeader(

              title: 'Schedule',

              subtitle: 'Set the start and end dates',

            ),

            const SizedBox(height: AppSpacing.lg),

            AppCard(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    'Schedule',

                    style: AppTextStyles.sectionTitle.copyWith(

                      color: isDark

                          ? AppColors.darkTextPrimary

                          : AppColors.lightTextPrimary,

                    ),

                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _DateSelector(

                    label: 'Start Date',

                    date: _startDate,

                    isRequired: true,

                    onTap: () => _selectDate(context, true),

                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _DateSelector(

                    label: 'End Date',

                    date: _endDate,

                    isRequired: true,

                    onTap: () => _selectDate(context, false),

                  ),

                  if (_calculateDuration() != null && _calculateDuration()! > 0)

                    Padding(

                      padding: const EdgeInsets.only(top: AppSpacing.lg),

                      child: Container(

                        padding: const EdgeInsets.all(AppSpacing.md),

                        decoration: BoxDecoration(

                          color: AppColors.accentBlue.withValues(alpha: 0.12),

                          borderRadius: AppRadius.medium,

                        ),

                        child: Row(

                          children: [

                            const Icon(

                              Icons.schedule_rounded,

                              size: 18,

                              color: AppColors.accentBlue,

                            ),

                            const SizedBox(width: AppSpacing.sm),

                            Text(

                              '${_calculateDuration()} days',

                              style: AppTextStyles.label.copyWith(

                                color: AppColors.accentBlue,

                                fontWeight: FontWeight.w600,

                              ),

                            ),

                          ],

                        ),

                      ),

                    ),

                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(

                    controller: _durationController,

                    label: 'Planned Duration (Days)',

                    hint: 'Auto-calculated or enter manually',

                    keyboardType: TextInputType.number,

                    onChanged: (value) {

                      setState(() {

                        _plannedDuration = int.tryParse(value);

                      });

                    },

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildAssignmentSlide(ProjectMember? selectedMember, bool isDark) {

    return SingleChildScrollView(

      padding: const EdgeInsets.fromLTRB(

        AppSpacing.lg,

        AppSpacing.lg,

        AppSpacing.lg,

        200,

      ),

      child: ResponsiveContent(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SectionHeader(

              title: 'Assignment',

              subtitle: 'Assign the task to a team member',

            ),

            const SizedBox(height: AppSpacing.lg),

            AppCard(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    'Assignment',

                    style: AppTextStyles.sectionTitle.copyWith(

                      color: isDark

                          ? AppColors.darkTextPrimary

                          : AppColors.lightTextPrimary,

                    ),

                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _MemberSelector(

                    selectedMember: _assignedToMemberId == null

                        ? null

                        : selectedMember,

                    onTap: () {

                      final teamState = ref.watch(teamControllerProvider(widget.projectId));

                      _showMemberSelector(teamState.members);

                    },

                    isLoading: ref.watch(teamControllerProvider(widget.projectId)).isLoading,

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildDependenciesSlide(List<Task> availableTasks, bool isDark) {

    return SingleChildScrollView(

      padding: const EdgeInsets.fromLTRB(

        AppSpacing.lg,

        AppSpacing.lg,

        AppSpacing.lg,

        200,

      ),

      child: ResponsiveContent(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const SectionHeader(

              title: 'Task Dependencies',

              subtitle: 'Link this task to other tasks (optional)',

            ),

            const SizedBox(height: AppSpacing.lg),

            AppCard(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    'Task Dependencies',

                    style: AppTextStyles.sectionTitle.copyWith(

                      color: isDark

                          ? AppColors.darkTextPrimary

                          : AppColors.lightTextPrimary,

                    ),

                  ),

                  const SizedBox(height: AppSpacing.md),

                  if (_selectedDependencyIds.isEmpty)

                    Container(

                      padding: const EdgeInsets.all(AppSpacing.md),

                      decoration: BoxDecoration(

                        color: AppColors.surfaceFor(Brightness.values[isDark ? 0 : 1])

                            .withValues(alpha: 0.5),

                        borderRadius: AppRadius.medium,

                        border: Border.all(color: AppColors.borderFor(Brightness.values[isDark ? 0 : 1])),

                      ),

                      child: Row(

                        children: [

                          Icon(

                            Icons.link_off_rounded,

                            size: 18,

                            color: AppColors.secondaryTextFor(Brightness.values[isDark ? 0 : 1]),

                          ),

                          const SizedBox(width: AppSpacing.sm),

                          Text(

                            'No dependencies selected',

                            style: AppTextStyles.bodyMuted.copyWith(

                              color: AppColors.secondaryTextFor(Brightness.values[isDark ? 0 : 1]),

                            ),

                          ),

                        ],

                      ),

                    )

                  else

                    Wrap(

                      spacing: AppSpacing.sm,

                      runSpacing: AppSpacing.sm,

                      children: _selectedDependencyIds.map((depId) {

                        final task = availableTasks.firstWhere(

                          (t) => t.id == depId,

                          orElse: () => Task(

                            id: depId,

                            projectId: widget.projectId,

                            name: 'Unknown Task',

                            status: 'pending',

                            progressPercentage: 0.0,

                          ),

                        );

                        return Chip(

                          label: Text(task.name),

                          deleteIcon: const Icon(Icons.close, size: 18),

                          onDeleted: () {

                            setState(() {

                              _selectedDependencyIds.remove(depId);

                            });

                          },

                          backgroundColor: AppColors.accentBlue.withValues(alpha: 0.12),

                          labelStyle: AppTextStyles.label.copyWith(

                            color: AppColors.accentBlue,

                          ),

                          deleteIconColor: AppColors.accentBlue,

                        );

                      }).toList(),

                    ),

                  const SizedBox(height: AppSpacing.md),

                  AppButton(

                    text: 'Add Dependency',

                    icon: Icons.add_link_rounded,

                    onPressed: () =>

                        _showDependencySelector(availableTasks),

                    isOutline: true,

                  ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildBottomNavigation(bool isDark) {

    final isFirstPage = _currentPage == 0;

    final isLastPage = _currentPage == 3;



    return Container(

      padding: EdgeInsets.fromLTRB(

        AppSpacing.lg,

        AppSpacing.md,

        AppSpacing.lg,

        MediaQuery.paddingOf(context).bottom + AppSpacing.md,

      ),

      decoration: BoxDecoration(

        color: isDark ? AppColors.darkCard : AppColors.lightCard,

        border: Border(

          top: BorderSide(color: AppColors.borderFor(Brightness.values[isDark ? 0 : 1])),

        ),

      ),

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          // Page Indicators

          Row(

            mainAxisAlignment: MainAxisAlignment.center,

            children: List.generate(

              4,

              (index) => Container(

                width: _currentPage == index ? 24 : 8,

                height: 8,

                margin: const EdgeInsets.symmetric(horizontal: 4),

                decoration: BoxDecoration(

                  color: _currentPage == index

                      ? AppColors.accentBlue

                      : AppColors.secondaryTextFor(Brightness.values[isDark ? 0 : 1]),

                  borderRadius: BorderRadius.circular(4),

                ),

              ),

            ),

          ),

          const SizedBox(height: AppSpacing.md),

          // Navigation Buttons

          Row(

            children: [

              if (!isFirstPage) ...[

                Expanded(

                  child: AppButton(

                    text: 'Previous',

                    icon: Icons.arrow_back_rounded,

                    onPressed: () {

                      _pageController.previousPage(

                        duration: const Duration(milliseconds: 300),

                        curve: Curves.easeInOut,

                      );

                    },

                    isOutline: true,

                  ),

                ),

                const SizedBox(width: AppSpacing.md),

              ],

              Expanded(

                child: isLastPage

                    ? AppButton(

                        text: 'Create Task',

                        icon: Icons.add_task_rounded,

                        onPressed: _isSaving ? null : _createTask,

                        isLoading: _isSaving,

                      )

                    : AppButton(

                        text: 'Next',

                        icon: Icons.arrow_forward_rounded,

                        onPressed: () {

                          if (_currentPage == 0) {

                            if (!_formKey.currentState!.validate()) return;

                          }

                          _pageController.nextPage(

                            duration: const Duration(milliseconds: 300),

                            curve: Curves.easeInOut,

                          );

                        },

                      ),

              ),

            ],

          ),

        ],

      ),

    );

  }



}



class _MemberSelector extends StatelessWidget {

  final ProjectMember? selectedMember;

  final VoidCallback onTap;

  final bool isLoading;



  const _MemberSelector({

    required this.selectedMember,

    required this.onTap,

    required this.isLoading,

  });



  @override

  Widget build(BuildContext context) {

    final brightness = Theme.of(context).brightness;

    final isDark = brightness == Brightness.dark;



    return InkWell(

      onTap: onTap,

      borderRadius: AppRadius.medium,

      child: Container(

        height: 56,

        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),

        decoration: BoxDecoration(

          color: isDark ? AppColors.darkSurface : AppColors.lightMutedSurface,

          border: Border.all(color: AppColors.borderFor(brightness)),

          borderRadius: AppRadius.medium,

        ),

        child: Row(

          children: [

            if (selectedMember != null && selectedMember!.userId.isNotEmpty)

              CircleAvatar(

                backgroundColor: AppColors.accentBlue.withValues(alpha: 0.12),

                child: Text(

                  selectedMember!.fullName.isNotEmpty

                      ? selectedMember!.fullName[0].toUpperCase()

                      : selectedMember!.email[0].toUpperCase(),

                  style: AppTextStyles.label.copyWith(

                    color: AppColors.accentBlue,

                  ),

                ),

              )

            else

              CircleAvatar(

                backgroundColor: AppColors.accentBlue.withValues(alpha: 0.12),

                child: const Icon(

                  Icons.person_outline_rounded,

                  color: AppColors.accentBlue,

                  size: 20,

                ),

              ),

            const SizedBox(width: AppSpacing.md),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Text(

                    selectedMember?.fullName ?? 'Unassigned',

                    style: AppTextStyles.bodyMd.copyWith(

                      color: isDark

                          ? AppColors.darkTextPrimary

                          : AppColors.lightTextPrimary,

                    ),

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                  ),

                  if (selectedMember != null)

                    Text(

                      selectedMember!.email,

                      style: AppTextStyles.caption.copyWith(

                        color: AppColors.secondaryTextFor(brightness),

                      ),

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                    ),

                ],

              ),

            ),

            if (selectedMember != null) ...[

              const SizedBox(width: AppSpacing.sm),

              RoleBadge(

                label: selectedMember!.role,

                color: _getRoleColor(selectedMember!.role),

              ),

            ],

            const SizedBox(width: AppSpacing.sm),

            Icon(

              Icons.chevron_right,

              color: AppColors.secondaryTextFor(brightness),

              size: 20,

            ),

          ],

        ),

      ),

    );

  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'project_manager':
        return AppColors.accentBlue;
      case 'site_engineer':
        return AppColors.accentGreen;
      case 'supervisor':
        return AppColors.accentOrange;
      default:
        return AppColors.accentBlue;
    }
  }

}

class _DateSelector extends StatelessWidget {

  final String label;

  final DateTime? date;

  final bool isRequired;

  final VoidCallback onTap;



  const _DateSelector({

    required this.label,

    required this.date,

    required this.onTap,

    this.isRequired = false,

  });



  @override

  Widget build(BuildContext context) {

    final brightness = Theme.of(context).brightness;

    final isDark = brightness == Brightness.dark;

    final dateFormat = DateFormat('MMM dd, yyyy');



    return InkWell(

      onTap: onTap,

      borderRadius: AppRadius.medium,

      child: Container(

        height: 56,

        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),

        decoration: BoxDecoration(

          color: isDark ? AppColors.darkSurface : AppColors.lightMutedSurface,

          border: Border.all(color: AppColors.borderFor(brightness)),

          borderRadius: AppRadius.medium,

        ),

        child: Row(

          children: [

            const Icon(

              Icons.calendar_today_rounded,

              color: AppColors.accentBlue,

              size: 20,

            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Text(

                    label,

                    style: AppTextStyles.caption.copyWith(

                      color: AppColors.secondaryTextFor(brightness),

                    ),

                  ),

                  const SizedBox(height: 2),

                  Text(

                    date != null ? dateFormat.format(date!) : 'Select date',

                    style: AppTextStyles.bodyMd.copyWith(

                      color: date != null

                          ? (isDark

                              ? AppColors.darkTextPrimary

                              : AppColors.lightTextPrimary)

                          : AppColors.secondaryTextFor(brightness),

                    ),

                  ),

                ],

              ),

            ),

            if (isRequired && date == null)

              const Icon(Icons.error_outline, color: AppColors.error, size: 20),

          ],

        ),

      ),

    );

  }

}




