import 'package:flutter/material.dart';
import 'package:savora_app/core/routing/routes.dart';
import 'package:savora_app/core/theme/app_colors.dart';
import 'package:savora_app/core/theme/app_spacing.dart';
import 'package:savora_app/core/theme/app_text_styles.dart';
import '../models/step_data.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  Offset _pinPosition = const Offset(150, 120);
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _detailsController = TextEditingController();
  String _selectedArea = 'Maadi, Cairo';

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
        isActive: true,
        isCompleted: false,
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
  void dispose() {
    _streetController.dispose();
    _buildingController.dispose();
    _detailsController.dispose();
    super.dispose();
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
          IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Kitchen Location',
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
                    width: totalWidth * 0.4,
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
        Text(
          'Select Kitchen Location',
          style: _getTextStyle('headline-lg').copyWith(
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap on the map to place your kitchen pin, then confirm your full address details below.',
          style: _getTextStyle('body-md').copyWith(
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        // Interactive Mock Map
        _buildInteractiveMap(),
        const SizedBox(height: 24),

        // Address Form
        Text(
          'Address Details',
          style: _getTextStyle('label-lg').copyWith(
            color: color.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          label: 'Area/District',
          value: _selectedArea,
          items: ['Maadi, Cairo', 'Heliopolis, Cairo', 'Tagamoa, New Cairo', 'Zamalik, Cairo', 'Dokki, Giza'],
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedArea = val);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Street Name / Number',
          hint: 'e.g. 9 Road 250',
          controller: _streetController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Building & Flat Number',
          hint: 'e.g. Building 12, Apt 4',
          controller: _buildingController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Additional details (Optional)',
          hint: 'e.g. Near Seoudi Market',
          controller: _detailsController,
        ),
        const SizedBox(height: 32),

        // Confirm Button
        _buildConfirmButton(context),
      ],
    );
  }

  Widget _buildInteractiveMap() {
    final color = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1.8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Map Drawing Simulator
            GestureDetector(
              onTapDown: (details) {
                setState(() {
                  _pinPosition = details.localPosition;
                });
              },
              child: CustomPaint(
                painter: MapPainter(colorScheme: color),
                child: Container(),
              ),
            ),
            // Floating Marker
            Positioned(
              left: _pinPosition.dx - 20,
              top: _pinPosition.dy - 40,
              child: IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.onSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Kitchen Location',
                        style: TextStyle(
                          color: color.surface,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.location_on,
                      color: color.primary,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),
            // Map Control Buttons (Visual enhancement)
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                children: [
                  _buildMiniMapButton(Icons.add),
                  const SizedBox(height: 4),
                  _buildMiniMapButton(Icons.remove),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMapButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: Colors.grey.shade800),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _getTextStyle('label-md').copyWith(
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: color.surfaceVariant.withOpacity(0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color.secondary, width: 2),
            ),
          ),
          style: _getTextStyle('body-md').copyWith(
            color: color.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final color = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _getTextStyle('label-md').copyWith(
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: color.surfaceVariant.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: color.onSurfaceVariant),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isEnabled = _streetController.text.isNotEmpty && _buildingController.text.isNotEmpty;

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
                  Navigator.of(context).pushReplacementNamed(Routes.chefWaitingApproval);
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              'Confirm Location',
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

// Custom Painter to draw a beautiful visual representation of a map grid
class MapPainter extends CustomPainter {
  final ColorScheme colorScheme;

  MapPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Map Background
    final bgPaint = Paint()..color = Colors.lightBlue.shade50;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Draw Parks/Green Areas
    final parkPaint = Paint()..color = Colors.green.shade100;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(20, 20, 100, 70), const Radius.circular(8)), parkPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(200, 80, 120, 60), const Radius.circular(8)), parkPaint);

    // 3. Draw Water bodies
    final waterPaint = Paint()..color = Colors.blue.shade200..style = PaintingStyle.stroke..strokeWidth = 16;
    final path = Path();
    path.moveTo(0, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.75, size.width * 0.7, size.height * 0.85);
    path.lineTo(size.width, size.height * 0.8);
    canvas.drawPath(path, waterPaint);

    // 4. Draw Streets/Grid Lines
    final roadPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final roadBorderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    // Horizontals
    List<double> horizs = [40, size.height * 0.5, size.height * 0.7];
    for (var h in horizs) {
      canvas.drawLine(Offset(0, h), Offset(size.width, h), roadBorderPaint);
      canvas.drawLine(Offset(0, h), Offset(size.width, h), roadPaint);
    }

    // Verticals
    List<double> verts = [80, size.width * 0.5, size.width * 0.8];
    for (var v in verts) {
      canvas.drawLine(Offset(v, 0), Offset(v, size.height), roadBorderPaint);
      canvas.drawLine(Offset(v, 0), Offset(v, size.height), roadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
