import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String name;
  final int price;
  int qty;
  final Color tone;
  final String emoji;

  CartItem({
    required this.name,
    required this.price,
    required this.qty,
    required this.tone,
    required this.emoji,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'qty': qty,
        'tone': tone.toARGB32(),
        'emoji': emoji,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        name: json['name'] as String,
        price: json['price'] as int,
        qty: json['qty'] as int,
        tone: Color(json['tone'] as int),
        emoji: json['emoji'] as String,
      );
}

class CartState extends ChangeNotifier {
  List<CartItem> _items = [];
  Future<void>? _loadFuture;

  CartState() {
    _loadFuture = _loadFromStorage();
  }

  List<CartItem> get items => _items;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString('savora_cart_items');
      if (dataStr != null) {
        final List<dynamic> list = jsonDecode(dataStr);
        _items = list.map((x) => CartItem.fromJson(x as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading cart: $e");
    }
  }

  Future<void> _ensureLoaded() async {
    if (_loadFuture != null) {
      await _loadFuture;
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = jsonEncode(_items.map((x) => x.toJson()).toList());
      await prefs.setString('savora_cart_items', dataStr);
    } catch (e) {
      debugPrint("Error saving cart: $e");
    }
  }

  Future<void> addItem(CartItem item) async {
    await _ensureLoaded();
    final index = _items.indexWhere((x) => x.name == item.name && x.price == item.price);
    if (index != -1) {
      _items[index].qty += item.qty;
    } else {
      _items.add(item);
    }
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> removeItem(String name) async {
    await _ensureLoaded();
    _items.removeWhere((x) => x.name == name);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> changeQty(String name, int delta) async {
    await _ensureLoaded();
    final index = _items.indexWhere((x) => x.name == name);
    if (index != -1) {
      _items[index].qty += delta;
      if (_items[index].qty <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
      await _saveToStorage();
    }
  }

  Future<void> clearCart() async {
    await _ensureLoaded();
    _items.clear();
    notifyListeners();
    await _saveToStorage();
  }
}

final CartState cartState = CartState();
