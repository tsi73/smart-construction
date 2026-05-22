import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../team/presentation/controllers/contractor_controller.dart';
import '../../../team/presentation/widgets/contractor_form.dart';

class ContractorCreationPage extends ConsumerStatefulWidget {
  const ContractorCreationPage({super.key});

  @override
  ConsumerState<ContractorCreationPage> createState() =>
      _ContractorCreationPageState();
}

class _ContractorCreationPageState
    extends ConsumerState<ContractorCreationPage> {
  bool _isSaving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('Contractors')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ResponsiveContent(
            maxWidth: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Add Contractor',
                  subtitle: 'Create a contractor record for this project.',
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.constructProBlue
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.constructProBlue
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.engineering_rounded,
                              color: AppColors.constructProBlue,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Add the company or trade partner name used by the project team.',
                                style: AppTextStyles.bodyMuted.copyWith(
                                  color:
                                      AppColors.secondaryTextFor(brightness),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ContractorForm(
                        submitLabel: 'Create Contractor',
                        submitIcon: Icons.add_rounded,
                        isLoading: _isSaving,
                        error: _error,
                        onSubmit: (name) async {
                          setState(() {
                            _isSaving = true;
                            _error = null;
                          });
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final success = await ref
                              .read(contractorControllerProvider.notifier)
                              .createContractor(name);
                          if (mounted) {
                            setState(() => _isSaving = false);
                            if (success) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Contractor created'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              navigator.maybePop();
                            } else {
                              final ctrlError = ref
                                  .read(contractorControllerProvider)
                                  .error;
                              setState(() {
                                _error =
                                    ctrlError ?? 'Failed to create contractor';
                              });
                            }
                          }
                        },
                      ),
                    ],
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
