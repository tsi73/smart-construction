import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../project/presentation/providers/project_provider.dart';
import '../controllers/settings_controller.dart';
import 'sync_queue_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final currentRole = ref.watch(currentProjectRoleProvider);
    final user = authState.user;
    final syncItems = ref.watch(syncQueueItemsProvider).valueOrNull ?? [];
    final pendingCount =
        syncItems.where((item) => item.status != 'failed').length;
    final failedCount =
        syncItems.where((item) => item.status == 'failed').length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ResponsiveContent(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: l10n.settings,
                  subtitle: l10n.appearanceAndPreferences,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (user != null) ...[
                  _SettingsGroup(
                    title: l10n.account,
                    children: [
                      _ProfileSummary(
                        name: (user['full_name'] ?? '').toString(),
                        email: (user['email'] ?? '').toString(),
                        roleLabel: _roleLabel(currentRole, l10n),
                        roleColor: _roleColor(currentRole),
                        onTap: () => context.push(RouteNames.profile),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                _SettingsGroup(
                  title: l10n.appearance,
                  children: [
                    AppDropdownField<ThemeMode>(
                      label: l10n.theme,
                      value: settings.themeMode,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(l10n.systemDefault),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(l10n.lightMode),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(l10n.darkMode),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setThemeMode(mode);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppDropdownField<String>(
                      label: l10n.language,
                      value: settings.locale.languageCode,
                      items: [
                        DropdownMenuItem(
                            value: 'en', child: Text(l10n.english)),
                        DropdownMenuItem(
                            value: 'am', child: Text(l10n.amharic)),
                      ],
                      onChanged: (code) {
                        if (code != null) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setLocale(Locale(code));
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppDropdownField<CalendarType>(
                      label: l10n.calendar,
                      value: settings.calendarType,
                      items: [
                        DropdownMenuItem(
                          value: CalendarType.gregorian,
                          child: Text(l10n.gregorianCalendar),
                        ),
                        DropdownMenuItem(
                          value: CalendarType.ethiopian,
                          child: Text(l10n.ethiopianCalendar),
                        ),
                      ],
                      onChanged: (type) {
                        if (type != null) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .setCalendarType(type);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _SettingsGroup(
                  title: l10n.sync,
                  children: [
                    _MetricRow(
                      icon: Icons.schedule_rounded,
                      label: l10n.pending,
                      value: pendingCount.toString(),
                      color: AppColors.statusPendingSync,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _MetricRow(
                      icon: Icons.error_outline_rounded,
                      label: l10n.failed,
                      value: failedCount.toString(),
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      text: l10n.viewSyncQueue,
                      icon: Icons.sync_rounded,
                      size: AppButtonSize.medium,
                      onPressed: () => context.push(RouteNames.syncQueue),
                    ),
                  ],
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _SettingsGroup(
                    title: l10n.developerInfo,
                    children: [
                      _InfoRow(
                          label: l10n.appVersion, value: AppConfig.appVersion),
                      const SizedBox(height: AppSpacing.md),
                      _InfoRow(
                        label: l10n.environment,
                        value: AppConfig.environment.name.toUpperCase(),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: l10n.logout,
                  icon: Icons.logout_rounded,
                  isOutline: true,
                  isDanger: true,
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    // Clear project state to prevent cross-account data leakage
                    ref.read(currentProjectProvider.notifier).state = null;
                    ref.read(currentProjectRoleProvider.notifier).state = null;
                    ref.read(isCurrentProjectOwnerProvider.notifier).state =
                        false;
                    context.go(RouteNames.login);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
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

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.label.copyWith(
            color: AppColors.mutedTextFor(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  final String name;
  final String email;
  final String roleLabel;
  final Color roleColor;
  final VoidCallback onTap;

  const _ProfileSummary({
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.roleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final displayName = name.trim().isEmpty ? email : name;
    final initial =
        displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.large,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.constructProBlue.withValues(alpha: 0.14),
              borderRadius: AppRadius.large,
              border: Border.all(
                color: AppColors.constructProBlue.withValues(alpha: 0.28),
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.constructProBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                RoleBadge(label: roleLabel, color: roleColor),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedTextFor(brightness),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.medium,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: brightness == Brightness.dark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.cardTitle.copyWith(color: color),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.label.copyWith(
            color: brightness == Brightness.dark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
