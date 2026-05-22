import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/ethiopia_formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/role_guard.dart';
import '../../../../core/network/dio_client.dart' show dioProvider;
import '../../domain/entities/daily_log.dart';
import '../controllers/daily_log_controller.dart'
    show dailyLogControllerProvider, projectLogsProvider;
import '../../data/datasources/daily_log_remote_data_source.dart';

class DailyLogWizardPage extends ConsumerStatefulWidget {
  final String projectId;
  final String? taskId;

  const DailyLogWizardPage({super.key, required this.projectId, this.taskId});

  @override
  ConsumerState<DailyLogWizardPage> createState() => _DailyLogWizardPageState();
}

class _DailyLogWizardPageState extends ConsumerState<DailyLogWizardPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final ImagePicker _imagePicker = ImagePicker();

  // Step 1: Basic Info
  DateTime _selectedDate = DateTime.now();
  final _notesController = TextEditingController();
  final _reportNumberController = TextEditingController();
  String _weatherCondition = 'Fine';
  double _weatherLostHours = 0.0;
  double _taskProgressPercent = 0.0;

  // Step 2: Shifts
  final List<LogShift> _shifts = [const LogShift(shiftType: 'Day')];

  // Step 3: Labor
  final List<LogLabor> _labor = [];

  // Step 4: Materials
  final List<LogMaterial> _materials = [];

  // Step 5: Equipment
  final List<LogEquipment> _equipment = [];

  // Step 6: Photos
  final List<XFile> _selectedImages = [];
  final List<String> _imageCaptions = [];
  final List<String> _selectedPdfs = [];
  bool _isUploadingImages = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    _reportNumberController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final l10n = AppLocalizations.of(context)!;

    // Validate current step before proceeding
    String? stepError;
    switch (_currentStep) {
      case 0: // Basic Info
        if (_notesController.text.trim().isEmpty) {
          stepError = l10n.validationErrorStepNotes;
        }
        break;
      case 1: // Shifts
        if (_shifts.isEmpty) {
          stepError = l10n.validationErrorStepShift;
        }
        break;
      case 2: // Labor
        for (int i = 0; i < _labor.length; i++) {
          final labor = _labor[i];
          if (labor.workerType.trim().isEmpty) {
            stepError = l10n.validationErrorLaborType(i + 1);
            break;
          }
          if (labor.hoursWorked <= 0) {
            stepError = l10n.validationErrorLaborHours(i + 1);
            break;
          }
          if (labor.cost < 0) {
            stepError = l10n.validationErrorLaborCost(i + 1);
            break;
          }
        }
        break;
      case 3: // Materials
        for (int i = 0; i < _materials.length; i++) {
          final material = _materials[i];
          if (material.name.trim().isEmpty) {
            stepError = l10n.validationErrorMaterialName(i + 1);
            break;
          }
          if (material.quantity <= 0) {
            stepError = l10n.validationErrorMaterialQuantity(i + 1);
            break;
          }
          if (material.unit.trim().isEmpty) {
            stepError = l10n.validationErrorMaterialUnit(i + 1);
            break;
          }
          if (material.cost < 0) {
            stepError = l10n.validationErrorMaterialCost(i + 1);
            break;
          }
        }
        break;
      case 4: // Equipment
        for (int i = 0; i < _equipment.length; i++) {
          final equipment = _equipment[i];
          if (equipment.name.trim().isEmpty) {
            stepError = l10n.validationErrorEquipmentName(i + 1);
            break;
          }
          if (equipment.hoursUsed <= 0) {
            stepError = l10n.validationErrorEquipmentHours(i + 1);
            break;
          }
          if (equipment.cost < 0) {
            stepError = l10n.validationErrorEquipmentCost(i + 1);
            break;
          }
        }
        break;
      case 5: // Photos - no validation required
      case 6: // Review - no validation required
        break;
    }

    if (stepError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(stepError),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (_currentStep < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  String get _weatherText => '$_weatherCondition – Lost: ${_weatherLostHours}h';

  String get _notesText {
    final reportNumber = _reportNumberController.text.trim();
    final notes = _notesController.text.trim();
    if (reportNumber.isNotEmpty) {
      return 'Report #$reportNumber\n$notes';
    }
    return notes;
  }

  String? _validateDailyLog({bool requireSubmission = false}) {
    final l10n = AppLocalizations.of(context)!;

    // Validate basic info
    if (_notesController.text.trim().isEmpty) {
      return l10n.validationError;
    }

    // For submission, validate additional required fields
    if (requireSubmission) {
      // Validate shifts (at least one shift should be present)
      if (_shifts.isEmpty) {
        return l10n.validationErrorShift;
      }

      // Validate labor entries (if any added)
      for (int i = 0; i < _labor.length; i++) {
        final labor = _labor[i];
        if (labor.workerType.trim().isEmpty) {
          return l10n.validationErrorLaborType(i + 1);
        }
        if (labor.hoursWorked <= 0) {
          return l10n.validationErrorLaborHours(i + 1);
        }
        if (labor.cost < 0) {
          return l10n.validationErrorLaborCost(i + 1);
        }
      }

      // Validate material entries (if any added)
      for (int i = 0; i < _materials.length; i++) {
        final material = _materials[i];
        if (material.name.trim().isEmpty) {
          return l10n.validationErrorMaterialName(i + 1);
        }
        if (material.quantity <= 0) {
          return l10n.validationErrorMaterialQuantity(i + 1);
        }
        if (material.unit.trim().isEmpty) {
          return l10n.validationErrorMaterialUnit(i + 1);
        }
        if (material.cost < 0) {
          return l10n.validationErrorMaterialCost(i + 1);
        }
      }

      // Validate equipment entries (if any added)
      for (int i = 0; i < _equipment.length; i++) {
        final equipment = _equipment[i];
        if (equipment.name.trim().isEmpty) {
          return l10n.validationErrorEquipmentName(i + 1);
        }
        if (equipment.hoursUsed <= 0) {
          return l10n.validationErrorEquipmentHours(i + 1);
        }
        if (equipment.cost < 0) {
          return l10n.validationErrorEquipmentCost(i + 1);
        }
      }

      // Validate shift entries
      for (int i = 0; i < _shifts.length; i++) {
        final shift = _shifts[i];
        if (shift.shiftType.trim().isEmpty) {
          return l10n.validationErrorShiftType(i + 1);
        }
      }
    }

    // All validations passed
    return null;
  }

  Future<void> _saveLog({bool submit = false}) async {
    // Validate before saving/submission
    final validationError = _validateDailyLog(requireSubmission: submit);
    if (validationError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final log = DailyLog(
      projectId: widget.projectId,
      taskId: widget.taskId,
      date: _selectedDate,
      status: submit ? 'submitted' : 'draft',
      notes: _notesText,
      weather: _weatherText,
      labor: _labor,
      materials: _materials,
      equipment: _equipment,
      shifts: _shifts,
      attachments: [
        ..._selectedImages.map((img) => img.path),
        ..._selectedPdfs,
      ],
    );

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await ref.read(dailyLogControllerProvider.notifier).createLog(log);

    if (!mounted) return;
    if (ref.read(dailyLogControllerProvider).hasError) {
      messenger.showSnackBar(
        SnackBar(
            content:
                Text('Error: ${ref.read(dailyLogControllerProvider).error}'),
            backgroundColor: AppColors.error,
        ),
      );
    } else {
      // Upload images if there are any
      final createdLog = ref.read(dailyLogControllerProvider).value;
      if (createdLog != null && createdLog.id != null) {
        if (_selectedImages.isNotEmpty) {
          await _uploadImages(createdLog.id!);
        }
        if (_selectedPdfs.isNotEmpty) {
          await _uploadPdfs(createdLog.id!);
        }

        // Update task progress if applicable
        if (widget.taskId != null && _taskProgressPercent > 0) {
          try {
            await ref.read(dioProvider).patch(
              '/projects/${widget.projectId}/tasks/${widget.taskId}',
              data: {'progress_percentage': _taskProgressPercent},
            );
          } catch (_) {
            // Don't block navigation if this fails
          }
        }
      }

      // Refresh the daily logs list
      ref.invalidate(projectLogsProvider(widget.projectId));
      if (mounted) {
        navigator.pop();
      }
    }
  }

  Future<void> _uploadImages(String logId) async {
    setState(() {
      _isUploadingImages = true;
      _uploadProgress = 0.0;
    });

    try {
      for (int i = 0; i < _selectedImages.length; i++) {
        await ref.read(dailyLogRemoteDataSourceProvider).uploadAttachment(
              logId,
              _selectedImages[i].path,
            );
        setState(() {
          _uploadProgress = ((i + 1) / _selectedImages.length);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _uploadPdfs(String logId) async {
    try {
      for (final pdfPath in _selectedPdfs) {
        await ref.read(dailyLogRemoteDataSourceProvider).uploadAttachment(
              logId,
              pdfPath,
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading PDFs: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // Request permissions
    final messenger = ScaffoldMessenger.of(context);
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Camera permission denied')),
          );
        }
        return;
      }
    } else {
      final storageStatus = await Permission.photos.request();
      if (!storageStatus.isGranted) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Photos permission denied')),
          );
        }
        return;
      }
    }

    final XFile? image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1280,
    );

    if (image != null) {
      setState(() {
        if (_selectedImages.length < 5) {
          _selectedImages.add(image);
          _imageCaptions.add('');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 5 images allowed')),
          );
        }
      });
    }
  }

  Future<void> _pickGallery() async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );
        if (result != null && result.files.isNotEmpty) {
          final xFiles = result.files
              .map((f) => XFile(f.path ?? '', name: f.name))
              .toList();
          setState(() {
            _selectedImages.addAll(xFiles.take(5 - _selectedImages.length));
            while (_imageCaptions.length < _selectedImages.length) {
              _imageCaptions.add('');
            }
          });
        }
      } else {
        // Mobile: use image_picker
        final images = await _imagePicker.pickMultiImage(
          imageQuality: 70,
          maxWidth: 1280,
        );
        if (images.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(images.take(5 - _selectedImages.length));
            while (_imageCaptions.length < _selectedImages.length) {
              _imageCaptions.add('');
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open gallery: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _imageCaptions.removeAt(index);
    });
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdfs.add(result.files.single.path!);
      });
    }
  }

  void _removePdf(int index) {
    setState(() {
      _selectedPdfs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Only site_engineer and project_manager/owner can create logs
    if (!isRoleAllowed(ref, ['site_engineer', 'project_manager', 'owner'])) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Create Daily Log'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_person_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Access Restricted',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Only Site Engineers and Project Managers can create daily logs.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted.copyWith(
                    color: AppColors.secondaryTextFor(
                        Theme.of(context).brightness),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Create Daily Log'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _WizardHeader(currentStep: _currentStep),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _BasicInfoStep(
                  selectedDate: _selectedDate,
                  notesController: _notesController,
                  reportNumberController: _reportNumberController,
                  weatherCondition: _weatherCondition,
                  weatherLostHours: _weatherLostHours,
                  taskProgressPercent: _taskProgressPercent,
                  taskId: widget.taskId,
                  onDateChanged: (date) => setState(() => _selectedDate = date),
                  onWeatherConditionChanged: (v) =>
                      setState(() => _weatherCondition = v),
                  onWeatherLostHoursChanged: (v) =>
                      setState(() => _weatherLostHours = v),
                  onTaskProgressChanged: (v) =>
                      setState(() => _taskProgressPercent = v),
                ),
                _ShiftsStep(
                  shifts: _shifts,
                  onChanged: () => setState(() {}),
                ),
                _LaborStep(
                  labor: _labor,
                  onChanged: () => setState(() {}),
                ),
                _MaterialsStep(
                  materials: _materials,
                  onChanged: () => setState(() {}),
                ),
                _EquipmentStep(
                  equipment: _equipment,
                  onChanged: () => setState(() {}),
                ),
                _PhotosStep(
                  selectedImages: _selectedImages,
                  imageCaptions: _imageCaptions,
                  selectedPdfs: _selectedPdfs,
                  onPickImage: _pickImage,
                  onPickGallery: _pickGallery,
                  onRemoveImage: _removeImage,
                  onCaptionChanged: (index, caption) {
                    setState(() => _imageCaptions[index] = caption);
                  },
                  onPickPdf: _pickPdf,
                  onRemovePdf: _removePdf,
                  isUploading: _isUploadingImages,
                  uploadProgress: _uploadProgress,
                ),
                _ReviewStep(
                  date: _selectedDate,
                  notes: _notesText,
                  weather: _weatherText,
                  labor: _labor,
                  materials: _materials,
                  equipment: _equipment,
                  shifts: _shifts,
                  images: _selectedImages,
                  imageCaptions: _imageCaptions,
                  selectedPdfs: _selectedPdfs,
                ),
              ],
            ),
          ),
          _WizardFooter(
            currentStep: _currentStep,
            onBack: _prevStep,
            onNext: _nextStep,
            onSave: () => _saveLog(submit: false),
            onSubmit: () => _saveLog(submit: true),
            isLoading: ref.watch(dailyLogControllerProvider).isLoading ||
                _isUploadingImages,
          ),
        ],
      ),
    );
  }
}

class _WizardHeader extends StatelessWidget {
  final int currentStep;
  const _WizardHeader({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    const labels = [
      'Basic Info',
      'Shift',
      'Labor',
      'Materials',
      'Equipment',
      'Photos',
      'Review',
    ];
    const totalSteps = 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border:
            Border(bottom: BorderSide(color: AppColors.borderFor(brightness))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Create Daily Log',
                style: AppTextStyles.sectionTitle.copyWith(
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
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  borderRadius: AppRadius.small,
                ),
                child: Text(
                  'Step ${currentStep + 1} of $totalSteps',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            labels[currentStep],
            style: AppTextStyles.bodyMuted.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;
              return Expanded(
                child: Container(
                  margin:
                      EdgeInsets.only(right: index == totalSteps - 1 ? 0 : AppSpacing.xs),
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.accentBlue
                        : AppColors.borderFor(brightness),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _WizardFooter extends StatelessWidget {
  final int currentStep;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSave;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _WizardFooter({
    required this.currentStep,
    required this.onBack,
    required this.onNext,
    required this.onSave,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final isFinalStep = currentStep == 6;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border(top: BorderSide(color: AppColors.borderFor(brightness))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: AppButton(
                text: 'Back',
                onPressed: onBack,
                isOutline: true,
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: isFinalStep ? 2 : 1,
            child: isFinalStep
                ? Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Save Draft',
                          onPressed: onSave,
                          isOutline: true,
                          isLoading: isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'Submit Log',
                          onPressed: onSubmit,
                          isLoading: isLoading,
                        ),
                      ),
                    ],
                  )
                : AppButton(
                    text: 'Next',
                    onPressed: onNext,
                  ),
          ),
        ],
      ),
    );
  }
}

class _BasicInfoStep extends StatelessWidget {
  final DateTime selectedDate;
  final TextEditingController notesController;
  final TextEditingController reportNumberController;
  final String weatherCondition;
  final double weatherLostHours;
  final double taskProgressPercent;
  final String? taskId;
  final Function(DateTime) onDateChanged;
  final Function(String) onWeatherConditionChanged;
  final Function(double) onWeatherLostHoursChanged;
  final Function(double) onTaskProgressChanged;

  static const _weatherOptions = ['Fine', 'Good', 'Bad', 'Rainy'];

  const _BasicInfoStep({
    required this.selectedDate,
    required this.notesController,
    required this.reportNumberController,
    required this.weatherCondition,
    required this.weatherLostHours,
    required this.taskProgressPercent,
    required this.taskId,
    required this.onDateChanged,
    required this.onWeatherConditionChanged,
    required this.onWeatherLostHoursChanged,
    required this.onTaskProgressChanged,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return _StepPage(
      title: 'Basic Info',
      subtitle: 'Record the date, site conditions, and field notes.',
      child: Column(
        children: [
          AppTextField(
            label: 'Date',
            hint: 'Select Date',
            controller: TextEditingController(
                text: DateFormat('MMM dd, yyyy').format(selectedDate)),
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) onDateChanged(date);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Site Conditions',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.secondaryTextFor(brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _weatherOptions.map((option) {
                  final isSelected = option == weatherCondition;
                  return InkWell(
                    onTap: () => onWeatherConditionChanged(option),
                    borderRadius: AppRadius.medium,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentBlue.withValues(alpha: 0.12)
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.lightMutedSurface),
                        borderRadius: AppRadius.medium,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentBlue
                              : AppColors.borderFor(brightness),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.accentBlue,
                            ),
                          if (isSelected) const SizedBox(width: AppSpacing.xs),
                          Text(
                            option,
                            style: AppTextStyles.label.copyWith(
                              color: isSelected
                                  ? AppColors.accentBlue
                                  : AppColors.secondaryTextFor(brightness),
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Lost Hours (weather)',
            hint: '0.0',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            controller: TextEditingController(
                text: weatherLostHours == 0.0
                    ? ''
                    : weatherLostHours.toStringAsFixed(1)),
            onChanged: (v) =>
                onWeatherLostHoursChanged(double.tryParse(v) ?? 0.0),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Report Number',
            hint: 'e.g. RPT-2024-001',
            controller: reportNumberController,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Notes',
            hint: 'Enter detailed notes about today\'s work...',
            controller: notesController,
            maxLines: 4,
          ),
          if (taskId != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Completion %',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: taskProgressPercent,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: '${taskProgressPercent.round()}%',
                        onChanged: onTaskProgressChanged,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${taskProgressPercent.round()}%',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ShiftsStep extends StatelessWidget {
  final List<LogShift> shifts;
  final VoidCallback onChanged;

  const _ShiftsStep({required this.shifts, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return _StepPage(
      title: 'Shift',
      subtitle: 'Select the shifts that were active today.',
      child: Column(
        children: [
          if (shifts.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(brightness).withValues(alpha: 0.5),
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.borderFor(brightness)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.work_outline_rounded,
                    size: 48,
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No shifts added yet',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add shifts to track work periods',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightMutedSurface,
                borderRadius: AppRadius.medium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Text(
                      'Active shifts',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.secondaryTextFor(brightness),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ...shifts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final shift = entry.value;
                    return Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Text(
                            shift.shiftType,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: AppColors.error.withValues(alpha: 0.7),
                            onPressed: () {
                              shifts.removeAt(index);
                              onChanged();
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: '+ Add Shift',
            onPressed: () => _showShiftBottomSheet(context, shifts, onChanged),
            isOutline: true,
          ),
        ],
      ),
    );
  }

  void _showShiftBottomSheet(
    BuildContext context,
    List<LogShift> shifts,
    VoidCallback onChanged,
  ) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AppBottomSheet(
        title: 'Select Shift Type',
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...['Day', 'Night', 'Other'].map((type) {
              return InkWell(
                onTap: () {
                  shifts.add(LogShift(shiftType: type));
                  onChanged();
                  Navigator.pop(context);
                },
                borderRadius: AppRadius.medium,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.borderFor(brightness),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        type,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.secondaryTextFor(brightness),
                      ),
                    ],
                  ),
       ),
              );
            }),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
                isOutline: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaborStep extends StatelessWidget {
  final List<LogLabor> labor;
  final VoidCallback onChanged;

  static const _workerTypeOptions = [
    'Mason',
    'Carpenter',
    'Reinforcement Worker (Fitter)',
    'Electrician',
    'Plumber',
    'Painter',
    'Tile Layer',
    'General Labor',
    'Site Supervisor',
    'Driver',
    'Guard',
    'Other',
  ];

  const _LaborStep({required this.labor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _StepPage(
      title: 'Labor',
      subtitle: 'Add workers, hours, and labor cost.',
      child: Column(
        children: [
          ...labor.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _EntryCard(
              title: Text(item.workerType),
              subtitle: Text(
                '${item.hoursWorked} hrs · ${EthiopiaFormatters.formatCurrencyCompact(item.cost)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error.withValues(alpha: 0.7),
                onPressed: () {
                  labor.removeAt(index);
                  onChanged();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: '+ Add Labor',
            onPressed: () => _showAddLaborBottomSheet(context, labor, onChanged),
            isOutline: true,
          ),
        ],
      ),
    );
  }

  void _showAddLaborBottomSheet(
    BuildContext context,
    List<LogLabor> labor,
    VoidCallback onChanged,
  ) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    String selectedType = _workerTypeOptions.first;
    final hoursController = TextEditingController();
    final countController = TextEditingController(text: '1');
    final costController = TextEditingController();

    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AppBottomSheet(
          title: 'Add Labor',
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Worker Type',
                  labelStyle: AppTextStyles.label.copyWith(
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.medium,
                    borderSide: BorderSide(color: AppColors.borderFor(brightness)),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightMutedSurface,
                ),
                items: _workerTypeOptions
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    selectedType = v;
                    setDialogState(() {});
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Hours Worked',
                      controller: hoursController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Count',
                      controller: countController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Total Cost (ETB)',
                controller: costController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isOutline: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      text: 'Add',
                      onPressed: () {
                        final count = int.tryParse(countController.text) ?? 1;
                        labor.add(LogLabor(
                          workerType: '$selectedType (x$count)',
                          hoursWorked: double.tryParse(hoursController.text) ?? 0,
                          cost: double.tryParse(costController.text) ?? 0,
                        ));
                        onChanged();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialsStep extends StatelessWidget {
  final List<LogMaterial> materials;
  final VoidCallback onChanged;

  static const _materialOptions = [
    'Cement',
    'Sand',
    'Gravel/Aggregate',
    'Steel Reinforcement',
    'Bricks',
    'Concrete Blocks',
    'Wood/Timber',
    'Paint',
    'Glass',
    'Ceramic Tiles',
    'Marble/Granite',
    'PVC Pipes',
    'Electrical Wiring',
    'Insulation Materials',
    'Roofing Materials',
    'Nails/Screws',
    'Adhesives/Sealants',
    'Drywall/Gypsum Board',
    'Other',
  ];

  static const _unitOptions = [
    'm³',
    'm²',
    'm (linear)',
    'kg',
    'ton',
    'bag (50kg)',
    'bag (25kg)',
    'piece',
    'liter',
    'set',
    'lot',
    'Other',
  ];

  const _MaterialsStep({required this.materials, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _StepPage(
      title: 'Materials',
      subtitle: 'Track quantities, units, and material cost.',
      child: Column(
        children: [
          ...materials.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _EntryCard(
              title: Text(item.name),
              subtitle: Text(
                '${item.quantity} ${item.unit} · ${EthiopiaFormatters.formatCurrencyCompact(item.cost)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error.withValues(alpha: 0.7),
                onPressed: () {
                  materials.removeAt(index);
                  onChanged();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: '+ Add Material',
            onPressed: () => _showAddMaterialBottomSheet(context, materials, onChanged),
            isOutline: true,
          ),
        ],
      ),
    );
  }

  void _showAddMaterialBottomSheet(
    BuildContext context,
    List<LogMaterial> materials,
    VoidCallback onChanged,
  ) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    String selectedMaterial = _materialOptions.first;
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    String selectedUnit = _unitOptions.first;
    final costController = TextEditingController();
    final supplierController = TextEditingController();

    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AppBottomSheet(
          title: 'Add Material',
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedMaterial,
                decoration: InputDecoration(
                  labelText: 'Material Name',
                  labelStyle: AppTextStyles.label.copyWith(
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.medium,
                    borderSide: BorderSide(color: AppColors.borderFor(brightness)),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightMutedSurface,
                ),
                items: _materialOptions
                    .map((material) => DropdownMenuItem(
                          value: material,
                          child: Text(
                            material,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    selectedMaterial = v;
                    nameController.text = v;
                    setDialogState(() {});
                  }
                },
              ),
              if (selectedMaterial == 'Other')
                Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Custom Material Name',
                      controller: nameController,
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Qty',
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        labelStyle: AppTextStyles.label.copyWith(
                          color: AppColors.secondaryTextFor(brightness),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.medium,
                          borderSide: BorderSide(color: AppColors.borderFor(brightness)),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightMutedSurface,
                      ),
                      items: _unitOptions
                          .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(
                                  unit,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          selectedUnit = v;
                          setDialogState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Total Cost (ETB)',
                controller: costController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Supplier (optional)',
                controller: supplierController,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isOutline: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      text: 'Add',
                      onPressed: () {
                        final name = selectedMaterial == 'Other'
                            ? nameController.text.trim()
                            : selectedMaterial.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a material name')),
                          );
                          return;
                        }
                        final supplier = supplierController.text.trim();
                        materials.add(LogMaterial(
                          name: supplier.isNotEmpty ? '$name [$supplier]' : name,
                          quantity: double.tryParse(qtyController.text) ?? 0,
                          unit: selectedUnit,
                          cost: double.tryParse(costController.text) ?? 0,
                        ));
                        onChanged();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentStep extends StatelessWidget {
  final List<LogEquipment> equipment;
  final VoidCallback onChanged;

  static const _equipmentOptions = [
    'Excavator',
    'Bulldozer',
    'Backhoe Loader',
    'Crane',
    'Concrete Mixer',
    'Concrete Pump',
    'Forklift',
    'Dump Truck',
    'Road Roller',
    'Grader',
    'Compactor',
    'Paver',
    'Jackhammer',
    'Generator',
    'Compressor',
    'Welding Machine',
    'Scaffolding',
    'Tower Crane',
    'Skid Steer Loader',
    'Other',
  ];

  const _EquipmentStep({required this.equipment, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return _StepPage(
      title: 'Equipment',
      subtitle: 'Record equipment hours and cost.',
      child: Column(
        children: [
          if (equipment.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(brightness).withValues(alpha: 0.5),
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.borderFor(brightness)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.precision_manufacturing_rounded,
                    size: 48,
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No equipment added yet',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Track machinery hours, idle time, down time, and cost.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            )
          else ...[
            ...equipment.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _EntryCard(
                title: Text(item.name),
                subtitle: Text(
                  '${item.hoursUsed} hrs · ${EthiopiaFormatters.formatCurrencyCompact(item.cost)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.error.withValues(alpha: 0.7),
                  onPressed: () {
                    equipment.removeAt(index);
                    onChanged();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: '+ Add Equipment',
            onPressed: () => _showAddEquipmentBottomSheet(context, equipment, onChanged),
            isOutline: true,
          ),
        ],
      ),
    );
  }

  void _showAddEquipmentBottomSheet(
    BuildContext context,
    List<LogEquipment> equipment,
    VoidCallback onChanged,
  ) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    String selectedEquipment = _equipmentOptions.first;
    final nameController = TextEditingController();
    final hoursController = TextEditingController();
    final costController = TextEditingController();
    final idleHoursController = TextEditingController();
    final downHoursController = TextEditingController();

    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AppBottomSheet(
          title: 'Add Equipment',
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedEquipment,
                decoration: InputDecoration(
                  labelText: 'Equipment Name',
                  labelStyle: AppTextStyles.label.copyWith(
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.medium,
                    borderSide: BorderSide(color: AppColors.borderFor(brightness)),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightMutedSurface,
                ),
                items: _equipmentOptions
                    .map((equipment) => DropdownMenuItem(
                          value: equipment,
                          child: Text(
                            equipment,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    selectedEquipment = v;
                    nameController.text = v;
                    setDialogState(() {});
                  }
                },
              ),
              if (selectedEquipment == 'Other')
                Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Custom Equipment Name',
                      controller: nameController,
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Hours Used',
              controller: hoursController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Idle Hours',
                    controller: idleHoursController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: 'Down Hours',
                    controller: downHoursController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Total Cost (ETB)',
              controller: costController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    isOutline: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    text: 'Add',
                    onPressed: () {
                      final name = selectedEquipment == 'Other'
                          ? nameController.text.trim()
                          : selectedEquipment.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter an equipment name')),
                        );
                        return;
                      }
                      final idle = double.tryParse(idleHoursController.text) ?? 0;
                      final down = double.tryParse(downHoursController.text) ?? 0;
                      final displayName = (idle > 0 || down > 0)
                          ? '$name | Idle:${idle}h Down:${down}h'
                          : name;
                      equipment.add(LogEquipment(
                        name: displayName,
                        hoursUsed: double.tryParse(hoursController.text) ?? 0,
                        cost: double.tryParse(costController.text) ?? 0,
                      ));
                      onChanged();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _PhotosStep extends StatelessWidget {
  final List<XFile> selectedImages;
  final List<String> imageCaptions;
  final List<String> selectedPdfs;
  final Function(ImageSource) onPickImage;
  final VoidCallback onPickGallery;
  final Function(int) onRemoveImage;
  final Function(int, String) onCaptionChanged;
  final VoidCallback onPickPdf;
  final Function(int) onRemovePdf;
  final bool isUploading;
  final double uploadProgress;

  const _PhotosStep({
    required this.selectedImages,
    required this.imageCaptions,
    required this.selectedPdfs,
    required this.onPickImage,
    required this.onPickGallery,
    required this.onRemoveImage,
    required this.onCaptionChanged,
    required this.onPickPdf,
    required this.onRemovePdf,
    required this.isUploading,
    required this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final totalAttachments = selectedImages.length + selectedPdfs.length;

    return _StepPage(
      title: 'Photos & Attachments',
      subtitle: 'Add photos or PDF documents to support today\'s report.',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              borderRadius: AppRadius.small,
            ),
            child: Text(
              '$totalAttachments / 5 attachments',
              style: AppTextStyles.label.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isUploading) ...[
            Column(
              children: [
                Text(
                  'Uploading images...',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(
                  value: uploadProgress,
                  backgroundColor:
                      AppColors.constructProBlue.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.constructProBlue),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${(uploadProgress * 100).round()}%',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (selectedImages.isEmpty && selectedPdfs.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(brightness).withValues(alpha: 0.5),
                borderRadius: AppRadius.medium,
                border: Border.all(
                  color: AppColors.borderFor(brightness),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 48,
                    color: AppColors.secondaryTextFor(brightness),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No photos or attachments yet',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Add photos or PDF documents to support today\'s report.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            )
          else ...[
            if (selectedImages.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  final caption =
                      index < imageCaptions.length ? imageCaptions[index] : '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadius.medium,
                              child: kIsWeb
                                  ? Image.network(
                                      selectedImages[index].path,
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    )
                                  : Image.file(
                                      File(selectedImages[index].path),
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                    ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white, size: 14),
                                  onPressed: () => onRemoveImage(index),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextFormField(
                            initialValue: caption,
                            decoration: InputDecoration(
                              labelText: 'Caption (optional)',
                              labelStyle: AppTextStyles.label.copyWith(
                                color: AppColors.secondaryTextFor(brightness),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.medium,
                                borderSide: BorderSide(
                                    color: AppColors.borderFor(brightness)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.medium,
                                borderSide: BorderSide(
                                    color: AppColors.borderFor(brightness)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadius.medium,
                                borderSide: const BorderSide(
                                    color: AppColors.accentBlue),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightMutedSurface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                            ),
                            style: AppTextStyles.bodyMd.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            onChanged: (v) => onCaptionChanged(index, v),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (selectedPdfs.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              ...selectedPdfs.asMap().entries.map((entry) {
                final index = entry.key;
                final pdfPath = entry.value;
                final fileName = p.basename(pdfPath);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _EntryCard(
                    title: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(fileName,
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => onRemovePdf(index),
                    ),
                  ),
                );
              }),
            ],
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Take Photo',
                  icon: Icons.camera_alt_rounded,
                  isOutline: true,
                  onPressed: isUploading
                      ? null
                      : () => onPickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  text: 'Choose from Gallery',
                  icon: Icons.photo_library_rounded,
                  isOutline: true,
                  onPressed: isUploading ? null : onPickGallery,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Attach PDF Document',
              icon: Icons.attach_file,
              isOutline: true,
              onPressed: isUploading ? null : onPickPdf,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final DateTime date;
  final String notes;
  final String weather;
  final List<LogLabor> labor;
  final List<LogMaterial> materials;
  final List<LogEquipment> equipment;
  final List<LogShift> shifts;
  final List<XFile> images;
  final List<String> imageCaptions;
  final List<String> selectedPdfs;

  const _ReviewStep({
    required this.date,
    required this.notes,
    required this.weather,
    required this.labor,
    required this.materials,
    required this.equipment,
    required this.shifts,
    required this.images,
    required this.imageCaptions,
    required this.selectedPdfs,
  });

  @override
  Widget build(BuildContext context) {
    final totalLaborCost = labor.fold(0.0, (sum, e) => sum + e.cost);
    final totalMaterialsCost = materials.fold(0.0, (sum, e) => sum + e.cost);
    final totalEquipmentCost = equipment.fold(0.0, (sum, e) => sum + e.cost);
    final totalCost = totalLaborCost + totalMaterialsCost + totalEquipmentCost;

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return _StepPage(
      title: 'Review & Save',
      subtitle: 'Confirm entries before saving the daily log.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cost summary card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkSurface : AppColors.lightMutedSurface,
              borderRadius: AppRadius.medium,
              border: Border.all(color: AppColors.borderFor(brightness)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cost Summary',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _CostRow(
                    label: 'Total Labor Cost',
                    value: EthiopiaFormatters.formatCurrency(totalLaborCost)),
                const SizedBox(height: AppSpacing.xs),
                _CostRow(
                    label: 'Total Materials Cost',
                    value:
                        EthiopiaFormatters.formatCurrency(totalMaterialsCost)),
                const SizedBox(height: AppSpacing.xs),
                _CostRow(
                    label: 'Total Equipment Cost',
                    value:
                        EthiopiaFormatters.formatCurrency(totalEquipmentCost)),
                const Divider(height: 24),
                _CostRow(
                  label: 'Total Day Cost',
                  value: EthiopiaFormatters.formatCurrency(totalCost),
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SummaryCard(
              title: 'Date', value: DateFormat('MMM dd, yyyy').format(date)),
          _SummaryCard(
              title: 'Site Conditions',
              value: weather.isEmpty ? '--' : weather),
          _SummaryCard(title: 'Notes', value: notes),
          _SummaryCard(
              title: 'Shifts',
              value: shifts.map((e) => e.shiftType).join(', ')),
          _SummaryCard(title: 'Labor Items', value: labor.length.toString()),
          _SummaryCard(
              title: 'Material Items', value: materials.length.toString()),
          _SummaryCard(
              title: 'Equipment Items', value: equipment.length.toString()),
          _SummaryCard(title: 'Photos', value: images.length.toString()),
          if (selectedPdfs.isNotEmpty)
            _SummaryCard(
                title: 'PDF Attachments',
                value: selectedPdfs
                    .map((path) => p.basename(path))
                    .join(', ')),
          // Show image captions if any
          if (images.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < images.length; i++)
              if (i < imageCaptions.length && imageCaptions[i].isNotEmpty)
                _SummaryCard(
                  title: 'Photo ${i + 1} Caption',
                  value: imageCaptions[i],
                ),
          ],
          const Divider(height: 32),
          _OfflineDraftNotice(),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _CostRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isBold
                  ? AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold)
                  : AppTextStyles.bodyMd)
              .copyWith(
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        Text(
          value,
          style: (isBold
                  ? AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold)
                  : AppTextStyles.bodyMd)
              .copyWith(
            color: isBold
                ? AppColors.accentBlue
                : (isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: AppColors.secondaryTextFor(brightness),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '--' : value,
            style: AppTextStyles.bodyMd.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepPage({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            isWide ? AppSpacing.xxl : AppSpacing.lg,
            AppSpacing.lg,
            isWide ? AppSpacing.xxl : AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  const _EntryCard({
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.lightMutedSurface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(brightness)),
        ),
        child: Row(
          children: [
            Expanded(
              child: DefaultTextStyle.merge(
                style: AppTextStyles.bodyMd.copyWith(
                  color: brightness == Brightness.dark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      DefaultTextStyle.merge(
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryTextFor(brightness),
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _OfflineDraftNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.warning),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Drafts can be saved offline and synced when connection is available.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
