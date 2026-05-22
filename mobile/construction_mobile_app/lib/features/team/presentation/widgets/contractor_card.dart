import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

class ContractorCard extends StatelessWidget {
  final String name;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canManage;

  const ContractorCard({
    super.key,
    required this.name,
    this.onEdit,
    this.onDelete,
    this.canManage = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
            child: const Center(
              child: Icon(
                Icons.business_rounded,
                color: AppColors.constructProBlue,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Unnamed Contractor',
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
                  'Trade partner',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.mutedTextFor(brightness),
                  ),
                ),
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
                if (value == 'edit') onEdit?.call();
                if (value == 'delete') onDelete?.call();
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit name'),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
