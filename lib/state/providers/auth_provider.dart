import 'package:flutter/foundation.dart';

class AuthState extends ChangeNotifier {
  String? _userId;
  String? _email;
  String? _name;
  String? _token;
  String? _roleKey;
  String? _profileId;
  Map<String, dynamic>? _profileData;
  bool _isLoggedIn = false;

  String? get userId => _userId;
  String? get email => _email;
  String? get name => _name;
  String? get token => _token;
  String? get roleKey => _roleKey;
  String? get profileId => _profileId;
  Map<String, dynamic>? get profileData => _profileData;
  bool get isLoggedIn => _isLoggedIn;
  bool get isVerified => _roleKey == 'Chef' ? (_profileData?['Is_Verified'] == true) : true;

  void setUserId(String id) { _userId = id; notifyListeners(); }
  void setEmail(String e) { _email = e; notifyListeners(); }
  void setName(String n) { _name = n; notifyListeners(); }
  void setToken(String t) { _token = t; notifyListeners(); }
  void setRoleKey(String r) { _roleKey = r; notifyListeners(); }
  void setProfileId(String id) { _profileId = id; notifyListeners(); }
  void setProfileData(Map<String, dynamic> d) { _profileData = d; notifyListeners(); }

  void login({
    required String userId,
    String? email,
    String? token,
    String? roleKey,
  }) {
    _userId = userId;
    _email = email;
    _token = token;
    _roleKey = roleKey;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _email = null;
    _name = null;
    _token = null;
    _roleKey = null;
    _profileId = null;
    _profileData = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void reset() {
    _userId = null;
    _email = null;
    _name = null;
    _token = null;
    _roleKey = null;
    _profileId = null;
    _profileData = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}

final AuthState authState = AuthState();
