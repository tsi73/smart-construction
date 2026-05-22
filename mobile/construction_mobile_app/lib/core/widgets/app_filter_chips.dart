import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppFilterChip {
  final String label;
  final IconData? icon;
  final String? value;

  const AppFilterChip({
    required this.label,
    this.icon,
    this.value,
  });
}

class AppFilterChips extends StatelessWidget {
  final List<AppFilterChip> chips;
  final String? selectedValue;
  final ValueChanged<String?>? onSelected;
  final bool allowDeselect;
  final ScrollController? controller;

  const AppFilterChips({
    super.key,
    required this.chips,
    this.selectedValue,
    this.onSelected,
    this.allowDeselect = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        // No visible scrollbar
        itemBuilder: (context, index) {
          final chip = chips[index];
          final chipValue = chip.value ?? chip.label;
          final isSelected = chipValue == selectedValue;

          return _AppFilterChipTile(
            chip: chip,
            isSelected: isSelected,
            isDark: isDark,
            brightness: brightness,
            onTap: () {
              if (isSelected && allowDeselect) {
                onSelected?.call(null);
              } else if (!isSelected) {
                onSelected?.call(chipValue);
              }
            },
          );
        },
      ),
    );
  }
}

class _AppFilterChipTile extends StatelessWidget {
  final AppFilterChip chip;
  final bool isSelected;
  final bool isDark;
  final Brightness brightness;
  final VoidCallback onTap;

  const _AppFilterChipTile({
    required this.chip,
    required this.isSelected,
    required this.isDark,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isDark ? AppColors.accentBlue : AppColors.accentBlueStrong;

    final bgColor = isSelected
        ? accentColor.withValues(alpha: 0.12)
        : (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final borderColor = isSelected
        ? accentColor.withValues(alpha: 0.32)
        : AppColors.borderFor(brightness);
    final textColor =
        isSelected ? accentColor : AppColors.secondaryTextFor(brightness);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chip.icon != null) ...[
              Icon(chip.icon, size: 16, color: textColor),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              chip.label,
              style: AppTextStyles.label.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
