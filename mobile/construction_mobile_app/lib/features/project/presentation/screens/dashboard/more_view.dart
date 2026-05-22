import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../providers/project_provider.dart';
import '../../../../../core/routing/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/responsive_content.dart';
import '../../../../../core/widgets/role_badge.dart';
import '../../../../../core/widgets/animated_page_section.dart';
import '../../../../../core/widgets/section_header.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class MoreView extends ConsumerWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final project = ref.watch(currentProjectProvider);
    final role = ref.watch(currentProjectRoleProvider);
    final normalizedRole = role == 'owner' ? 'project_manager' : role;
    final isPM = normalizedRole == 'project_manager';
    final isConsultant = normalizedRole == 'consultant';
    final projectName = (project?['name'] ?? l10n.projects).toString();

    // Build sectioned menu items
    final projectItems = <_MoreMenuItem>[];
    final accountItems = <_MoreMenuItem>[];
    final systemItems = <_MoreMenuItem>[];

    // ── Project section ──
    if (isPM) {
      projectItems.addAll([
        _MoreMenuItem(
          icon: Icons.groups_rounded,
          title: l10n.team,
          subtitle: 'Members, contractors, and access',
          onTap: () => context.push('${RouteNames.projectDashboard}/team'),
        ),
        _MoreMenuItem(
          icon: Icons.tune_rounded,
          title: l10n.projectSettings,
          subtitle: l10n.projectSettingsMobileNote,
          onTap: () => _showProjectInfoSheet(context, l10n, role: role),
        ),
      ]);
    } else {
      // Project info removed
    }

    if (isConsultant) {
      projectItems.add(
        _MoreMenuItem(
          icon: Icons.assignment_rounded,
          title: l10n.tasksReadOnly,
          subtitle: l10n.readOnly,
          onTap: () => context.push(RouteNames.tasks),
        ),
      );
    }

    // ── Account section ──
    accountItems.addAll([
      _MoreMenuItem(
        icon: Icons.person_outline_rounded,
        title: l10n.profile,
        subtitle: l10n.account,
        onTap: () => context.push(RouteNames.profile),
      ),
      _MoreMenuItem(
        icon: Icons.settings_outlined,
        title: l10n.settings,
        subtitle: l10n.appearanceAndPreferences,
        onTap: () => context.push(RouteNames.settings),
      ),
    ]);

    // ── System section ──
    systemItems.addAll([
      _MoreMenuItem(
        icon: Icons.sync_rounded,
        title: l10n.syncQueue,
        subtitle: l10n.pendingSync,
        onTap: () => context.push(RouteNames.syncQueue),
      ),
      _MoreMenuItem(
        icon: Icons.logout_rounded,
        title: l10n.logout,
        subtitle: l10n.signOutOfAccount,
        color: AppColors.error,
        onTap: () {
          ref.read(authProvider.notifier).logout();
          // Clear project state to prevent cross-account data leakage
          ref.read(currentProjectProvider.notifier).state = null;
          ref.read(currentProjectRoleProvider.notifier).state = null;
          ref.read(isCurrentProjectOwnerProvider.notifier).state = false;
          context.go(RouteNames.login);
        },
      ),
    ]);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ResponsiveContent(
          maxWidth: 900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: l10n.more,
                subtitle: l10n.moreMenuSubtitle,
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedPageSection(
                child: _ProjectContextCard(
                  projectName: projectName,
                  roleLabel: _roleLabel(normalizedRole, l10n),
                  roleColor: _roleColor(normalizedRole),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Project section
              if (projectItems.isNotEmpty) ...[
                AnimatedPageSection(
                  delay: const Duration(milliseconds: 60),
                  child: _MenuSection(
                    label: 'Project',
                    items: projectItems,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              // Account section
              AnimatedPageSection(
                delay: const Duration(milliseconds: 120),
                child: _MenuSection(
                  label: 'Account',
                  items: accountItems,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // System section
              AnimatedPageSection(
                delay: const Duration(milliseconds: 180),
                child: _MenuSection(
                  label: 'System',
                  items: systemItems,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }

  void _showProjectInfoSheet(BuildContext context, AppLocalizations l10n,
      {String? role}) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.cardFor(Theme.of(context).brightness),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.projectInfo, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.projectSettingsMobileNote,
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.secondaryTextFor(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: l10n.ok,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String? role, AppLocalizations l10n) {
    switch (role) {
      case 'owner':
      case 'project_manager':
        return l10n.projectManager;
      case 'site_engineer':
        return l10n.siteEngineer;
      case 'consultant':
        return l10n.consultant;
      default:
        return l10n.readOnly;
    }
  }

  Color _roleColor(String? role) {
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
}

// ─── Menu Section (label + rows) ────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final String label;
  final List<_MoreMenuItem> items;

  const _MenuSection({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.md,
          ),
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              color: AppColors.secondaryTextFor(brightness),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderFor(brightness),
                    ),
                  ),
                _MoreMenuRow(item: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── More Menu Row ───────────────────────────────────────────────────────────

class _MoreMenuRow extends StatelessWidget {
  final _MoreMenuItem item;

  const _MoreMenuRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final color = item.color ?? AppColors.accentBlue;

    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.label.copyWith(
                      color: item.color ??
                          (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryTextFor(brightness),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

// ─── Project Context Card ────────────────────────────────────────────────────

class _ProjectContextCard extends StatelessWidget {
  final String projectName;
  final String roleLabel;
  final Color roleColor;

  const _ProjectContextCard({
    required this.projectName,
    required this.roleLabel,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.constructProBlue.withValues(alpha: 0.14),
              borderRadius: AppRadius.large,
              border: Border.all(
                color: AppColors.constructProBlue.withValues(alpha: 0.28),
              ),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: AppColors.constructProBlue,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectName,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                RoleBadge(label: roleLabel, color: roleColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── More Menu Item ──────────────────────────────────────────────────────────

class _MoreMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _MoreMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });
}
