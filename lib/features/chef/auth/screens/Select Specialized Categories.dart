import 'package:flutter/material.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/state/providers/auth_provider.dart';
import 'package:savora_app/features/chef/auth/screens/verification_theme.dart';

enum _View { categories, subcategories, dishes }

class SelectSpecializedCategories extends StatefulWidget {
  const SelectSpecializedCategories({super.key});

  @override
  State<SelectSpecializedCategories> createState() =>
      _SelectSpecializedCategoriesState();
}

class _SelectSpecializedCategoriesState
    extends State<SelectSpecializedCategories> {
  _View _currentView = _View.categories;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subcategories = [];
  List<Map<String, dynamic>> _dishes = [];

  Map<String, dynamic>? _currentCategory;
  Map<String, dynamic>? _currentSubcategory;

  final Set<String> _selectedDishIds = {};

  bool _isLoading = true;
  bool _isSaving = false;
  bool _subLoading = false;
  bool _dishLoading = false;
  String? _error;
  String _lang = 'english';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<String> _getLanguageCode(Map<String, dynamic> data) {
    final d = data['data'];
    if (d is Map<String, dynamic> && d['language'] is String) {
      return Future.value(d['language'] as String);
    }
    if (data['language'] is String) {
      return Future.value(data['language'] as String);
    }
    return Future.value('en');
  }

  String _mapLang(String raw) {
    final code = raw.trim().toLowerCase();
    if (code == 'en' || code == 'english') return 'english';
    if (code == 'ar' || code == 'arabic') return 'arabic';
    if (code == 'es' || code == 'spanish') return 'spanish';
    if (code == 'fr' || code == 'french') return 'french';
    if (code == 'zh' || code == 'chinese') return 'chinese';
    return 'english';
  }

  Future<List<Map<String, dynamic>>> _extractList(Map<String, dynamic> data) {
    if (data['response'] is List) return Future.value(List<Map<String, dynamic>>.from(data['response']));
    if (data['dishes'] is List) return Future.value(List<Map<String, dynamic>>.from(data['dishes']));
    if (data['data'] is List) return Future.value(List<Map<String, dynamic>>.from(data['data']));
    if (data['categories'] is List) return Future.value(List<Map<String, dynamic>>.from(data['categories']));
    if (data['records'] is List) return Future.value(List<Map<String, dynamic>>.from(data['records']));
    if (data['result'] is List) return Future.value(List<Map<String, dynamic>>.from(data['result']));
    return Future.value([]);
  }

  String _name(dynamic item) {
    if (item is! Map<String, dynamic>) return '';
    final langKey = '${_lang}_name';
    return (item[langKey] as String?) ??
        (item['name'] as String?) ??
        (item['english_name'] as String?) ??
        (item['_id'] as String?) ??
        '';
  }

  String _imageUrl(dynamic item) {
    if (item is! Map<String, dynamic>) return '';
    return (item['image'] as String?) ?? '';
  }

  Future<void> _loadCategories() async {
    try {
      final profileId = authState.profileId;
      final userId = authState.userId;

      if (profileId == null || userId == null) {
        setState(() { _error = 'User or profile ID not found. Please log in again.'; _isLoading = false; });
        return;
      }

      await SavoraApi.getChiefProfile(profileId);

      final langData = await SavoraApi.getUserLanguage(userId);
      final rawLang = await _getLanguageCode(langData);
      _lang = _mapLang(rawLang);

      final catData = await SavoraApi.getCategoriesByLanguage(_lang);
      final list = await _extractList(catData);

      setState(() { _categories = list; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _isLoading = false; });
    }
  }

  Future<void> _onCategoryTap(Map<String, dynamic> cat) async {
    final catId = cat['_id'] as String?;
    if (catId == null) return;

    setState(() { _currentView = _View.subcategories; _currentCategory = cat; _subLoading = true; _subcategories = []; });

    try {
      final subData = await SavoraApi.getSubcategoriesByCategory(catId);
      final list = await _extractList(subData);
      if (mounted) setState(() { _subcategories = list; _subLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _subLoading = false; });
    }
  }

  Future<void> _onSubcategoryTap(Map<String, dynamic> sub) async {
    final subId = sub['_id'] as String?;
    if (subId == null) return;

    setState(() { _currentView = _View.dishes; _currentSubcategory = sub; _dishLoading = true; _dishes = []; });

    try {
      final dishData = await SavoraApi.getDishesBySubcategory(subId);
      final list = await _extractList(dishData);
      if (mounted) setState(() { _dishes = list; _dishLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _dishLoading = false; });
    }
  }

  Future<void> _onContinue() async {
    if (_selectedDishIds.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final profileId = authState.profileId;
      if (profileId == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile ID not found'), backgroundColor: Colors.red));
        setState(() => _isSaving = false);
        return;
      }

      for (final dishId in _selectedDishIds) {
        await SavoraApi.setPreferredDish(chiefId: profileId, dishId: dishId, preferred: true);
      }

      await SavoraApi.verifyStep(profileId: profileId, step: 'Items_Can_Make_Status', status: 'verified');

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
      }
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kVfBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildBody()),
                _buildBottomActionBar(),
              ],
            ),
            if (_isSaving)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: kVfAccent),
                      SizedBox(height: 16),
                      Text('Saving your selections...', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: kVfAccent));
    if (_error != null) return _buildErrorState();

    switch (_currentView) {
      case _View.categories:
        return _buildCategoriesList();
      case _View.subcategories:
        return _buildSubcategoriesList();
      case _View.dishes:
        return _buildDishesList();
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: kVfMutedText),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: kVfMutedText, fontSize: 16, fontFamily: 'DM Sans')),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () { setState(() { _isLoading = true; _error = null; }); _loadCategories(); },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: kVfAccent, foregroundColor: kVfDarkText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    String title;
    VoidCallback? onBack;

    switch (_currentView) {
      case _View.categories:
        title = 'Choose Items';
        onBack = () => Navigator.of(context).pop();
        break;
      case _View.subcategories:
        title = _name(_currentCategory);
        onBack = () => setState(() { _currentView = _View.categories; _currentCategory = null; _subcategories = []; });
        break;
      case _View.dishes:
        title = _name(_currentSubcategory);
        onBack = () => setState(() { _currentView = _View.subcategories; _currentSubcategory = null; _dishes = []; });
        break;
    }

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: kVfWhite,
        border: Border(bottom: BorderSide(color: kVfBorder.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: kVfDarkText,
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 18, fontWeight: FontWeight.w700, color: kVfDarkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    if (_categories.isEmpty) {
      return const Center(child: Text('No categories available', style: TextStyle(color: kVfMutedText, fontFamily: 'DM Sans', fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final image = _imageUrl(cat);
        final name = _name(cat);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _onCategoryTap(cat),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: image.isNotEmpty
                    ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover)
                    : null,
                color: image.isEmpty ? kVfBorder : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(16),
                child: Text(
                  name,
                  style: const TextStyle(fontFamily: 'DM Sans', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubcategoriesList() {
    if (_subLoading) return const Center(child: CircularProgressIndicator(color: kVfAccent));

    if (_subcategories.isEmpty) {
      return const Center(child: Text('No subcategories found', style: TextStyle(color: kVfMutedText, fontFamily: 'DM Sans', fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _subcategories.length,
      itemBuilder: (context, index) {
        final sub = _subcategories[index];
        final image = _imageUrl(sub);
        final name = _name(sub);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _onSubcategoryTap(sub),
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: image.isNotEmpty
                    ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover)
                    : null,
                color: image.isEmpty ? kVfBorder : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(14),
                child: Text(
                  name,
                  style: const TextStyle(fontFamily: 'DM Sans', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDishesList() {
    if (_dishLoading) return const Center(child: CircularProgressIndicator(color: kVfAccent));

    if (_dishes.isEmpty) {
      return const Center(child: Text('No dishes found', style: TextStyle(color: kVfMutedText, fontFamily: 'DM Sans', fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _dishes.length,
      itemBuilder: (context, index) {
        final dish = _dishes[index];
        final dishId = dish['_id'] as String? ?? '';
        final image = _imageUrl(dish);
        final name = _name(dish);
        final isSelected = _selectedDishIds.contains(dishId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) { _selectedDishIds.remove(dishId); }
                else { _selectedDishIds.add(dishId); }
              });
            },
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? kVfAccent : kVfBorder, width: isSelected ? 2 : 1),
                color: isSelected ? kVfAccent.withValues(alpha: 0.08) : kVfWhite,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                    child: image.isNotEmpty
                        ? Image.network(image, width: 90, height: 90, fit: BoxFit.cover)
                        : Container(width: 90, height: 90, color: kVfBorder, child: Icon(Icons.restaurant, color: kVfMutedText)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w600, color: kVfDarkText),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? kVfAccent : kVfBorder,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar() {
    final count = _selectedDishIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kVfBackground.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: kVfBorder.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: count > 0 && !_isSaving ? _onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: count > 0 ? kVfAccent : kVfBorder,
              foregroundColor: count > 0 ? kVfDarkText : kVfMutedText,
              disabledBackgroundColor: kVfBorder,
              disabledForegroundColor: kVfMutedText,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: count > 0 ? 4 : 0,
            ),
            child: _isSaving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: kVfDarkText))
                : Text(
                    count > 0 ? 'Confirm $count dish${count > 1 ? "es" : ""}' : 'Select dishes to continue',
                    style: const TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }
}
