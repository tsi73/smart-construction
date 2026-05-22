import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/role_badge.dart';

class MemberCard extends StatelessWidget {
  final String name;
  final String email;
  final String? phoneNumber;
  final String roleLabel;
  final Color roleColor;
  final String changeRoleLabel;
  final String removeMemberLabel;
  final VoidCallback? onEditRole;
  final VoidCallback? onRemove;
  final bool canManage;

  const MemberCard({
    super.key,
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.roleColor,
    required this.changeRoleLabel,
    required this.removeMemberLabel,
    this.phoneNumber,
    this.onEditRole,
    this.onRemove,
    this.canManage = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: name),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
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
                if (phoneNumber != null && phoneNumber!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    phoneNumber!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mutedTextFor(brightness),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                RoleBadge(label: roleLabel, color: roleColor),
              ],
            ),
          ),
          if (canManage)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppColors.mutedTextFor(brightness),
              ),
              onSelected: (value) {
                if (value == 'edit') onEditRole?.call();
                if (value == 'remove') onRemove?.call();
              },
              itemBuilder: (context) => [
                if (onEditRole != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(changeRoleLabel),
                  ),
                if (onRemove != null)
                  PopupMenuItem(
                    value: 'remove',
                    child: Text(removeMemberLabel),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.constructProBlue.withValues(alpha: 0.14),
        borderRadius: AppRadius.large,
        border: Border.all(
            color: AppColors.constructProBlue.withValues(alpha: 0.28)),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: AppTextStyles.label.copyWith(
            color: AppColors.constructProBlue,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
