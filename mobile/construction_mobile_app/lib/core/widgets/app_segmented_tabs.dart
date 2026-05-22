import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppSegmentedTab {
  final String label;
  final IconData? icon;

  const AppSegmentedTab({
    required this.label,
    this.icon,
  });
}

class AppSegmentedTabs extends StatefulWidget {
  final List<AppSegmentedTab> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final Color? accentColor;

  const AppSegmentedTabs({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onSelected,
    this.accentColor,
  });

  @override
  State<AppSegmentedTabs> createState() => _AppSegmentedTabsState();
}

class _AppSegmentedTabsState extends State<AppSegmentedTabs>
    with SingleTickerProviderStateMixin {
  late AnimationController _indicatorController;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _indicatorController.value = 1.0;
  }

  @override
  void didUpdateWidget(AppSegmentedTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _indicatorController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final accent = widget.accentColor ??
        (isDark ? AppColors.accentBlue : AppColors.accentBlueStrong);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightMutedSurface,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        border: Border.all(color: AppColors.borderFor(brightness), width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / widget.tabs.length;

          return Stack(
            children: [
              // Animated sliding indicator
              AnimatedBuilder(
                animation: _indicatorController,
                builder: (context, _) {
                  final animValue = Curves.easeOutCubic.transform(
                    _indicatorController.value,
                  );
                  final fromX = _previousIndex * tabWidth;
                  final toX = widget.selectedIndex * tabWidth;
                  final currentX = fromX + (toX - fromX) * animValue;

                  return Positioned(
                    top: AppSpacing.xs,
                    bottom: AppSpacing.xs,
                    left: currentX + AppSpacing.xs,
                    width: tabWidth - AppSpacing.xs * 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(AppRadius.chip - 2),
                      ),
                    ),
                  );
                },
              ),
              // Tab labels
              Row(
                children: [
                  for (var i = 0; i < widget.tabs.length; i++)
                    Expanded(
                      child: _SegmentedTabTile(
                        tab: widget.tabs[i],
                        isSelected: i == widget.selectedIndex,
                        accentColor: accent,
                        brightness: brightness,
                        onTap: () => widget.onSelected?.call(i),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentedTabTile extends StatelessWidget {
  final AppSegmentedTab tab;
  final bool isSelected;
  final Color accentColor;
  final Brightness brightness;
  final VoidCallback onTap;

  const _SegmentedTabTile({
    required this.tab,
    required this.isSelected,
    required this.accentColor,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isSelected ? Colors.white : AppColors.secondaryTextFor(brightness);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip - 2),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              Icon(tab.icon, size: 16, color: textColor),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              tab.label,
              style: AppTextStyles.label.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
