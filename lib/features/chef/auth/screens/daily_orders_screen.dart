import 'package:flutter/material.dart';
import 'package:savora_app/core/routing/routes.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import '../models/step_data.dart';

import '../models/verification_step.dart';

class DailyOrdersScreen extends StatefulWidget {
  const DailyOrdersScreen({super.key});

  @override
  State<DailyOrdersScreen> createState() => _DailyOrdersScreenState();
}

class _DailyOrdersScreenState extends State<DailyOrdersScreen> {
  int _selectedLimit = 15;
  final List<int> _quickOptions = [5, 10, 15, 20, 30, 50];

  // Steps data - matches PartnerVerificationScreen
  final List<StepData> steps = [
    StepData(
        label: 'Orders',
        icon: Icons.motorcycle,
        isActive: true,
        isCompleted: false,
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
        isActive: false,
        isCompleted: false,
        isError: true),
    StepData(
        label: 'Health Cert',
        icon: Icons.medical_information,
        isActive: false,
        isCompleted: true,
        isError: false),
  ];

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          // Back Button
          _buildIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Daily Orders Limit',
            style: _getTextStyle('headline-md').copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
        ),
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
                // Progress Line (up to step 4)
                Positioned(
                  left: 0,
                  top: 20,
                  child: Container(
                    width: totalWidth * 0.85,
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
        // Labels (visible on larger screens)
        const SizedBox(height: 8),
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
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w600,
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
        // Title Section
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Orders Limit',
                style: _getTextStyle('headline-lg').copyWith(
                  color: color.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how many orders you want to receive and prepare per day to maintain top culinary quality.',
                style: _getTextStyle('body-md').copyWith(
                  color: color.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Limit Counter Section
        _buildLimitSelector(context),
        const SizedBox(height: 24),
        // Primary Action Button
        _buildSubmitButton(context),
        const SizedBox(height: 24),
        // Contextual Information Card
        _buildInfoCard(context),
      ],
    );
  }

  Widget _buildLimitSelector(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Maximum Daily Orders',
            style: _getTextStyle('label-lg').copyWith(
              color: color.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          // Plus Minus Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onPressed: _selectedLimit > 1
                    ? () => setState(() => _selectedLimit--)
                    : null,
              ),
              const SizedBox(width: 24),
              Container(
                constraints: const BoxConstraints(minWidth: 80),
                alignment: Alignment.center,
                child: Text(
                  '$_selectedLimit',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              _buildCounterButton(
                icon: Icons.add,
                onPressed: () => setState(() => _selectedLimit++),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Quick Select Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _quickOptions.map((opt) {
              final isSelected = _selectedLimit == opt;
              return ChoiceChip(
                label: Text('$opt orders'),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _selectedLimit = opt);
                },
                selectedColor: color.secondary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : color.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final color = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: onPressed != null
            ? color.secondary.withOpacity(0.1)
            : Colors.grey.shade200,
      ),
      child: IconButton(
        icon: Icon(icon,
            color: onPressed != null ? color.secondary : Colors.grey),
        onPressed: onPressed,
        iconSize: 28,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.secondary,
        boxShadow: [
          BoxShadow(
            color: color.secondary.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushReplacementNamed(Routes.chefIdPhoto);
          },
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              'Submit Daily Limit',
              style: _getTextStyle('label-lg').copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user,
              color: color.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why this matters',
                  style: _getTextStyle('label-lg').copyWith(
                    color: color.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Setting a realistic daily order capacity helps you stay in control of your kitchen workload and ensures high food safety and customer satisfaction standards.',
                  style: _getTextStyle('body-sm').copyWith(
                    color: color.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
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
