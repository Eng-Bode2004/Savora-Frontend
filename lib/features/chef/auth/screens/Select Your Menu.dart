import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuSelectionScreen extends StatefulWidget {
  const MenuSelectionScreen({super.key});

  @override
  State<MenuSelectionScreen> createState() => _MenuSelectionScreenState();
}

class _MenuSelectionScreenState extends State<MenuSelectionScreen> {
  final List<MenuItem> menuItems = [
    MenuItem(
      id: 'royal_lamb_fattah',
      name: 'Royal Lamb Fattah',
      description:
          'Traditional toasted pita, garlic-vinegar rice topped with slow-roasted lamb shank and rich tomato sauce.',
      tags: ['High Demand', '45m Prep'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC8axYMzjvyvO-Au0AXRYgbhiDUf6IexBrLZb67D_dGEw6dcWbGGVN5psaXv2XCse-P6rrB2_EnipOffDXjeoqKajqdBDy3BaBGGCCoy--4xKBiVAoY_UhY9uUK-9xGkewqWtVhPevvHyNmARnI0OH-iwZZ1wOo6oD2qMMcpBOLiSnwUK6wsQAaRkvMpdbg4FZxI_-mQ_Q4KPLx4-Xta0uaRQhL0sLVP7kDnc0AzB-EOwaO1KxeQ5dtL6qqJm55R8A4mlgalVBTOKw',
      isSelected: true,
    ),
    MenuItem(
      id: 'classic_beef_kofta',
      name: 'Classic Beef Kofta',
      description:
          'Minced beef mixed with parsley, onions, and traditional spices, grilled on skewers to smoky perfection.',
      tags: ['Bestseller', '20m Prep'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuClU2OGkQa5n8UsNmmGTTFtxMo1a11wlIGO1jNAV1H2MHlmPZczc48Wb5d3qW357iXIlGbOSkPSfjAwfjQunwQvIAVBS_XNtSWmewpAUhx5-v_5P9tGgTWrIyji3Ty9_qgmDtm0V_TSBVv2MSbEDMgbeIRTOczfQhYffpRlyI_gVIcNVdu1iEpsKpFM50IiMcL95jlfE4SeR3bwrm1cAcBJr4yNefVMzq3OuMBsbwBl0W6I0zToqigFAa1vWH5r9rfgkVtRHUmkYZ0',
      isSelected: true,
    ),
    MenuItem(
      id: 'spicy_shish_taouk',
      name: 'Spicy Shish Taouk',
      description:
          'Marinated chicken breast cubes grilled with bell peppers and onions, served with garlic dip.',
      tags: ['Spicy', '25m Prep'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAM-s8IIduDp28CmdfpUzxfQP9g4KB-XPla8TMhRY_vkahfG13fVr04knZgQrBZbAl0W74HWu9OxQP5teKiS2Jw2Fwn__c5SG6Vm6twv9yJ9tuxz1eUkMs4OPZASfQAzban4pIJfujNw9tcdxTAh4-VpQb0VYcad-BhGGO8m69qVaiCEYiKmyxC5bb-BINnz2svSn7yHBSuiEX067X4QPlrhg2hhWuOssowifPjSy7kfAECZVmY9TVSVvSsBhgmfepETGNcqjuNvjk',
      isSelected: false,
    ),
    MenuItem(
      id: 'alexandrian_liver',
      name: 'Alexandrian Liver',
      description:
          'Spicy pan-fried beef liver with garlic, green chilies, and cumin, served with fresh tahini and bread.',
      tags: ['Quick Prep', '15m Prep'],
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAWmZ0TP5QE7T2KMzaEhQnSAq8aS7CloDHcMk4gBJu73E1E8pDxVIjM1PQgm4Fx89A3wO_nJIRjB-CbXZI68IRA92_jecsJdGyy3rS99VBjipbm2oH3UKJNwktSQcLu4-xgjHmdQhlb4OFzkg8wS9DTSgF3AgpbyT3x216u2RP7tw3WhUnLjoCyI_0I7EUZBZZokzubPrdGiH8yCJzigKH9eTeOTG4ShVUZHkeNh_jxy3wuBCnzhFIy2WU-szcbiS8yHavh59QvTuM',
      isSelected: true,
    ),
  ];

  int get selectedCount => menuItems.where((item) => item.isSelected).length;

  void _toggleSelection(String itemId) {
    setState(() {
      final index = menuItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        menuItems[index].isSelected = !menuItems[index].isSelected;
      }
    });
  }

  void _handleFinish() {
    final selectedItems = menuItems.where((item) => item.isSelected).toList();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${selectedItems.length} menu items'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(colorScheme),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(colorScheme),
                    const SizedBox(height: 24),
                    // Stepper (Desktop only)
                    _buildStepper(colorScheme),
                    const SizedBox(height: 32),
                    // Menu Section
                    _buildMenuSection(colorScheme),
                    // Bottom Spacer
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            // Bottom Action Bar
            _buildBottomActionBar(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(ColorScheme colorScheme) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left section
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  color: colorScheme.primary,
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Savora Partner',
                  style: _getTextStyle('headline-lg').copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            // Right section
            Row(
              children: [
                // Step indicator (desktop)
                if (MediaQuery.of(context).size.width > 768)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      'Step 3 of 3',
                      style: _getTextStyle('label-lg').copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.help_outline),
                  color: colorScheme.primary,
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mobile step indicator
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Step 3 of 3',
            style: _getTextStyle('label-lg').copyWith(
              color: colorScheme.secondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Text(
          'Menu Selection',
          style: _getTextStyle('display-lg').copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the standardized recipes you want to offer from your chosen categories. You can always update this later in your Partner Dashboard.',
          style: _getTextStyle('body-lg').copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(ColorScheme colorScheme) {
    if (MediaQuery.of(context).size.width < 768) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        children: [
          // Step 1: Profile
          _buildStepNode(
            label: 'Profile',
            icon: Icons.check,
            isCompleted: true,
            colorScheme: colorScheme,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: colorScheme.secondary,
            ),
          ),
          // Step 2: Categories
          _buildStepNode(
            label: 'Categories',
            icon: Icons.check,
            isCompleted: true,
            colorScheme: colorScheme,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: colorScheme.secondary,
            ),
          ),
          // Step 3: Menu
          _buildStepNode(
            label: 'Menu',
            icon: Icons.restaurant_menu,
            isCompleted: false,
            isActive: true,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required String label,
    required IconData icon,
    required bool isCompleted,
    bool isActive = false,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? colorScheme.secondary
                : isActive
                    ? colorScheme.surface
                    : colorScheme.surface,
            border: Border.all(
              color: isCompleted
                  ? colorScheme.secondary
                  : isActive
                      ? colorScheme.secondary
                      : colorScheme.outlineVariant,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              color: isCompleted
                  ? Colors.white
                  : isActive
                      ? colorScheme.secondary
                      : colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: _getTextStyle('label-md').copyWith(
            color:
                isActive ? colorScheme.secondary : colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(ColorScheme colorScheme) {
    return Column(
      children: [
        // Category Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.kebab_dining,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Egyptian Grills',
                    style: _getTextStyle('headline-md').copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '$selectedCount Items Selected',
                  style: _getTextStyle('label-md').copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Menu Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuItemCard(
                  item: item,
                  onTap: () => _toggleSelection(item.id),
                  colorScheme: colorScheme,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItemCard({
    required MenuItem item,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.isSelected
                  ? colorScheme.secondary
                  : colorScheme.outlineVariant.withOpacity(0.5),
              width: item.isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 12),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isSelected
                        ? colorScheme.secondary
                        : Colors.transparent,
                    border: Border.all(
                      color: item.isSelected
                          ? colorScheme.secondary
                          : colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: item.isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: _getTextStyle('headline-sm').copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _getTextStyle('body-sm').copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tags
                    Wrap(
                      spacing: 8,
                      children: item.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: _getTextStyle('label-md').copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.2),
                    ),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.surfaceVariant,
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.grey,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back Button (Mobile)
            if (MediaQuery.of(context).size.width < 768)
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(80, 56),
                  side: BorderSide(
                      color: colorScheme.outlineVariant.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Back',
                  style: _getTextStyle('label-lg').copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            // Spacer
            if (MediaQuery.of(context).size.width < 768)
              const SizedBox(width: 12),
            // Continue Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryFixedDim,
                  foregroundColor: colorScheme.onPrimaryFixed,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Submit Menu',
                      style: _getTextStyle('headline-sm').copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle, size: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getTextStyle(String style) {
    switch (style) {
      case 'display-lg':
        return const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.8,
        );
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

class MenuItem {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final String imageUrl;
  bool isSelected;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.imageUrl,
    this.isSelected = false,
  });
}
