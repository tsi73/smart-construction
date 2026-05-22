import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../project/presentation/providers/project_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController =
        TextEditingController(text: (user?['full_name'] ?? '').toString());
    _emailController =
        TextEditingController(text: (user?['email'] ?? '').toString());
    _phoneController =
        TextEditingController(text: (user?['phone_number'] ?? '').toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers if cancelling
        final user = ref.read(authProvider).user;
        _nameController.text = (user?['full_name'] ?? '').toString();
        _emailController.text = (user?['email'] ?? '').toString();
        _phoneController.text = (user?['phone_number'] ?? '').toString();
      }
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    final success = await ref.read(authProvider.notifier).updateProfile({
      'full_name': _nameController.text,
      'email': _emailController.text,
      'phone_number': _phoneController.text,
    });

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      if (success) _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Profile updated' : 'Failed to update profile'),
      backgroundColor: success ? AppColors.success : AppColors.error,
    ));
  }

  void _showChangePasswordSheet() {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showAppBottomSheet(
      context: context,
      builder: (context) => AppBottomSheet(
        title: 'Change Password',
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: formKey,
                child: AppTextField(
                  controller: passwordController,
                  label: 'New Password',
                  hint: 'Enter new password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: 'Save Password',
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final success =
                        await ref.read(authProvider.notifier).updateProfile({
                      'password': passwordController.text,
                    });
                    if (mounted) {
                      navigator.pop();
                      messenger.showSnackBar(SnackBar(
                        content: Text(success
                            ? 'Password updated successfully'
                            : 'Failed to update password'),
                        backgroundColor:
                            success ? AppColors.success : AppColors.error,
                      ));
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).user;
    final role = ref.watch(currentProjectRoleProvider);
    final brightness = Theme.of(context).brightness;

    final name = (user?['full_name'] ?? '').toString();
    final email = (user?['email'] ?? '').toString();
    final phone = (user?['phone_number'] ?? '').toString();
    final displayName = name.trim().isEmpty ? email : name;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _toggleEdit,
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ResponsiveContent(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: l10n.profile,
                  subtitle: l10n.profileSubtitle,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    children: [
                      _Avatar(name: displayName),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        displayName,
                        style: AppTextStyles.screenTitle.copyWith(
                          color: brightness == Brightness.dark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        email,
                        style: AppTextStyles.bodyMuted.copyWith(
                          color: AppColors.secondaryTextFor(brightness),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          RoleBadge(
                            label: _roleLabel(role, l10n),
                            color: _roleColor(role),
                          ),
                          RoleBadge(
                            label: l10n.account,
                            color: AppColors.statusDraft,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_circle_outlined,
                            size: 20,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Account Information',
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: brightness == Brightness.dark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _AccountInfoTile(
                        icon: Icons.business_center_outlined,
                        label: 'Account Type',
                        value: 'Standard Account',
                      ),
                      const Divider(height: 1),
                      const _AccountInfoTile(
                        icon: Icons.verified_outlined,
                        label: 'Account Status',
                        value: 'Active',
                        valueColor: AppColors.success,
                      ),
                      const Divider(height: 1),
                      _AccountInfoTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Member Since',
                        value: _formatDate(user?['created_at']),
                      ),
                      const Divider(height: 1),
                      _AccountInfoTile(
                        icon: Icons.update_outlined,
                        label: 'Last Updated',
                        value: _formatDate(user?['updated_at']),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: Column(
                    children: [
                      if (!_isEditing) ...[
                        _InfoTile(
                            icon: Icons.person_outline,
                            label: l10n.fullName,
                            value: name),
                        const Divider(height: 1),
                        _InfoTile(
                            icon: Icons.email_outlined,
                            label: l10n.email,
                            value: email),
                        const Divider(height: 1),
                        _InfoTile(
                          icon: Icons.phone_outlined,
                          label: l10n.phoneNumber,
                          value: phone.isEmpty ? '-' : phone,
                        ),
                        const Divider(height: 1),
                        _InfoTile(
                          icon: Icons.badge_outlined,
                          label: l10n.role,
                          value: _roleLabel(role, l10n),
                        ),
                      ] else ...[
                        AppTextField(
                          controller: _nameController,
                          label: l10n.fullName,
                          hint: l10n.fullName,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _emailController,
                          label: l10n.email,
                          hint: l10n.email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          readOnly: true, // Email is usually unique and not editable easily
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _phoneController,
                          label: l10n.phoneNumber,
                          hint: l10n.phoneNumber,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          text: 'Save Changes',
                          onPressed: _saveProfile,
                          isLoading: _isSaving,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    title: 'Security',
                    subtitle: 'Manage your account security',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: AppButton(
                      text: 'Change Password',
                      icon: Icons.lock_outline_rounded,
                      isOutline: true,
                      onPressed: _showChangePasswordSheet,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
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

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Not available';
    try {
      final date = DateTime.parse(dateString.toString());
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Not available';
    }
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.constructProBlue.withValues(alpha: 0.14),
        borderRadius: AppRadius.doubleExtraLarge,
        border: Border.all(
          color: AppColors.constructProBlue.withValues(alpha: 0.28),
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.heroTitle.copyWith(
            color: AppColors.constructProBlue,
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E40AF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _AccountInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryTextFor(Theme.of(context).brightness)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryTextFor(Theme.of(context).brightness),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodySm.copyWith(
                    color: valueColor ?? (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}