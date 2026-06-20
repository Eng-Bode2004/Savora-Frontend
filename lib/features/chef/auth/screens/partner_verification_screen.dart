import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:savora_app/core/routing/routes.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

import '../../widgets/chef_ui_kit.dart';
import '../models/verification_step.dart';

/// Profile tab home: partner verification checklist + identity document
/// upload.
class PartnerVerificationScreen extends StatefulWidget {
  const PartnerVerificationScreen({super.key});

  @override
  State<PartnerVerificationScreen> createState() =>
      _PartnerVerificationScreenState();
}

class _PartnerVerificationScreenState extends State<PartnerVerificationScreen> {
  static const _steps = [
    VerificationStep(
      title: 'Daily Orders',
      description: 'Order volume and kitchen capacity confirmed.',
      state: VerificationStepState.completed,
    ),
    VerificationStep(
      title: 'Location',
      description: 'Kitchen facility location verified via GPS.',
      state: VerificationStepState.completed,
    ),
    VerificationStep(
      title: 'ID Photo',
      description: 'Action Required: Upload your government-issued ID.',
      state: VerificationStepState.inProgress,
    ),
    VerificationStep(
      title: 'Pending',
      description: 'Final security review and bank linkage.',
      state: VerificationStepState.locked,
    ),
  ];

  String? _selectedFileName;

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedFileName = image.name;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected image from camera: ${image.name}')),
          );
        }
      }
    } catch (e) {
      debugPrint("Camera error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open camera: $e')),
        );
      }
    }
  }

  Future<void> _pickFileFromGallery() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected file: ${file.name}')),
          );
        }
      }
    } catch (e) {
      debugPrint("File picker error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceOf(Theme.of(context).brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (BuildContext context) {
        final brightness = Theme.of(context).brightness;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.amber),
                title: Text(
                  'Take Photo with Camera',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textOf(brightness)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.amber),
                title: Text(
                  'Choose Photo / File from Gallery',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textOf(brightness)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFileFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
        children: [
          Text('Partner Verification',
              style: AppTextStyles.headlineLg
                  .copyWith(color: AppColors.textOf(brightness))),
          const SizedBox(height: 4),
          Text(
            'Complete these steps to unlock your executive kitchen dashboard and start accepting gourmet orders.',
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.textMutedOf(brightness)),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            child: Column(
              children: [
                for (int i = 0; i < _steps.length; i++)
                  _VerificationRow(
                    step: _steps[i],
                    isLast: i == _steps.length - 1,
                    onTap: _steps[i].title == 'Location'
                        ? () => Navigator.of(context)
                            .pushNamed(Routes.chefLocationSetup)
                        : null,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          UploadDropzone(
            icon: _selectedFileName != null ? Icons.check_circle_outline_rounded : Icons.add_a_photo_outlined,
            title: _selectedFileName != null ? 'File Selected' : 'Upload Identity Document',
            subtitle: _selectedFileName ?? 'Tap to open camera or browse files',
            buttonLabel: _selectedFileName != null ? 'CHANGE FILE' : 'SELECT FILE',
            onTap: _showPickerOptions,
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            backgroundColor: AppColors.surfaceSunkenOf(brightness),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: AppColors.textMutedOf(brightness)),
                    const SizedBox(width: 6),
                    Text(
                      'UPLOAD GUIDELINES',
                      style: AppTextStyles.overline
                          .copyWith(color: AppColors.textMutedOf(brightness)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final line in const [
                  'Ensure the photo is clear and all text is legible',
                  'Use a solid, neutral background for the document',
                  'Accepted files: JPG, PNG, PDF (Max 10MB)',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 16, color: AppColors.amber),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(line,
                              style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textOf(brightness))),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.help_outline_rounded,
                      size: 17, color: AppColors.clay),
                  const SizedBox(width: 6),
                  Text(
                    'Need help? Contact Partner Support',
                    style:
                        AppTextStyles.labelLg.copyWith(color: AppColors.clay),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow(
      {required this.step, required this.isLast, this.onTap});

  final VerificationStep step;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final completed = step.state == VerificationStepState.completed;
    final inProgress = step.state == VerificationStepState.inProgress;
    final locked = step.state == VerificationStepState.locked;

    final nodeColor = locked
        ? AppColors.textMutedOf(brightness).withValues(alpha: 0.15)
        : AppColors.gold;
    final nodeIcon = completed
        ? Icons.check_rounded
        : locked
            ? Icons.lock_outline_rounded
            : Icons.badge_outlined;

    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: nodeColor),
                  child: Icon(
                    nodeIcon,
                    size: 16,
                    color: locked
                        ? AppColors.textMutedOf(brightness)
                        : AppColors.clay,
                  ),
                ),
                if (!isLast)
                  Expanded(
                      child: Container(
                          width: 2, color: AppColors.borderOf(brightness))),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          step.title,
                          style: AppTextStyles.titleMd.copyWith(
                            color: locked
                                ? AppColors.textMutedOf(brightness)
                                : AppColors.textOf(brightness),
                          ),
                        ),
                        StatusPill(
                          label: completed
                              ? 'Completed'
                              : inProgress
                                  ? 'In Progress'
                                  : 'Locked',
                          tone: completed
                              ? PillTone.warning
                              : inProgress
                                  ? PillTone.warning
                                  : PillTone.neutral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.description,
                      style: inProgress
                          ? AppTextStyles.bodySm.copyWith(
                              color: AppColors.textOf(brightness),
                              fontWeight: FontWeight.w600)
                          : AppTextStyles.bodySm.copyWith(
                              color: AppColors.textMutedOf(brightness)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
