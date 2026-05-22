import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class ContractorForm extends StatefulWidget {
  final String initialName;
  final String submitLabel;
  final IconData submitIcon;
  final bool isLoading;
  final String? error;
  final ValueChanged<String> onSubmit;

  const ContractorForm({
    super.key,
    this.initialName = '',
    required this.submitLabel,
    this.submitIcon = Icons.add_rounded,
    this.isLoading = false,
    this.error,
    required this.onSubmit,
  });

  @override
  State<ContractorForm> createState() => _ContractorFormState();
}

class _ContractorFormState extends State<ContractorForm> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void didUpdateWidget(ContractorForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialName != widget.initialName &&
        _nameController.text != widget.initialName) {
      _nameController.text = widget.initialName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Contractor Name',
            hint: 'Enter contractor name',
            controller: _nameController,
            prefixIcon: Icons.business_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Contractor name is required';
              }
              return null;
            },
          ),
          if (widget.error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.error!,
                      style: AppTextStyles.bodyMuted.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            text: widget.submitLabel,
            icon: widget.submitIcon,
            isLoading: widget.isLoading,
            onPressed: widget.isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
