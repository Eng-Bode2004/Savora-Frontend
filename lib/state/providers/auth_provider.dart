import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  String? _userId;
  String? _email;
  String? _name;
  String? _token;
  String? _roleKey;
  bool _isLoggedIn = false;

  String? get userId => _userId;
  String? get email => _email;
  String? get name => _name;
  String? get token => _token;
  String? get roleKey => _roleKey;
  bool get isLoggedIn => _isLoggedIn;

  void setUserId(String id) { _userId = id; notifyListeners(); }
  void setEmail(String e) { _email = e; notifyListeners(); }
  void setName(String n) { _name = n; notifyListeners(); }
  void setToken(String t) { _token = t; notifyListeners(); }
  void setRoleKey(String r) { _roleKey = r; notifyListeners(); }

  void login({
    required String userId,
    String? email,
    String? token,
  }) {
    _userId = userId;
    _email = email;
    _token = token;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _email = null;
    _name = null;
    _token = null;
    _roleKey = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void reset() {
    _userId = null;
    _email = null;
    _name = null;
    _token = null;
    _roleKey = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}

final AuthState authState = AuthState();
