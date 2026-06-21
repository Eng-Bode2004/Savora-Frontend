import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savora_app/features/chef/auth/screens/verification_theme.dart';

class SelectSpecializedCategories extends StatefulWidget {
  const SelectSpecializedCategories({super.key});

  @override
  State<SelectSpecializedCategories> createState() =>
      _SelectSpecializedCategoriesState();
}

class _SelectSpecializedCategoriesState
    extends State<SelectSpecializedCategories> {
  final List<CategoryItem> categories = [
    CategoryItem(
      id: 'egyptian_grills',
      name: 'Egyptian Grills',
      icon: Icons.outdoor_grill,
    ),
    CategoryItem(
      id: 'koshary',
      name: 'Koshary',
      icon: Icons.rice_bowl,
    ),
    CategoryItem(
      id: 'mahshi',
      name: 'Mahshi',
      icon: Icons.tapas,
    ),
    CategoryItem(
      id: 'desserts',
      name: 'Desserts',
      icon: Icons.cake,
    ),
    CategoryItem(
      id: 'shawarma',
      name: 'Shawarma',
      icon: Icons.kebab_dining,
    ),
    CategoryItem(
      id: 'bakery',
      name: 'Bakery & Bread',
      icon: Icons.bakery_dining,
    ),
    CategoryItem(
      id: 'beverages',
      name: 'Beverages',
      icon: Icons.local_cafe,
    ),
    CategoryItem(
      id: 'healthy_salads',
      name: 'Healthy & Salads',
      icon: Icons.eco,
    ),
  ];

  final Set<String> selectedCategories = {};
  bool isContinueEnabled = false;

  void _toggleCategory(String categoryId) {
    setState(() {
      if (selectedCategories.contains(categoryId)) {
        selectedCategories.remove(categoryId);
      } else {
        selectedCategories.add(categoryId);
      }
      isContinueEnabled = selectedCategories.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kVfBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildCategoryGrid(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: kVfWhite,
        border: Border(
          bottom: BorderSide(color: kVfBorder.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: kVfDarkText,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Text(
            'Choose Items',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kVfDarkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What will you be cooking today?',
          style: _getTextStyle('display-lg').copyWith(
            color: kVfDarkText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your culinary expertise to see standardized recipes, packaging requirements, and suggested pricing for your region.',
          style: _getTextStyle('body-lg').copyWith(
            color: kVfMutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000
            ? 4
            : constraints.maxWidth > 600
                ? 3
                : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategories.contains(category.id);

            return _buildCategoryCard(
              category: category,
              isSelected: isSelected,
              onTap: () => _toggleCategory(category.id),
    
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required CategoryItem category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? kVfAccent.withValues(alpha: 0.12) : kVfBackground,
            border: Border.all(
              color:
                  isSelected ? kVfAccent : kVfBorder,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kVfAccent.withValues(alpha: 0.3) /* was primaryFixedDim */.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: -10,
                    ),
                  ]
                : null,
          ),
          transform: Matrix4.identity()..translate(0, isSelected ? -2 : 0),
          child: Stack(
            children: [
              // Selection Icon
              Positioned(
                top: 12,
                right: 12,
                child: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? kVfAccent
                      : kVfBorder,
                  size: 24,
                ),
              ),
              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: kVfBorder,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      color: isSelected
                          ? kVfAccent
                          : kVfMutedText,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: _getTextStyle('label-lg').copyWith(
                      color: kVfDarkText,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: kVfBackground.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: kVfBorder.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Selection Count (Desktop only)
            if (MediaQuery.of(context).size.width > 768)
              Text(
                '${selectedCategories.length} categories selected',
                style: _getTextStyle('label-md').copyWith(
                  color: kVfMutedText,
                ),
              ),
            // Continue Button
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (!isContinueEnabled) return;
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isContinueEnabled
                      ? kVfAccent
                      : kVfBorder,
                  foregroundColor: isContinueEnabled
                      ? kVfDarkText
                      : kVfMutedText,
                  disabledBackgroundColor: kVfBorder,
                  disabledForegroundColor: kVfMutedText,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: isContinueEnabled ? 4 : 0,
                ),
                child: Text(
                  'Continue Setup',
                  style: _getTextStyle('label-lg'),
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

// ==================== الصفحة الثانية ====================
class NextStepScreen extends StatelessWidget {
  const NextStepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kVfBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildNextTopAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNextHeader(),
                    const SizedBox(height: 24),
                    _buildNextContent(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            _buildNextBottomActionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNextTopAppBar(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: kVfBackground.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: kVfBorder.withOpacity(0.3),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // زر رجوع
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: kVfDarkText,
            ),
            const SizedBox(width: 8),
            // Brand Logo
            Text(
              'Savora Partner',
              style: _getTextStyle('headline-lg').copyWith(
                color: kVfAccent,
              ),
            ),
            const Spacer(),
            // Step Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: kVfBorder,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                'Step 2 of 3',
                style: _getTextStyle('label-md').copyWith(
                  color: kVfMutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about your kitchen',
          style: _getTextStyle('display-lg').copyWith(
            color: kVfDarkText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide details about your kitchen setup, equipment, and capacity to help us personalize your experience.',
          style: _getTextStyle('body-lg').copyWith(
            color: kVfMutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildNextContent() {
    return Column(
      children: [
        // بطاقة معلومات
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kVfAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: kVfAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: kVfAccent,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Please fill in the required information to complete your profile setup.',
                  style: _getTextStyle('body-md').copyWith(
                    color: kVfMutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // نموذج بسيط
        _buildFormField(
          label: 'Kitchen Name',
          hint: 'Enter your kitchen name',

        ),
        const SizedBox(height: 16),
        _buildFormField(
          label: 'Kitchen Type',
          hint: 'e.g., Restaurant, Home Kitchen, Food Truck',

        ),
        const SizedBox(height: 16),
        _buildFormField(
          label: 'Years of Experience',
          hint: 'Enter number of years',

        ),
        const SizedBox(height: 24),
        // اختيارات إضافية
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: kVfBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Do you have a commercial kitchen license?',
                style: _getTextStyle('label-lg').copyWith(
                  color: kVfDarkText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRadioOption(
                    label: 'Yes',
                    value: 'yes',
                    groupValue: 'yes',
          
                  ),
                  const SizedBox(width: 16),
                  _buildRadioOption(
                    label: 'No',
                    value: 'no',
                    groupValue: 'yes',
          
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _getTextStyle('label-lg').copyWith(
            color: kVfDarkText,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: kVfBorder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: kVfAccent,
                width: 2,
              ),
            ),
          ),
          style: _getTextStyle('body-md').copyWith(
            color: kVfDarkText,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String label,
    required String value,
    required String groupValue,
  }) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: groupValue,
          onChanged: (val) {},
          activeColor: kVfAccent,
        ),
        Text(
          label,
          style: _getTextStyle('body-md').copyWith(
            color: kVfDarkText,
          ),
        ),
      ],
    );
  }

  Widget _buildNextBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: kVfBackground.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: kVfBorder.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // زر الرجوع
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(100, 56),
                side: BorderSide(color: kVfBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: kVfMutedText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Back',
                    style: _getTextStyle('label-lg').copyWith(
                      color: kVfMutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // زر المتابعة
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Proceeding to final step!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kVfAccent,
                  foregroundColor: kVfDarkText,
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
                      'Next Step',
                      style: _getTextStyle('label-lg'),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
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

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;

  CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
  });
}
