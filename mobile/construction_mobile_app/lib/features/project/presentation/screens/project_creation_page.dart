import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/ethiopia_formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/project_controller.dart';
import '../providers/project_provider.dart';

class ProjectCreationPage extends ConsumerStatefulWidget {
  const ProjectCreationPage({super.key});

  @override
  ConsumerState<ProjectCreationPage> createState() =>
      _ProjectCreationPageState();
}

class _ProjectCreationPageState extends ConsumerState<ProjectCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int _step = 0;

  Map<String, String>? _selectedClient;
  bool _isAddingNewClient = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final initialDate =
        isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final scheme = isDark
            ? const ColorScheme.dark(
                primary: AppColors.accentBlue,
                onPrimary: Colors.white,
                surface: AppColors.darkCard,
                onSurface: AppColors.darkTextPrimary,
              )
            : const ColorScheme.light(
                primary: AppColors.accentBlueStrong,
                onPrimary: Colors.white,
                surface: AppColors.lightCard,
                onSurface: AppColors.lightTextPrimary,
              );
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: scheme),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final formatted = DateFormat('yyyy-MM-dd').format(picked);
        if (isStart) {
          _startDate = picked;
          _startDateController.text = formatted;
        } else {
          _endDate = picked;
          _endDateController.text = formatted;
        }
      });
    }
  }

  void _nextStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_datesAreValid()) return;
    setState(() => _step = 1);
  }

  bool _datesAreValid() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end dates'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_datesAreValid()) return;

    final l10n = AppLocalizations.of(context)!;
    final success =
        await ref.read(projectControllerProvider.notifier).createProject(
              name: _nameController.text.trim(),
              totalBudget: double.tryParse(_budgetController.text.trim()) ?? 0,
              clientName: _clientNameController.text.trim(),
              clientEmail: _clientEmailController.text.trim(),
              description: _descriptionController.text.trim(),
              location: _locationController.text.trim(),
              startDate: _startDate,
              endDate: _endDate,
            );

    if (mounted && success != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invitationSentSuccess),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(projectControllerProvider);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(l10n.createProject),
        backgroundColor: background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isWide ? 760 : double.infinity),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                isWide ? AppSpacing.xxl : AppSpacing.lg,
                AppSpacing.lg,
                isWide ? AppSpacing.xxl : AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WizardHeader(step: _step),
                    const SizedBox(height: AppSpacing.lg),
                    _FormCard(
                      title: _step == 0 ? 'Project Details' : 'Client',
                      subtitle: _step == 0
                          ? 'Set the project scope, value, location, and schedule.'
                          : 'Add the client contact details for this project.',
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _step == 0 ? _detailsStep(l10n) : _clientStep(),
                      ),
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _InlineMessage(message: state.error!),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    if (_step == 0) ...[
                      AppButton(
                        text: 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _nextStep,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        text: 'Cancel',
                        isOutline: true,
                        onPressed: () => context.pop(),
                      ),
                    ] else ...[
                      AppButton(
                        text: 'Review + Create Project',
                        icon: Icons.check_rounded,
                        isLoading: state.isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        text: 'Back',
                        isOutline: true,
                        icon: Icons.arrow_back_rounded,
                        onPressed: state.isLoading
                            ? null
                            : () => setState(() => _step = 0),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailsStep(AppLocalizations l10n) {
    final brightness = Theme.of(context).brightness;

    return Column(
      key: const ValueKey('details'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.projectName,
          controller: _nameController,
          hint: 'e.g. Bole Road Rehabilitation',
          prefixIcon: Icons.business_rounded,
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Description',
          controller: _descriptionController,
          hint: 'Brief project summary',
          prefixIcon: Icons.notes_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: l10n.projectLocation,
          controller: _locationController,
          hint: 'e.g. Addis Ababa',
          prefixIcon: Icons.location_on_outlined,
          suffixIcon: PopupMenuButton<String>(
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.secondaryTextFor(brightness),
            ),
            onSelected: (val) => _locationController.text = val,
            itemBuilder: (context) => EthiopiaFormatters.majorCities
                .map((city) => PopupMenuItem(value: city, child: Text(city)))
                .toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Total Budget / Contract Value',
          controller: _budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          hint: '0.00',
          prefixIcon: Icons.payments_outlined,
          onChanged: (_) => setState(() {}),
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'ETB',
              style: AppTextStyles.label.copyWith(
                color: AppColors.secondaryTextFor(brightness),
              ),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (double.tryParse(v.trim()) == null) return 'Invalid number';
            return null;
          },
        ),
        if (double.tryParse(_budgetController.text.trim()) != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            EthiopiaFormatters.formatCurrencyCompact(
              double.tryParse(_budgetController.text.trim()) ?? 0,
            ),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 560;
            final fields = [
              AppTextField(
                label: l10n.startDate,
                readOnly: true,
                onTap: () => _selectDate(context, true),
                controller: _startDateController,
                hint: 'YYYY-MM-DD',
                prefixIcon: Icons.calendar_today_rounded,
              ),
              AppTextField(
                label: l10n.endDate,
                readOnly: true,
                onTap: () => _selectDate(context, false),
                controller: _endDateController,
                hint: 'YYYY-MM-DD',
                prefixIcon: Icons.event_available_rounded,
              ),
            ];
            if (stacked) {
              return Column(
                children: [
                  fields[0],
                  const SizedBox(height: AppSpacing.lg),
                  fields[1],
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: fields[0]),
                const SizedBox(width: AppSpacing.lg),
                Expanded(child: fields[1]),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _clientStep() {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final clientsAsync = ref.watch(clientsProvider);

    return clientsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) =>
          _InlineMessage(message: 'Failed to load clients: $err'),
      data: (clients) {
        return Column(
          key: const ValueKey('client'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Client Selection',
                prefixIcon: const Icon(Icons.person_search_rounded),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.medium,
                  borderSide:
                      BorderSide(color: AppColors.borderFor(brightness)),
                ),
              ),
              value: _isAddingNewClient ? 'new' : _selectedClient?['name'],
              items: [
                DropdownMenuItem(
                  value: 'new',
                  child: Text(
                    '+ Add New Client',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...clients.map((c) => DropdownMenuItem(
                      value: c['name'],
                      child: Text(c['name']!, style: AppTextStyles.bodyMd),
                    )),
              ],
              onChanged: (val) {
                setState(() {
                  if (val == 'new' || val == null) {
                    _isAddingNewClient = true;
                    _selectedClient = null;
                    _clientNameController.clear();
                    _clientEmailController.clear();
                  } else {
                    _isAddingNewClient = false;
                    final client = clients.firstWhere((c) => c['name'] == val);
                    _selectedClient = client;
                    _clientNameController.text = client['name']!;
                    _clientEmailController.text = client['email']!;
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_isAddingNewClient) ...[
              AppTextField(
                label: 'Client Name',
                controller: _clientNameController,
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Client Email',
                controller: _clientEmailController,
                keyboardType: TextInputType.emailAddress,
                hint: 'client@example.com',
                prefixIcon: Icons.alternate_email_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
            ] else if (_selectedClient != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightMutedSurface,
                  borderRadius: AppRadius.medium,
                  border: Border.all(color: AppColors.borderFor(brightness)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.accentBlue, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Selected Client',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _selectedClient!['name']!,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _selectedClient!['email']!,
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            _ReviewBlock(
              name: _nameController.text.trim(),
              location: _locationController.text.trim(),
              budget: double.tryParse(_budgetController.text.trim()),
              brightness: brightness,
            ),
          ],
        );
      },
    );
  }
}

class _WizardHeader extends StatelessWidget {
  final int step;

  const _WizardHeader({required this.step});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.doubleExtraLarge,
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Row(
        children: [
          _StepPill(
              number: 1,
              label: 'Project Details',
              active: step == 0,
              done: step > 0),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              color: step > 0
                  ? AppColors.accentBlue
                  : AppColors.borderFor(brightness),
            ),
          ),
          _StepPill(number: 2, label: 'Client', active: step == 1, done: false),
        ],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final int number;
  final String label;
  final bool active;
  final bool done;

  const _StepPill({
    required this.number,
    required this.label,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = active || done
        ? AppColors.accentBlue
        : AppColors.mutedTextFor(brightness);

    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: active || done ? 0.16 : 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: done
                  ? Icon(Icons.check_rounded, color: color, size: 16)
                  : Text(
                      '$number',
                      style: AppTextStyles.label.copyWith(color: color),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(color: color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _FormCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.doubleExtraLarge,
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.bodyMuted.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}

class _ReviewBlock extends StatelessWidget {
  final String name;
  final String location;
  final double? budget;
  final Brightness brightness;

  const _ReviewBlock({
    required this.name,
    required this.location,
    required this.budget,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _ReviewRow(
          label: 'Project', value: name.isEmpty ? 'Unnamed Project' : name),
      if (location.isNotEmpty) _ReviewRow(label: 'Location', value: location),
      if (budget != null)
        _ReviewRow(
          label: 'Contract Value',
          value: EthiopiaFormatters.formatCurrencyCompact(budget!),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lightMutedSurface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.borderFor(brightness)),
      ),
      child: Column(children: rows),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryTextFor(brightness),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.label.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  final String message;

  const _InlineMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodyMd.copyWith(color: const Color(0xFFF87171)),
      ),
    );
  }
}
