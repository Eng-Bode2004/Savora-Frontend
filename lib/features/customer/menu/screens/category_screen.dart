import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../services/menu_service.dart';
import 'dish_detail_screen.dart';

const _kAccent = Color(0xFFE8A838);
const _kAccentLight = Color(0xFFF0B040);
const _kAccentDark = Color(0xFFD4952E);

enum _MenuView { categories, subcategories, dishes }

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  _MenuView _view = _MenuView.categories;
  List<MenuItem> _categories = [];
  List<MenuItem> _subcategories = [];
  List<MenuItem> _dishes = [];
  MenuItem? _currentCategory;
  MenuItem? _currentSubcategory;
  bool _isLoading = true;
  bool _subLoading = false;
  bool _dishLoading = false;
  String? _error;

  bool get _isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  Color get _bgColor => _isDarkMode ? AppColors.espresso : const Color(0xFFFDFBF7);
  Color get _textColor => _isDarkMode ? AppColors.cream : const Color(0xFF1A1410);
  Color get _subTextColor => _isDarkMode ? AppColors.creamDim : const Color(0xFF8A8A8A);
  Color get _cardColor => _isDarkMode ? AppColors.glass : Colors.white;
  Color get _shadowColor => _isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await MenuService.loadLanguage();
      final cats = await MenuService.getCategories();
      if (mounted) setState(() { _categories = cats; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  Future<void> _onCategoryTap(MenuItem cat) async {
    setState(() { _view = _MenuView.subcategories; _currentCategory = cat; _subLoading = true; _subcategories = []; });
    try {
      final subs = await MenuService.getSubcategories(cat.id);
      if (mounted) setState(() { _subcategories = subs; _subLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _subLoading = false; });
    }
  }

  Future<void> _onSubcategoryTap(MenuItem sub) async {
    setState(() { _view = _MenuView.dishes; _currentSubcategory = sub; _dishLoading = true; _dishes = []; });
    try {
      final dishes = await MenuService.getDishes(sub.id);
      if (mounted) setState(() { _dishes = dishes; _dishLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _dishLoading = false; });
    }
  }

  void _openDishDetail(MenuItem dish) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ProductDetailScreen(
          dishId: dish.id,
          name: dish.name,
          description: dish.description ?? 'A delightful dish prepared just for you.',
          basePrice: (dish.price ?? 0).toInt(),
          rating: dish.rating ?? 0,
          image: dish.image ?? '',
          tone: _kAccent,
          chefId: dish.chefId,
        ),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = AppLocalizations.of(context).locale.languageCode == 'ar';
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    String title;
    VoidCallback? onBack;

    switch (_view) {
      case _MenuView.categories:
        title = 'Menu';
        onBack = () => Navigator.of(context).pop();
        break;
      case _MenuView.subcategories:
        title = _currentCategory?.name ?? '';
        onBack = () => setState(() { _view = _MenuView.categories; _currentCategory = null; _subcategories = []; });
        break;
      case _MenuView.dishes:
        title = _currentSubcategory?.name ?? '';
        onBack = () => setState(() { _view = _MenuView.subcategories; _currentSubcategory = null; _dishes = []; });
        break;
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(bottom: BorderSide(color: _subTextColor.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: _textColor,
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'DM Sans', fontSize: 18, fontWeight: FontWeight.w700, color: _textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: _kAccent));
    if (_error != null) return _buildError();

    switch (_view) {
      case _MenuView.categories:
        return _buildCategoriesGrid();
      case _MenuView.subcategories:
        return _buildSubcategoriesGrid();
      case _MenuView.dishes:
        return _buildDishesList();
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: _subTextColor),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: _subTextColor, fontSize: 16, fontFamily: 'DM Sans')),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent, foregroundColor: const Color(0xFF2C1810)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    if (_categories.isEmpty) {
      return Center(child: Text('No categories available', style: TextStyle(color: _subTextColor, fontFamily: 'DM Sans', fontSize: 16)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, i) => _buildCategoryCard(_categories[i]),
    );
  }

  Widget _buildCategoryCard(MenuItem cat) {
    return GestureDetector(
      onTap: () => _onCategoryTap(cat),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: _shadowColor, blurRadius: 14, offset: const Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            cat.image != null && cat.image!.isNotEmpty
                ? Image.network(cat.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _catPlaceholder())
                : _catPlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                ),
              ),
            ),
            Positioned(
              left: 12, right: 12, bottom: 12,
              child: Text(
                cat.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_kAccentLight.withValues(alpha: 0.3), _kAccentDark.withValues(alpha: 0.2)]),
      ),
      child: const Center(child: Icon(Icons.restaurant_menu_rounded, size: 48, color: _kAccent)),
    );
  }

  Widget _buildSubcategoriesGrid() {
    if (_subLoading) return const Center(child: CircularProgressIndicator(color: _kAccent));
    if (_subcategories.isEmpty) {
      return Center(child: Text('No subcategories found', style: TextStyle(color: _subTextColor, fontFamily: 'DM Sans', fontSize: 16)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: _subcategories.length,
      itemBuilder: (context, i) => _buildSubcategoryCard(_subcategories[i]),
    );
  }

  Widget _buildSubcategoryCard(MenuItem sub) {
    return GestureDetector(
      onTap: () => _onSubcategoryTap(sub),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _shadowColor, blurRadius: 12, offset: const Offset(0, 5))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            sub.image != null && sub.image!.isNotEmpty
                ? Image.network(sub.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _subPlaceholder())
                : _subPlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),
            Positioned(
              left: 10, right: 10, bottom: 10,
              child: Text(
                sub.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_kAccentLight.withValues(alpha: 0.2), _kAccentDark.withValues(alpha: 0.15)]),
      ),
      child: const Center(child: Icon(Icons.category_rounded, size: 36, color: _kAccent)),
    );
  }

  Widget _buildDishesList() {
    if (_dishLoading) return const Center(child: CircularProgressIndicator(color: _kAccent));
    if (_dishes.isEmpty) {
      return Center(child: Text('No dishes available', style: TextStyle(color: _subTextColor, fontFamily: 'DM Sans', fontSize: 16)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: _dishes.length,
      itemBuilder: (context, i) => _buildDishCard(_dishes[i]),
    );
  }

  Widget _buildDishCard(MenuItem dish) {
    final hasImage = dish.image != null && dish.image!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _openDishDetail(dish),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _subTextColor.withValues(alpha: 0.12)),
            boxShadow: [BoxShadow(color: _shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                child: hasImage
                    ? Image.network(dish.image!, width: 110, height: 110, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _dishImagePlaceholder())
                    : _dishImagePlaceholder(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w700, color: _textColor),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          if (dish.rating != null) ...[
                            const Icon(Icons.star_rounded, size: 16, color: _kAccent),
                            const SizedBox(width: 3),
                            Text(dish.rating!.toStringAsFixed(1), style: TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w600, color: _textColor)),
                            const SizedBox(width: 8),
                          ],
                          if (dish.price != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _kAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'EGP ${dish.price!.toInt()}',
                                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w700, color: _kAccentDark),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded, color: _kAccent, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dishImagePlaceholder() {
    return Container(
      width: 110, height: 110,
      color: _subTextColor.withValues(alpha: 0.1),
      child: const Icon(Icons.restaurant_rounded, size: 36, color: _kAccent),
    );
  }
}
