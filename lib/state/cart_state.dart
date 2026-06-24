import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartAddOn {
  final String name;
  final int price;

  CartAddOn({required this.name, required this.price});

  Map<String, dynamic> toJson() => {'name': name, 'price': price};

  factory CartAddOn.fromJson(Map<String, dynamic> json) => CartAddOn(
        name: json['name'] as String,
        price: json['price'] as int,
      );
}

class CartItem {
  final String dishId;
  final String name;
  final int price;
  int qty;
  final Color tone;
  final String emoji;
  final List<CartAddOn> addOns;
  final String? image;

  CartItem({
    this.dishId = '',
    required this.name,
    required this.price,
    required this.qty,
    required this.tone,
    this.emoji = '🍽',
    this.addOns = const [],
    this.image,
  });

  int get unitPrice => price;
  int get totalPrice => unitPrice * qty;

  Map<String, dynamic> toJson() => {
        'dishId': dishId,
        'name': name,
        'price': price,
        'qty': qty,
        'tone': tone.toARGB32(),
        'emoji': emoji,
        'addOns': addOns.map((a) => a.toJson()).toList(),
        'image': image,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        dishId: json['dishId'] as String? ?? '',
        name: json['name'] as String,
        price: json['price'] as int,
        qty: json['qty'] as int,
        tone: Color(json['tone'] as int),
        emoji: json['emoji'] as String? ?? '🍽',
        addOns: (json['addOns'] as List<dynamic>?)
                ?.map((a) => CartAddOn.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
        image: json['image'] as String?,
      );
}

class CartState extends ChangeNotifier {
  List<CartItem> _items = [];
  String? _chefId;
  String? _chefName;
  Future<void>? _loadFuture;

  CartState() {
    _loadFuture = _loadFromStorage();
  }

  List<CartItem> get items => _items;
  String? get chefId => _chefId;
  String? get chefName => _chefName;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.qty);
  int get total => _items.fold(0, (sum, i) => sum + i.totalPrice);

  bool get isEmpty => _items.isEmpty;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString('savora_cart_items');
      if (dataStr != null) {
        final Map<String, dynamic> data = jsonDecode(dataStr);
        _chefId = data['chefId'] as String?;
        _chefName = data['chefName'] as String?;
        final list = data['items'] as List<dynamic>? ?? [];
        _items = list.map((x) => CartItem.fromJson(x as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading cart: $e");
    }
  }

  Future<void> ensureLoaded() async {
    if (_loadFuture != null) {
      await _loadFuture;
      _loadFuture = null;
    }
  }

  Future<void> _ensureLoaded() async {
    await ensureLoaded();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = jsonEncode({
        'chefId': _chefId,
        'chefName': _chefName,
        'items': _items.map((x) => x.toJson()).toList(),
      });
      await prefs.setString('savora_cart_items', dataStr);
    } catch (e) {
      debugPrint("Error saving cart: $e");
    }
  }

  void setChef({required String id, required String name}) {
    _chefId = id;
    _chefName = name;
    _saveToStorage();
    notifyListeners();
  }

  Future<void> addItem(CartItem item) async {
    await _ensureLoaded();
    final index = _items.indexWhere((x) => x.dishId == item.dishId);
    if (index != -1) {
      _items[index].qty += item.qty;
    } else {
      _items.add(item);
    }
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> removeItem(String dishId) async {
    await _ensureLoaded();
    _items.removeWhere((x) => x.dishId == dishId);
    if (_items.isEmpty) {
      _chefId = null;
      _chefName = null;
    }
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> changeQty(String dishId, int delta) async {
    await _ensureLoaded();
    final index = _items.indexWhere((x) => x.dishId == dishId);
    if (index != -1) {
      _items[index].qty += delta;
      if (_items[index].qty <= 0) {
        _items.removeAt(index);
      }
      if (_items.isEmpty) {
        _chefId = null;
        _chefName = null;
      }
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> clearCart() async {
    await _ensureLoaded();
    _items.clear();
    _chefId = null;
    _chefName = null;
    notifyListeners();
    await _saveToStorage();
  }
}

final CartState cartState = CartState();
