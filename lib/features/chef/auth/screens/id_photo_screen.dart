import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savora_app/core/routing/routes.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import '../models/step_data.dart';

class IdPhotoScreen extends StatefulWidget {
  const IdPhotoScreen({super.key});

  @override
  State<IdPhotoScreen> createState() => _IdPhotoScreenState();
}

class _IdPhotoScreenState extends State<IdPhotoScreen> {
  String? _frontFileName;
  String? _backFileName;
  bool _isFrontSelected = false;
  bool _isBackSelected = false;

  // Stepper steps: Orders and Health Cert are completed (2 checkmarks)
  // Identity is active, Location is not done.
  final List<StepData> steps = [
    StepData(
        label: 'Orders',
        icon: Icons.motorcycle,
        isActive: false,
        isCompleted: true,
        isError: false),
    StepData(
        label: 'Location',
        icon: Icons.map_outlined,
        isActive: false,
        isCompleted: false,
        isError: true),
    StepData(
        label: 'Identity',
        icon: Icons.badge_outlined,
        isActive: true,
        isCompleted: false,
        isError: false),
    StepData(
        label: 'Health Cert',
        icon: Icons.medical_information,
        isActive: false,
        isCompleted: true,
        isError: false),
  ];

  Future<void> _pickImage(bool isFront) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isFront) {
            _isFrontSelected = true;
            _frontFileName = image.name;
          } else {
            _isBackSelected = true;
            _backFileName = image.name;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${isFront ? "Front" : "Back"} ID selected: ${image.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Picker error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open gallery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavBar(context),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Stepper Component
                    _buildStepper(),
                    const SizedBox(height: 24),
                    // Main Content Section
                    _buildMainContent(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          // Back Button
          IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Identity Verification',
            style: _getTextStyle('headline-md').copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stepper Nodes
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final nodeWidth = (totalWidth - 32) / steps.length;

            return Stack(
              children: [
                // Background Line
                Positioned(
                  left: 0,
                  right: 0,
                  top: 20,
                  child: Container(
                    height: 2,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                // Progress Line (up to step 3)
                Positioned(
                  left: 0,
                  top: 20,
                  child: Container(
                    width: totalWidth * 0.65,
                    height: 2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                // Nodes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;

                    return _buildStepNode(
                      index: index,
                      step: step,
                      nodeWidth: nodeWidth,
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        // Labels
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: steps.map((step) {
                  final isActive = step.isActive;
                  return SizedBox(
                    width: 64,
                    child: Text(
                      step.label,
                      style: _getTextStyle('label-md').copyWith(
                        color: isActive
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepNode({
    required int index,
    required StepData step,
    required double nodeWidth,
  }) {
    final isActive = step.isActive;
    final isCompleted = step.isCompleted;
    final isError = step.isError;
    final color = Theme.of(context).colorScheme;

    Color nodeBgColor;
    Color iconColor;
    BorderSide borderSide;
    IconData displayIcon;

    if (isError) {
      nodeBgColor = Colors.red;
      iconColor = Colors.white;
      borderSide = const BorderSide(color: Colors.red, width: 2);
      displayIcon = Icons.close;
    } else if (isCompleted) {
      nodeBgColor = color.secondary;
      iconColor = Colors.white;
      borderSide = BorderSide(color: color.secondary, width: 2);
      displayIcon = Icons.check;
    } else {
      nodeBgColor = color.surface;
      iconColor = isActive ? color.secondary : color.onSurfaceVariant;
      borderSide = BorderSide(
        color: isActive ? color.secondary : color.outlineVariant,
        width: 2,
      );
      displayIcon = step.icon;
    }

    return SizedBox(
      width: nodeWidth,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: nodeBgColor,
              border: Border.fromBorderSide(borderSide),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.secondary.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                displayIcon,
                color: iconColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'National ID Card Photo',
          style: _getTextStyle('headline-lg').copyWith(
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Please upload clear photos of both the front and back of your national identity card.',
          style: _getTextStyle('body-md').copyWith(
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Front ID Card Upload
        _buildUploadCard(
          title: 'Front of ID Card',
          isSelected: _isFrontSelected,
          fileName: _frontFileName,
          onTap: () => _pickImage(true),
        ),
        const SizedBox(height: 16),

        // Back ID Card Upload
        _buildUploadCard(
          title: 'Back of ID Card',
          isSelected: _isBackSelected,
          fileName: _backFileName,
          onTap: () => _pickImage(false),
        ),
        const SizedBox(height: 32),

        // Submit Button
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required bool isSelected,
    required String? fileName,
    required VoidCallback onTap,
  }) {
    final color = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.green.withOpacity(0.5) : color.outlineVariant,
          width: 2,
        ),
        color: isSelected
            ? Colors.green.withOpacity(0.02)
            : color.surfaceVariant.withOpacity(0.1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle_outline : Icons.add_a_photo_outlined,
                    color: isSelected ? Colors.green : color.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isSelected ? fileName ?? '' : 'Tap to upload $title',
                  style: _getTextStyle('label-lg').copyWith(
                    color: isSelected ? Colors.green : color.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  isSelected ? 'Ready to upload' : 'Ensure all details on the card are clearly readable',
                  style: _getTextStyle('body-sm').copyWith(
                    color: color.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isEnabled = _isFrontSelected && _isBackSelected;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isEnabled ? color.secondary : Colors.grey.shade300,
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: color.secondary.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled
              ? () {
                  Navigator.of(context).pushReplacementNamed(Routes.chefLocationSelection);
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              'Submit ID Card',
              style: _getTextStyle('label-lg').copyWith(
                color: isEnabled ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _getTextStyle(String style) {
    switch (style) {
      case 'headline-lg':
        return const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.25,
        );
      case 'headline-md':
        return const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.33,
        );
      case 'headline-sm':
        return const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        );
      case 'body-lg':
        return const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.44,
        );
      case 'body-md':
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        );
      case 'body-sm':
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
        );
      case 'label-lg':
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.43,
          letterSpacing: 0.14,
        );
      case 'label-md':
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: 0.24,
        );
      default:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        );
    }
  }
}
