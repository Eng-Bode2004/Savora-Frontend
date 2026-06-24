import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/state/providers/auth_provider.dart';

class MenuItem {
  final String id;
  final String name;
  final String? image;
  final String? description;
  final double? price;
  final double? rating;
  final String? chefId;
  final Map<String, dynamic> raw;

  MenuItem({
    required this.id,
    required this.name,
    this.image,
    this.description,
    this.price,
    this.rating,
    this.chefId,
    required this.raw,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map, String lang) {
    final langKey = '${lang}_name';
    return MenuItem(
      id: map['_id'] as String? ?? '',
      name: (map[langKey] as String?) ??
          (map['name'] as String?) ??
          (map['english_name'] as String?) ??
          '',
      image: map['image'] as String?,
      description: map['description'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      rating: (map['rating'] as num?)?.toDouble(),
      chefId: (map['chef_id'] as String?) ?? (map['chefId'] as String?),
      raw: map,
    );
  }
}

class MenuService {
  static String _lang = 'english';

  static String _mapLang(String raw) {
    final code = raw.trim().toLowerCase();
    if (code == 'en' || code == 'english') return 'english';
    if (code == 'ar' || code == 'arabic') return 'arabic';
    if (code == 'es' || code == 'spanish') return 'spanish';
    if (code == 'fr' || code == 'french') return 'french';
    if (code == 'zh' || code == 'chinese') return 'chinese';
    return 'english';
  }

  static Future<void> loadLanguage() async {
    final userId = authState.userId;
    if (userId == null) return;
    try {
      final data = await SavoraApi.getUserLanguage(userId);
      final d = data['data'];
      final raw = (d is Map<String, dynamic> && d['language'] is String)
          ? d['language'] as String
          : (data['language'] as String? ?? 'en');
      _lang = _mapLang(raw);
    } catch (_) {
      _lang = 'english';
    }
  }

  static List<MenuItem> _extractItems(Map<String, dynamic> data) {
    final list = (data['response'] ?? data['dishes'] ?? data['data'] ?? data['categories'] ?? data['records'] ?? data['result']);
    if (list is List) {
      return list.map((e) => MenuItem.fromMap(e as Map<String, dynamic>, _lang)).toList();
    }
    return [];
  }

  static Future<List<MenuItem>> getCategories() async {
    final data = await SavoraApi.getCategoriesByLanguage(_lang);
    return _extractItems(data);
  }

  static Future<List<MenuItem>> getSubcategories(String categoryId) async {
    final data = await SavoraApi.getSubcategoriesByCategory(categoryId);
    return _extractItems(data);
  }

  static Future<List<MenuItem>> getDishes(String subcategoryId) async {
    final data = await SavoraApi.getDishesBySubcategory(subcategoryId);
    return _extractItems(data);
  }

  static Future<List<MenuItem>> getRecommendedDishes() async {
    final data = await SavoraApi.getDishesByLanguage(_lang);
    final all = _extractItems(data);
    all.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return all.take(6).toList();
  }

  static Future<List<MenuItem>> getPopularDishes() async {
    final data = await SavoraApi.getAllDishes();
    final all = _extractItems(data);
    all.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return all.take(4).toList();
  }
}
