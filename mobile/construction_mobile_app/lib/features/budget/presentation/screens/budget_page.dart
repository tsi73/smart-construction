import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../core/theme/app_radius.dart';

import '../../../../core/theme/app_spacing.dart';

import '../../../../core/theme/app_text_styles.dart';

import '../../../../core/utils/ethiopia_formatters.dart';

import '../../../../core/widgets/app_button.dart';

import '../../../../core/widgets/app_card.dart';

import '../../../../core/widgets/app_segmented_tabs.dart';

import '../../../../core/widgets/responsive_content.dart';

import '../../../../core/widgets/section_header.dart';

import '../../../project/presentation/providers/project_provider.dart';

import '../controllers/budget_controller.dart';



class BudgetPage extends ConsumerStatefulWidget {

  const BudgetPage({super.key});



  @override

  ConsumerState<BudgetPage> createState() => _BudgetPageState();

}



class _BudgetPageState extends ConsumerState<BudgetPage> {

  int _selectedTab = 0;



  static const _tabs = [

    AppSegmentedTab(label: 'Overview', icon: Icons.dashboard_outlined),

    AppSegmentedTab(label: 'Breakdown', icon: Icons.pie_chart_outline_rounded),

    AppSegmentedTab(label: 'Expenses', icon: Icons.receipt_long_rounded),

  ];



  @override

  Widget build(BuildContext context) {

    final project = ref.watch(currentProjectProvider);

    final projectId = (project?['id'] ?? '').toString();

    final role = ref.watch(currentProjectRoleProvider);

    final summaryAsync = ref.watch(budgetSummaryProvider(projectId));

    final itemsAsync = ref.watch(budgetItemsProvider(projectId));

    final brightness = Theme.of(context).brightness;

    final isDark = brightness == Brightness.dark;



    final canAddExpense = role == 'project_manager' ||
        role == 'owner';



    // Show FAB only on Expenses tab (index 2) and only if role allows

    final showFab = _selectedTab == 2 && canAddExpense;



    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,

      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => _showAddExpenseSheet(context, ref, projectId),

              backgroundColor: AppColors.accentBlueStrong,

              child: const Icon(Icons.add_rounded, color: Colors.white),

            )

          : null,

      body: ResponsiveContent(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),

          children: [
            // Header

            SectionHeader(
              title: 'Budget',

              subtitle: 'Track project budget, expenses, and utilization.',

              trailing: summaryAsync.when(
                data: (data) {
                  final spent =
                      (data['budget_spent'] as num?)?.toDouble() ?? 0;

                  final total =
                      (data['total_budget'] as num?)?.toDouble() ?? 1;

                  final pct = total > 0 ? (spent / total * 100).round() : 0;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,

                      vertical: AppSpacing.sm,

                    ),

                    decoration: BoxDecoration(
                      color: _healthColor(spent, total)
                          .withValues(alpha: 0.12),

                      borderRadius: AppRadius.medium,

                      border: Border.all(
                        color: _healthColor(spent, total)
                            .withValues(alpha: 0.28),

                      ),

                    ),

                    child: Text(
                      '$pct% used',

                      style: AppTextStyles.label.copyWith(
                        color: _healthColor(spent, total),

                      ),

                    ),

                  );

                },

                loading: () => const SizedBox.shrink(),

                error: (_, __) => const SizedBox.shrink(),

              ),

            ),

            const SizedBox(height: AppSpacing.md),

            // Segmented Tabs

            AppSegmentedTabs(
              tabs: _tabs,

              selectedIndex: _selectedTab,

              onSelected: (index) => setState(() => _selectedTab = index),

            ),

            const SizedBox(height: AppSpacing.lg),

            // Tab content with animated switcher

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),

              child: KeyedSubtree(
                key: ValueKey(_selectedTab),

                child: _buildTabContent(
                  context: context,

                  tabIndex: _selectedTab,

                  projectId: projectId,

                  summaryAsync: summaryAsync,

                  itemsAsync: itemsAsync,

                  canAddExpense: canAddExpense,

                  isDark: isDark,

                  brightness: brightness,

                ),

              ),

            ),

            // Bottom padding for FAB

            const SizedBox(height: 80),

          ],

        ),

      ),

    );

  }



  Widget _buildTabContent({
    required BuildContext context,

    required int tabIndex,

    required String projectId,

    required AsyncValue<Map<String, dynamic>> summaryAsync,

    required AsyncValue<List<Map<String, dynamic>>> itemsAsync,

    required bool canAddExpense,

    required bool isDark,

    required Brightness brightness,

  }) {
    switch (tabIndex) {
      case 0:
        return _OverviewTab(
          summaryAsync: summaryAsync,

          itemsAsync: itemsAsync,

          projectId: projectId,

          isDark: isDark,

          brightness: brightness,

        );

      case 1:
        return _BreakdownTab(isDark: isDark, brightness: brightness);

      case 2:
        return _ExpensesTab(
          itemsAsync: itemsAsync,

          projectId: projectId,

          canAddExpense: canAddExpense,

          isDark: isDark,

          brightness: brightness,

          onAddExpense: () =>
              _showAddExpenseSheet(context, ref, projectId),

        );

      default:
        return const SizedBox.shrink();

    }

  }



  Color _healthColor(double spent, double total) {
    if (total <= 0) return AppColors.success;

    if (spent > total) return AppColors.error;

    final ratio = spent / total;

    if (ratio >= 0.8) return AppColors.warning;

    return AppColors.success;

  }





  void _showAddExpenseSheet(
      BuildContext context, WidgetRef ref, String projectId) {
    final amountController = TextEditingController();

    final descriptionController = TextEditingController();

    final formKey = GlobalKey<FormState>();



    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      showDragHandle: true,

      backgroundColor: AppColors.cardFor(Theme.of(context).brightness),

      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,

            0,

            AppSpacing.lg,

            MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,

          ),

          child: Form(
            key: formKey,

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                Text(
                  'Add Expense',

                  style: AppTextStyles.cardTitle.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,

                  ),

                ),

                const SizedBox(height: AppSpacing.lg),

                TextFormField(
                  controller: amountController,

                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),

                  decoration: const InputDecoration(
                    labelText: 'Amount (ETB)',

                    border: OutlineInputBorder(),

                  ),

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Required';

                    }

                    final val = double.tryParse(v);

                    if (val == null || val <= 0) {
                      return 'Must be greater than 0';

                    }

                    return null;

                  },

                ),

                const SizedBox(height: AppSpacing.md),

                TextFormField(
                  controller: descriptionController,

                  maxLength: 200,

                  decoration: const InputDecoration(
                    labelText: 'Description',

                    border: OutlineInputBorder(),

                  ),

                ),

                const SizedBox(height: AppSpacing.lg),

                AppButton(
                  text: 'Add Expense',

                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final amount = double.parse(amountController.text);

                    final description = descriptionController.text.trim();



                    await ref
                        .read(budgetControllerProvider.notifier)
                        .addItem(
                            projectId,
                            amount,
                            description.isEmpty ? null : description);



                    if (context.mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense recorded')),

                      );

                    }

                  },

                ),

              ],

            ),

          ),

        );

      },

    );

  }

}



// ─── Overview Tab ──────────────────────────────────────────────────────────



class _OverviewTab extends ConsumerWidget {
  final AsyncValue<Map<String, dynamic>> summaryAsync;

  final AsyncValue<List<Map<String, dynamic>>> itemsAsync;

  final String projectId;

  final bool isDark;

  final Brightness brightness;



  const _OverviewTab({
    required this.summaryAsync,

    required this.itemsAsync,

    required this.projectId,

    required this.isDark,

    required this.brightness,

  });



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // Budget Summary Card

        summaryAsync.when(
          loading: () => AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Budget Summary',

                  style: AppTextStyles.cardTitle.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,

                  ),

                ),

                const SizedBox(height: AppSpacing.lg),

                const Center(child: CircularProgressIndicator()),

              ],

            ),

          ),

          error: (e, _) => AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 40, color: AppColors.error),

                const SizedBox(height: AppSpacing.md),

                Text('Failed to load budget summary',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.error)),

                const SizedBox(height: AppSpacing.md),

                AppButton(
                  text: 'Retry',

                  isOutline: true,

                  size: AppButtonSize.medium,

                  onPressed: () =>
                      ref.invalidate(budgetSummaryProvider(projectId)),

                ),

              ],

            ),

          ),

          data: (data) {
            final totalBudget =
                (data['total_budget'] as num?)?.toDouble() ?? 0;

            final budgetSpent =
                (data['budget_spent'] as num?)?.toDouble() ?? 0;

            final totalReceived =
                (data['total_received'] as num?)?.toDouble() ?? 0;

            final remaining = (data['remaining'] as num?)?.toDouble() ??
                (totalBudget - budgetSpent);

            final utilization = totalBudget > 0
                ? (budgetSpent / totalBudget).clamp(0.0, 1.0)
                : 0.0;

            final utilizationPct = (utilization * 100).round();



            final healthColor = _healthColor(budgetSpent, totalBudget);

            final healthLabel = _healthLabel(budgetSpent, totalBudget);



            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Text(
                        'Budget Summary',

                        style: AppTextStyles.cardTitle.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,

                        ),

                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,

                          vertical: AppSpacing.xs,

                        ),

                        decoration: BoxDecoration(
                          color: healthColor.withValues(alpha: 0.12),

                          borderRadius: AppRadius.small,

                          border: Border.all(
                            color: healthColor.withValues(alpha: 0.28),

                          ),

                        ),

                        child: Text(
                          healthLabel,

                          style: AppTextStyles.badge.copyWith(
                            color: healthColor,

                          ),

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: AppSpacing.lg),

                  _BudgetRow(
                    label: 'Total Budget',

                    value: EthiopiaFormatters.formatCurrency(totalBudget),

                    isDark: isDark,

                  ),

                  const SizedBox(height: AppSpacing.md),

                  _BudgetRow(
                    label: 'Total Spent',

                    value: EthiopiaFormatters.formatCurrency(budgetSpent),

                    valueColor: healthColor,

                    isDark: isDark,

                  ),

                  const SizedBox(height: AppSpacing.md),

                  _BudgetRow(
                    label: 'Received',

                    value: EthiopiaFormatters.formatCurrency(totalReceived),

                    isDark: isDark,

                  ),

                  const SizedBox(height: AppSpacing.md),

                  _BudgetRow(
                    label: 'Remaining',

                    value: EthiopiaFormatters.formatCurrency(remaining),

                    isBold: true,

                    isDark: isDark,

                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    children: [
                      Text(
                        'Budget Utilization: $utilizationPct%',

                        style: AppTextStyles.label.copyWith(
                          color: AppColors.secondaryTextFor(brightness),

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: AppSpacing.sm),

                  ClipRRect(
                    borderRadius: AppRadius.medium,

                    child: LinearProgressIndicator(
                      value: utilization,

                      minHeight: 8,

                      backgroundColor: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,

                      valueColor: AlwaysStoppedAnimation<Color>(healthColor),

                    ),

                  ),

                ],

              ),

            );

          },

        ),
      ],
    );

  }



  Color _healthColor(double spent, double total) {
    if (total <= 0) return AppColors.success;

    if (spent > total) return AppColors.error;

    final ratio = spent / total;

    if (ratio >= 0.8) return AppColors.warning;

    return AppColors.success;

  }



  String _healthLabel(double spent, double total) {
    if (total <= 0) return 'Healthy';

    if (spent > total) return 'Over Budget';

    final ratio = spent / total;

    if (ratio >= 0.8) return 'Watch';

    return 'Healthy';

  }

}



// ─── Budget Row ────────────────────────────────────────────────────────────



class _BudgetRow extends StatelessWidget {

  final String label;

  final String value;

  final Color? valueColor;

  final bool isBold;

  final bool isDark;



  const _BudgetRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
    required this.isDark,
  });



  @override

  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          label,

          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.secondaryTextFor(
                Theme.of(context).brightness),
          ),

        ),

        Text(
          value,

          style: AppTextStyles.bodyMd.copyWith(
            color: valueColor ??
                (isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,

          ),

        ),

      ],

    );

  }

}



// ─── Breakdown Tab ──────────────────────────────────────────────────────────



class _BreakdownTab extends StatelessWidget {

  final bool isDark;

  final Brightness brightness;



  const _BreakdownTab({
    required this.isDark,
    required this.brightness,
  });



  @override

  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Budget Breakdown',

            style: AppTextStyles.cardTitle.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,

            ),

          ),

          const SizedBox(height: AppSpacing.lg),

          Center(
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart_outline_rounded,

                  size: 64,

                  color: AppColors.secondaryTextFor(brightness),

                ),

                const SizedBox(height: AppSpacing.md),

                Text(
                  'Budget breakdown visualization',

                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.secondaryTextFor(brightness),

                  ),

                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Coming soon',

                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryTextFor(brightness),

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



// ─── Expenses Tab ───────────────────────────────────────────────────────────



class _ExpensesTab extends StatelessWidget {

  final AsyncValue<List<Map<String, dynamic>>> itemsAsync;

  final String projectId;

  final bool canAddExpense;

  final bool isDark;

  final Brightness brightness;

  final VoidCallback onAddExpense;



  const _ExpensesTab({
    required this.itemsAsync,
    required this.projectId,
    required this.canAddExpense,
    required this.isDark,
    required this.brightness,
    required this.onAddExpense,
  });



  @override

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        AppCard(
          child: itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),

            error: (e, _) => Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.error),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Failed to load expenses',

                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.error,

                    ),

                  ),

                ],

              ),

            ),

            data: (items) {
              if (items.isEmpty) {
                return Column(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,

                      size: 48,

                      color: AppColors.secondaryTextFor(brightness),

                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'No expenses recorded yet',

                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.secondaryTextFor(brightness),

                      ),

                    ),

                    if (canAddExpense) ...[
                      const SizedBox(height: AppSpacing.lg),

                      AppButton(
                        text: 'Add First Expense',

                        onPressed: onAddExpense,

                      ),

                    ],

                  ],

                );

              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'Expenses',

                    style: AppTextStyles.cardTitle.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,

                    ),

                  ),

                  const SizedBox(height: AppSpacing.lg),

                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),

                        child: _ExpenseItem(
                          amount: (item['amount'] as num?)?.toDouble() ?? 0,

                          description: item['description'] as String? ?? 'No description',

                          isDark: isDark,

                        ),

                      )),

                ],

              );

            },

          ),

        ),
      ],

    );

  }

}



class _ExpenseItem extends StatelessWidget {

  final double amount;

  final String description;

  final bool isDark;



  const _ExpenseItem({
    required this.amount,
    required this.description,
    required this.isDark,
  });



  @override

  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),

      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,

        borderRadius: AppRadius.medium,

        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,

        ),

      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Expanded(
            child: Text(
              description,

              style: AppTextStyles.bodyMd.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,

              ),

            ),

          ),

          Text(
            EthiopiaFormatters.formatCurrency(amount),

            style: AppTextStyles.bodyMd.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,

              fontWeight: FontWeight.w600,

            ),

          ),

        ],

      ),

    );

  }

}
