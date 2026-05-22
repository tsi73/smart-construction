import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/animated_page_section.dart';
import '../../domain/entities/contractor.dart';
import '../controllers/contractor_controller.dart';
import 'contractor_card.dart';
import 'contractor_form.dart';

class ContractorsTab extends ConsumerWidget {
  final bool canManage;

  const ContractorsTab({super.key, this.canManage = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contractorControllerProvider);

    if (state.error != null) {
      return _ContractorError(
        error: state.error!,
        onRetry: () =>
            ref.read(contractorControllerProvider.notifier).loadContractors(),
      );
    }

    if (state.isLoading && state.contractors.isEmpty) {
      return _ContractorLoading();
    }

    if (state.contractors.isEmpty) {
      return EmptyState(
        title: 'No contractors added yet',
        message: 'Add trade partners or companies working on this project.',
        icon: Icons.engineering_rounded,
        action: canManage
            ? SizedBox(
                width: 200,
                child: AppButton(
                  text: '+ Add Contractor',
                  icon: Icons.add_rounded,
                  size: AppButtonSize.small,
                  onPressed: () => _showAddSheet(context, ref),
                ),
              )
            : null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Contractors',
          trailing: canManage
              ? SizedBox(
                  width: 150,
                  child: AppButton(
                    text: 'Add Contractor',
                    icon: Icons.add_rounded,
                    size: AppButtonSize.small,
                    onPressed: () => _showAddSheet(context, ref),
                  ),
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        CardStagger(
          children: [
            for (final contractor in state.contractors)
              ContractorCard(
                name: contractor.name,
                canManage: canManage,
                onEdit: canManage
                    ? () => _showEditSheet(context, ref, contractor)
                    : null,
                onDelete: canManage
                    ? () => _showDeleteSheet(context, ref, contractor)
                    : null,
              ),
          ],
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    bool isLoading = false;
    String? error;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add Contractor', style: AppTextStyles.screenTitle),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Create a contractor record for this project.',
                  style: AppTextStyles.bodyMuted,
                ),
                const SizedBox(height: AppSpacing.xl),
                ContractorForm(
                  submitLabel: 'Create Contractor',
                  submitIcon: Icons.add_rounded,
                  isLoading: isLoading,
                  error: error,
                  onSubmit: (name) async {
                    setModalState(() {
                      isLoading = true;
                      error = null;
                    });
                    final success = await ref
                        .read(contractorControllerProvider.notifier)
                        .createContractor(name);
                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contractor created'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        final ctrlError =
                            ref.read(contractorControllerProvider).error;
                        setModalState(() {
                          isLoading = false;
                          error = ctrlError ?? 'Failed to create contractor';
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditSheet(
      BuildContext context, WidgetRef ref, Contractor contractor) {
    bool isLoading = false;
    String? error;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Edit Contractor', style: AppTextStyles.screenTitle),
                const SizedBox(height: AppSpacing.xl),
                ContractorForm(
                  initialName: contractor.name,
                  submitLabel: 'Save',
                  submitIcon: Icons.check_rounded,
                  isLoading: isLoading,
                  error: error,
                  onSubmit: (name) async {
                    setModalState(() {
                      isLoading = true;
                      error = null;
                    });
                    final success = await ref
                        .read(contractorControllerProvider.notifier)
                        .updateContractor(contractor.id, name);
                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contractor updated'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        final ctrlError =
                            ref.read(contractorControllerProvider).error;
                        setModalState(() {
                          isLoading = false;
                          error = ctrlError ?? 'Failed to update contractor';
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteSheet(
      BuildContext context, WidgetRef ref, Contractor contractor) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Delete Contractor', style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Are you sure you want to delete "${contractor.name}"? This action cannot be undone.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: 'Delete',
              isDanger: true,
              onPressed: () async {
                final success = await ref
                    .read(contractorControllerProvider.notifier)
                    .deleteContractor(contractor.id);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contractor deleted'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractorLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LoadingSkeleton(
            width: double.infinity, height: 90, borderRadius: 16),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < 3; i++) ...[
          const LoadingSkeleton(
              width: double.infinity, height: 80, borderRadius: 16),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _ContractorError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ContractorError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 48),
            const SizedBox(height: AppSpacing.lg),
            Text('Failed to load contractors',
                style: AppTextStyles.sectionTitle),
            const SizedBox(height: AppSpacing.sm),
            Text(error,
                style: AppTextStyles.bodyMuted, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: 'Retry',
              size: AppButtonSize.medium,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
