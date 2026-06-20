import 'package:flutter/material.dart';
import 'package:savora_app/core/routing/routes.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import '../models/step_data.dart';

class WaitingApprovalScreen extends StatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen> {
  // All steps completed with checkmarks!
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
        isCompleted: true,
        isError: false),
    StepData(
        label: 'Identity',
        icon: Icons.badge_outlined,
        isActive: false,
        isCompleted: true,
        isError: false),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Stepper Component
                    _buildStepper(),
                    const SizedBox(height: 32),
                    // Glassmorphic status panel
                    _buildStatusCard(context),
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
          const SizedBox(width: 16),
          Text(
            'Application Status',
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
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;
            final nodeWidth = (totalWidth - 32) / steps.length;

            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 20,
                  child: Container(
                    height: 2,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 20,
                  child: Container(
                    width: totalWidth,
                    height: 2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
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
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
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
              boxShadow: [
                BoxShadow(
                  color: color.secondary.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
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

  Widget _buildStatusCard(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.outlineVariant.withOpacity(0.6)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.surfaceVariant.withOpacity(0.2),
            color.surface.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Clock/Waiting Shield
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: color.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_empty_rounded,
              color: color.secondary,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Under Review',
            style: _getTextStyle('headline-lg').copyWith(
              color: color.onSurface,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Waiting for Admin Approval',
            style: _getTextStyle('body-lg').copyWith(
              color: color.secondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Thank you for submitting your partner details! Our administration team is currently reviewing your menus, daily orders capacity, identity card details, and kitchen location.',
            style: _getTextStyle('body-md').copyWith(
              color: color.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This process usually takes 24 to 48 hours. We will notify you by phone or SMS once your kitchen is approved and open for customers.',
            style: _getTextStyle('body-sm').copyWith(
              color: color.onSurfaceVariant.withOpacity(0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Done Button
          Container(
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
                  // Return back to PartnerVerificationScreen signaling completion
                  Navigator.of(context).pop(true);
                },
                borderRadius: BorderRadius.circular(8),
                child: Center(
                  child: Text(
                    'Back to Dashboard',
                    style: _getTextStyle('label-lg').copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
