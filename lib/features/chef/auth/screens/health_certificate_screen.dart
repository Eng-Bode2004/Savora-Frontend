import 'package:flutter/material.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';

import '../../widgets/chef_top_bar.dart';
import '../../widgets/chef_ui_kit.dart';

/// Step 2 ("Certification") of the account-setup wizard: upload a valid
/// health/food-handler certificate.
class HealthCertificateScreen extends StatefulWidget {
  const HealthCertificateScreen({super.key});

  @override
  State<HealthCertificateScreen> createState() =>
      _HealthCertificateScreenState();
}

class _HealthCertificateScreenState extends State<HealthCertificateScreen> {
  bool _fileSelected = false;

  void _browseFiles() => setState(() => _fileSelected = true);

  void _upload() {
    if (!_fileSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a certificate file first.')),
      );
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      backgroundColor: AppColors.surfaceSunkenOf(brightness),
      appBar: const ChefTopBar(
          leading: ChefTopBarLeading.back, title: 'Savora Chef'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const NumberedStepper(
              steps: ['Basic Info', 'Certification', 'Banking'],
              currentIndex: 1),
          const SizedBox(height: AppSpacing.lg),
          Text('Health Certificate',
              style: AppTextStyles.headlineLg
                  .copyWith(color: AppColors.textOf(brightness))),
          const SizedBox(height: 4),
          Text(
            'Please upload your valid food handler or hygiene certification to start your professional kitchen.',
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.textMutedOf(brightness)),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      borderRadius: AppSpacing.borderRadiusSm),
                  child: const Icon(Icons.info_outline,
                      color: AppColors.amber, size: 19),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Why is this required?',
                          style: AppTextStyles.titleMd
                              .copyWith(color: AppColors.textOf(brightness))),
                      const SizedBox(height: 4),
                      Text(
                        "To maintain Savora's high standards and ensure safety, we verify that all partner chefs hold current health and safety credentials.",
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textMutedOf(brightness)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          UploadDropzone(
            icon: Icons.cloud_upload_outlined,
            title: _fileSelected
                ? 'certificate_scan.pdf selected'
                : 'Tap to upload certificate',
            subtitle: 'Supports PDF, JPG, or PNG (Max 5MB)',
            buttonLabel: 'Browse Files',
            onTap: _browseFiles,
          ),
          const SizedBox(height: AppSpacing.lg),
          ChefPrimaryButton(
            label: 'Upload Certificate',
            icon: Icons.arrow_forward_rounded,
            onPressed: _upload,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: Text(
                'Need help? Contact Support',
                style: AppTextStyles.labelLg.copyWith(color: AppColors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
