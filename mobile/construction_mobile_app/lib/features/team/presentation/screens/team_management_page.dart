import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_segmented_tabs.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/role_guard.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/animated_page_section.dart';
import '../../../project/presentation/providers/project_provider.dart';
import '../../domain/entities/project_member.dart';
import '../controllers/contractor_controller.dart';
import '../controllers/team_controller.dart';
import '../widgets/member_card.dart';
import '../widgets/invitation_card.dart';
import '../widgets/contractors_tab.dart';

class TeamManagementPage extends ConsumerStatefulWidget {
  const TeamManagementPage({super.key});

  @override
  ConsumerState<TeamManagementPage> createState() =>
      _TeamManagementPageState();
}

class _TeamManagementPageState extends ConsumerState<TeamManagementPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final projectId =
        (ref.watch(currentProjectProvider)?['id'] ?? '').toString();
    final teamState = ref.watch(teamControllerProvider(projectId));
    final l10n = AppLocalizations.of(context)!;
    final myRole = ref.watch(currentProjectRoleProvider);
    final normalizedRole = myRole == 'owner' ? 'project_manager' : myRole;
    final isPM = normalizedRole == 'project_manager';
    final canManageContractors = isPM;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.team),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref
                  .read(teamControllerProvider(projectId).notifier)
                  .loadTeam();
              if (_selectedTab == 1) {
                ref
                    .read(contractorControllerProvider.notifier)
                    .loadContractors();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(teamControllerProvider(projectId).notifier)
              .loadTeam();
          if (_selectedTab == 1) {
            await ref
                .read(contractorControllerProvider.notifier)
                .loadContractors();
          }
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedPageSection(
                    child: SectionHeader(
                      title: l10n.team,
                      subtitle: 'Manage members, contractors, and access',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AnimatedPageSection(
                    delay: const Duration(milliseconds: 60),
                    child: AppSegmentedTabs(
                      tabs: const [
                        AppSegmentedTab(
                          label: 'Members',
                          icon: Icons.people_rounded,
                        ),
                        AppSegmentedTab(
                          label: 'Contractors',
                          icon: Icons.engineering_rounded,
                        ),
                      ],
                      selectedIndex: _selectedTab,
                      onSelected: (index) {
                        setState(() => _selectedTab = index);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AnimatedPageSection(
                    delay: const Duration(milliseconds: 120),
                    child: _selectedTab == 0
                        ? _MembersTab(
                            teamState: teamState,
                            projectId: projectId,
                            isPM: isPM,
                            l10n: l10n,
                            onInvite: () =>
                                _showInviteSheet(context, ref, projectId),
                            onEditRole: (userId, currentRole) =>
                                _showRoleUpdateSheet(context, ref, projectId,
                                    userId, currentRole),
                            onRemove: (userId, name) =>
                                _showRemoveSheet(
                                    context, ref, projectId, userId, name),
                          )
                        : ContractorsTab(
                            canManage: canManageContractors,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteSheet(BuildContext context, WidgetRef ref, String projectId) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    String selectedRole = 'site_engineer';
    bool isLoading = false;
    String? errorMessage;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.inviteMember, style: AppTextStyles.screenTitle),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.invitationExplanation,
                      style: AppTextStyles.bodyMuted),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: l10n.emailAddress,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterEmail;
                      }
                      if (!value.contains('@')) {
                        return l10n.pleaseEnterValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppDropdownField<String>(
                    label: l10n.selectRole,
                    value: selectedRole,
                    items: [
                      DropdownMenuItem(
                        value: 'project_manager',
                        child: Text(l10n.projectManager),
                      ),
                      DropdownMenuItem(
                        value: 'consultant',
                        child: Text(l10n.consultant),
                      ),
                      DropdownMenuItem(
                        value: 'site_engineer',
                        child: Text(l10n.siteEngineer),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => selectedRole = value);
                      }
                    },
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: AppTextStyles.bodyMd
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    text: l10n.sendInvitation,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setModalState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            final success = await ref
                                .read(
                                    teamControllerProvider(projectId).notifier)
                                .inviteMember(
                                    emailController.text.trim(), selectedRole);
                            if (context.mounted) {
                              setModalState(() => isLoading = false);
                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Invitation sent to ${emailController.text.trim()}'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                ref
                                    .read(teamControllerProvider(projectId)
                                        .notifier)
                                    .loadTeam();
                              } else {
                                final error = ref
                                    .read(teamControllerProvider(projectId))
                                    .error;
                                setModalState(() => errorMessage =
                                    error ?? 'Failed to send invitation');
                              }
                            }
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRoleUpdateSheet(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String userId,
    String currentRole,
  ) {
    String selectedRole = currentRole;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.changeRole, style: AppTextStyles.screenTitle),
                const SizedBox(height: AppSpacing.xl),
                AppDropdownField<String>(
                  label: l10n.selectRole,
                  value: selectedRole,
                  items: [
                    DropdownMenuItem(
                        value: 'project_manager',
                        child: Text(l10n.projectManager)),
                    DropdownMenuItem(
                        value: 'consultant', child: Text(l10n.consultant)),
                    DropdownMenuItem(
                        value: 'site_engineer', child: Text(l10n.siteEngineer)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: l10n.update,
                  onPressed: () async {
                    final success = await ref
                        .read(teamControllerProvider(projectId).notifier)
                        .updateMemberRole(userId, selectedRole);
                    if (success && context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRemoveSheet(
    BuildContext context,
    WidgetRef ref,
    String projectId,
    String userId,
    String name,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.removeMember, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.removeMemberConfirm(name),
                style: AppTextStyles.bodyMuted),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: l10n.removeMember,
              isDanger: true,
              onPressed: () async {
                final success = await ref
                    .read(teamControllerProvider(projectId).notifier)
                    .removeMember(userId);
                if (success && context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  final TeamState teamState;
  final String projectId;
  final bool isPM;
  final AppLocalizations l10n;
  final VoidCallback onInvite;
  final void Function(String userId, String currentRole) onEditRole;
  final void Function(String userId, String name) onRemove;

  const _MembersTab({
    required this.teamState,
    required this.projectId,
    required this.isPM,
    required this.l10n,
    required this.onInvite,
    required this.onEditRole,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (teamState.error != null) {
      return ErrorState(title: l10n.error, message: teamState.error!);
    }

    if (teamState.isLoading && teamState.members.isEmpty) {
      return _TeamLoading();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TeamSummary(
          members: teamState.members,
          invitationsCount: teamState.invitations.length,
        ),
        const SizedBox(height: AppSpacing.xl),
        RoleGuard(
          allowedRoles: const ['owner', 'project_manager'],
          child: SizedBox(
            width: 150,
            child: AppButton(
              text: l10n.inviteMember,
              icon: Icons.person_add_rounded,
              size: AppButtonSize.small,
              onPressed: onInvite,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (teamState.invitations.isNotEmpty) ...[
          SectionHeader(
            title: l10n.pendingInvitations,
            subtitle: l10n.invitedUserAcceptanceExplanation,
          ),
          const SizedBox(height: AppSpacing.md),
          CardStagger(
            children: [
              for (final invitation in teamState.invitations)
                InvitationCard(
                  email: invitation.email,
                  roleLabel: _roleLabel(invitation.role, l10n),
                  roleColor: _roleColor(invitation.role),
                  status: invitation.status,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        SectionHeader(title: l10n.teamMembers),
        const SizedBox(height: AppSpacing.md),
        if (teamState.members.isEmpty)
          EmptyState(
            title: l10n.noTeamMembers,
            message: l10n.noTeamMembersMessage,
            icon: Icons.groups_rounded,
          )
        else
          CardStagger(
            children: [
              for (final member in teamState.members)
                MemberCard(
                  name: member.fullName,
                  email: member.email,
                  phoneNumber: member.phoneNumber,
                  roleLabel: _roleLabel(member.role, l10n),
                  roleColor: _roleColor(member.role),
                  changeRoleLabel: l10n.changeRole,
                  removeMemberLabel: l10n.removeMember,
                  canManage: isPM && member.role != 'project_manager',
                  onEditRole: isPM
                      ? () => onEditRole(member.userId, member.role)
                      : null,
                  onRemove: isPM
                      ? () => onRemove(member.userId, member.fullName)
                      : null,
                ),
            ],
          ),
      ],
    );
  }

  String _roleLabel(String role, AppLocalizations l10n) {
    return switch (role) {
      'project_manager' || 'owner' => l10n.projectManager,
      'consultant' => l10n.consultant,
      'site_engineer' => l10n.siteEngineer,
      _ => role,
    };
  }

  Color _roleColor(String role) {
    return switch (role) {
      'project_manager' || 'owner' => AppColors.accentBlueStrong,
      'consultant' => AppColors.statusConsultantApproved,
      'site_engineer' => AppColors.constructProBlue,
      _ => AppColors.statusDraft,
    };
  }
}

class _TeamSummary extends StatelessWidget {
  final List<ProjectMember> members;
  final int invitationsCount;

  const _TeamSummary({
    required this.members,
    required this.invitationsCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    int count(String role) =>
        members.where((member) => member.role == role).length;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _TeamChip(label: l10n.totalMembers, value: members.length),
        _TeamChip(label: l10n.projectManagers, value: count('project_manager')),
        _TeamChip(label: l10n.consultants, value: count('consultant')),
        _TeamChip(label: l10n.siteEngineers, value: count('site_engineer')),
        _TeamChip(label: l10n.pendingInvitations, value: invitationsCount),
      ],
    );
  }
}

class _TeamChip extends StatelessWidget {
  final String label;
  final int value;

  const _TeamChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      shadow: const [],
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value.toString(),
              style: AppTextStyles.cardTitle
                  .copyWith(color: AppColors.accentBlue)),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.label),
        ],
      ),
    );
  }
}

class _TeamLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LoadingSkeleton(
            width: double.infinity, height: 90, borderRadius: 16),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < 4; i++) ...[
          const LoadingSkeleton(
              width: double.infinity, height: 106, borderRadius: 16),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
