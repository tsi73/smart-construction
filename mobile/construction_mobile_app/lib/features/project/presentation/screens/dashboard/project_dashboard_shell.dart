import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/network/network_info.dart';
import '../../providers/project_provider.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_nav.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_icon_button.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/widgets/app_top_bar.dart';
import '../../../../../core/widgets/role_badge.dart';
import 'project_manager_dashboard.dart';
import 'site_engineer_dashboard.dart';
import 'consultant_dashboard.dart';
import 'more_view.dart';
import 'dashboard_widgets.dart';
import 'package:construction_mobile_app/features/daily_log/presentation/screens/daily_log_list_page.dart';
import 'package:construction_mobile_app/features/task/presentation/screens/task_list_page.dart';
import 'package:construction_mobile_app/features/budget/presentation/screens/budget_page.dart';
import '../../../../../core/notifications/notification_service.dart';

class ProjectDashboardShell extends ConsumerStatefulWidget {
  const ProjectDashboardShell({super.key});

  @override
  ConsumerState<ProjectDashboardShell> createState() =>
      _ProjectDashboardShellState();
}

class _ProjectDashboardShellState extends ConsumerState<ProjectDashboardShell> {
  int _selectedIndex = 0;

  Widget _notificationIconWithBadge() {
    final unreadCount = ref.watch(notificationServiceProvider).unreadCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          onPressed: () => context.go(RouteNames.notifications),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(currentProjectProvider);
    final role = ref.watch(currentProjectRoleProvider);
    final networkStatus = ref.watch(networkStatusProvider).valueOrNull;
    final l10n = AppLocalizations.of(context)!;
    final projectId = (project?['id'] ?? '').toString();
    final projectName = (project?['name'] ?? l10n.projects).toString();

    // If no project is selected, show error
    if (project == null || projectId.isEmpty) {
      return AppScaffold(
        appBar: AppBar(title: Text(projectName)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'No Project Selected',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Please select a project from the projects list to continue.',
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.secondaryTextFor(
                        Theme.of(context).brightness),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Go to Projects',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => context.push(RouteNames.projects),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final normalizedRole = role == 'owner' ? 'project_manager' : role;

    if (normalizedRole == null || !_isSupportedRole(normalizedRole)) {
      return AppScaffold(
        appBar: AppBar(title: Text(projectName)),
        body: _RoleErrorState(
          message: normalizedRole == null
              ? l10n.couldNotVerifyRole
              : 'This project role is not supported on the mobile dashboard: $normalizedRole',
        ),
      );
    }

    final destinations = _getDestinations(normalizedRole, projectId, l10n);

    if (_selectedIndex >= destinations.length) {
      _selectedIndex = 0;
    }

    final roleLabel = _roleLabel(normalizedRole, l10n);
    final roleColor = _roleColor(normalizedRole);
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: KeyedSubtree(
        key: ValueKey(_selectedIndex),
        child: destinations[_selectedIndex].page,
      ),
    );
    final contentBody = Column(
      children: [
        if (networkStatus == NetworkStatus.offline)
          const DashboardOfflineBanner(),
        Expanded(child: body),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;

        if (isWide) {
          return AppScaffold(
            body: Row(
              children: [
                _ProjectSidebar(
                  projectName: projectName,
                  roleLabel: roleLabel,
                  roleColor: roleColor,
                  destinations: destinations,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      AppTopBar(
                        title: projectName,
                        subtitle: roleLabel,
                        actions: [
                          _notificationIconWithBadge(),
                        ],
                      ),
                      Expanded(
                        child: contentBody,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return AppScaffold(
          appBar: AppBar(
            toolbarHeight: 76,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectName,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                RoleBadge(label: roleLabel, color: roleColor),
              ],
            ),
            actions: [
              const SizedBox(width: AppSpacing.sm),
              _notificationIconWithBadge(),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: contentBody,
          bottomNavigationBar: AppBottomNav(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: [
              for (final destination in destinations)
                AppBottomNavItem(
                  icon: destination.icon,
                  label: destination.label,
                ),
            ],
          ),
        );
      },
    );
  }

  List<_ShellDestination> _getDestinations(
    String role,
    String projectId,
    AppLocalizations l10n,
  ) {
    final normalizedRole = role == 'owner' ? 'project_manager' : role;

    switch (normalizedRole) {
      case 'project_manager':
        return [
          _ShellDestination(
            icon: Icons.dashboard_rounded,
            label: l10n.home,
            page: const ProjectManagerDashboardBody(),
          ),
          _ShellDestination(
            icon: Icons.assignment_rounded,
            label: l10n.tasks,
            page: TaskListPage(projectId: projectId),
          ),
          _ShellDestination(
            icon: Icons.description_rounded,
            label: l10n.logs,
            page: DailyLogListPage(projectId: projectId),
          ),
          const _ShellDestination(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Budget',
            page: BudgetPage(),
          ),
          _ShellDestination(
            icon: Icons.grid_view_rounded,
            label: l10n.more,
            page: const MoreView(),
          ),
        ];
      case 'site_engineer':
        return [
          _ShellDestination(
            icon: Icons.dashboard_rounded,
            label: l10n.home,
            page: const SiteEngineerDashboardBody(),
          ),
          _ShellDestination(
            icon: Icons.assignment_rounded,
            label: l10n.tasks,
            page: TaskListPage(projectId: projectId),
          ),
          _ShellDestination(
            icon: Icons.description_rounded,
            label: l10n.logs,
            page: DailyLogListPage(projectId: projectId),
          ),
          const _ShellDestination(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Budget',
            page: BudgetPage(),
          ),
          _ShellDestination(
            icon: Icons.grid_view_rounded,
            label: l10n.more,
            page: const MoreView(),
          ),
        ];
      case 'consultant':
        return [
          _ShellDestination(
            icon: Icons.dashboard_rounded,
            label: l10n.home,
            page: const ConsultantDashboardBody(),
          ),
          _ShellDestination(
            icon: Icons.description_rounded,
            label: l10n.logs,
            page: DailyLogListPage(projectId: projectId),
          ),
          const _ShellDestination(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Budget',
            page: BudgetPage(),
          ),
          _ShellDestination(
            icon: Icons.grid_view_rounded,
            label: l10n.more,
            page: const MoreView(),
          ),
        ];
      default:
        return [
          _ShellDestination(
            icon: Icons.dashboard_rounded,
            label: l10n.home,
            page: _ShellPlaceholder(label: l10n.error),
          ),
        ];
    }
  }

  String _roleLabel(String role, AppLocalizations l10n) {
    switch (role) {
      case 'owner':
      case 'project_manager':
        return l10n.projectManager;
      case 'site_engineer':
        return l10n.siteEngineer;
      case 'consultant':
        return l10n.consultant;
      default:
        return role;
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'owner':
      case 'project_manager':
        return AppColors.accentBlueStrong;
      case 'site_engineer':
        return AppColors.constructProBlue;
      case 'consultant':
        return AppColors.statusConsultantApproved;
      default:
        return AppColors.statusDraft;
    }
  }

  bool _isSupportedRole(String role) {
    return role == 'project_manager' ||
        role == 'site_engineer' ||
        role == 'consultant';
  }

}

class _RoleErrorState extends StatelessWidget {
  final String message;

  const _RoleErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: AppRadius.doubleExtraLarge,
              border: Border.all(color: AppColors.borderFor(brightness)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Access Restricted',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectSidebar extends StatelessWidget {
  final String projectName;
  final String roleLabel;
  final Color roleColor;
  final List<_ShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _ProjectSidebar({
    required this.projectName,
    required this.roleLabel,
    required this.roleColor,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.darkSurface : AppColors.navySidebar;
    final borderColor = isDark ? AppColors.darkBorder : Colors.white12;

    return Container(
      width: 276,
      decoration: BoxDecoration(
        color: background,
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: AppRadius.medium,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Image.asset(
                      'assets/branding/apple-icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Foresite',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.08),
                  borderRadius: AppRadius.large,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style: AppTextStyles.label.copyWith(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    RoleBadge(label: roleLabel, color: roleColor),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView.separated(
                  itemCount: destinations.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final destination = destinations[index];
                    final selected = index == selectedIndex;
                    return _SidebarNavItem(
                      icon: destination.icon,
                      label: destination.label,
                      selected: selected,
                      onTap: () => onDestinationSelected(index),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SidebarNavItem(
                icon: Icons.settings_rounded,
                label: l10n.settings,
                selected: false,
                onTap: () => context.push(RouteNames.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const active = AppColors.accentBlue;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.medium,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? active.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: AppRadius.medium,
          border: Border.all(
            color:
                selected ? active.withValues(alpha: 0.42) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? active : Colors.white70, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellDestination {
  final IconData icon;
  final String label;
  final Widget page;

  const _ShellDestination({
    required this.icon,
    required this.label,
    required this.page,
  });
}

class _ShellPlaceholder extends StatelessWidget {
  final String label;

  const _ShellPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_copy_rounded,
              color: AppColors.mutedTextFor(brightness),
              size: 42,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: AppTextStyles.sectionTitle.copyWith(
                color: brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
