import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../state/providers/auth_provider.dart';

class SavoraApi {
  // Set to your local IP when testing OTP locally (e.g. 'http://192.168.1.100:5003')
  // Set to null to use Railway production
  // static const String? localOtpUrl = null;
  static const String? localOtpUrl = 'http://192.168.1.6:5003';

  static String get otpBase => localOtpUrl != null
      ? '$localOtpUrl/api/v1/otp'
      : 'https://savoraotp-services-production.up.railway.app/api/v1/otp';

  static const String userBase    = 'https://savorauser-services-production.up.railway.app/api/v1/users';
  static const String roleBase    = 'https://savorarole-services-production.up.railway.app/api/v1/roles';
  static const String chiefBase   = 'https://savora-chiefprofileservices-production.up.railway.app/api/v2/chief-profile';

  static const Duration _timeout = Duration(seconds: 15);

  static Map<String, String> get _headers => {'Content-Type': 'application/json'};

  static Map<String, String> get _authHeaders {
    final h = <String, String>{'Content-Type': 'application/json'};
    final token = authState.token;
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Future<http.Response> _post(String url, {Map<String, String>? headers, Object? body}) =>
      http.post(Uri.parse(url), headers: headers, body: body).timeout(_timeout);

  static Future<http.Response> _get(String url, {Map<String, String>? headers}) =>
      http.get(Uri.parse(url), headers: headers).timeout(_timeout);

  static Future<http.Response> _put(String url, {Map<String, String>? headers, Object? body}) =>
      http.put(Uri.parse(url), headers: headers, body: body).timeout(_timeout);

  // ── Auth ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> loginUser({
    required String identifier,
    required String password,
  }) async {
    final res = await _post('$userBase/login', headers: _headers, body: jsonEncode({
      'identifier': identifier,
      'password': password,
    }));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> registerEmail({
    required String email,
    required String password,
    required String confirmPassword,
    String? username,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    };
    if (username != null && username.isNotEmpty) body['username'] = username;

    final res = await _post('$userBase/register/email', headers: _headers, body: jsonEncode(body));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return data;
    throw Exception(_extractError(data));
  }

  static Future<String> generateUsername() async {
    final res = await _get('$userBase/generate-username', headers: _headers);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      return data['data']?['username'] as String? ?? '';
    }
    throw Exception(_extractError(data));
  }

  // ── OTP ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> sendOtpEmail({
    required String email,
    required String userId,
  }) async {
    final res = await _post('$otpBase/send/email', headers: _headers, body: jsonEncode({'email': email, 'userID': userId}));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> sendOtpPhone({
    required String phone,
    required String userId,
  }) async {
    final res = await _post('$otpBase/send/phone', headers: _headers, body: jsonEncode({'phone': phone, 'userID': userId}));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> sendOtpWhatsApp({
    required String phone,
    required String userId,
  }) async {
    final res = await _post('$otpBase/send/whatsapp', headers: _headers, body: jsonEncode({'phone': phone, 'userID': userId}));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String otpCode,
  }) async {
    final res = await _post('$otpBase/verify', headers: _headers, body: jsonEncode({'userID': userId, 'otp_code': otpCode}));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Roles ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getRoleById(String id) async {
    final res = await _get('$roleBase/$id', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<List<Map<String, dynamic>>> getRolesByLanguage(String lang) async {
    final res = await _get('$roleBase/language/$lang', headers: _headers);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      final list = data['data'];
      if (list is List) return list.cast<Map<String, dynamic>>();
      return [];
    }
    throw Exception(_extractError(data));
  }

  // ── User Management ───────────────────────────────────────────────────

  static Future<Map<String, dynamic>> assignRole({
    required String userId,
    required String roleId,
  }) async {
    final res = await _put('$userBase/$userId/role', headers: _authHeaders, body: jsonEncode({'roleId': roleId}));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> assignProfile({
    required String userId,
    required String profileId,
  }) async {
    final res = await _put('$userBase/$userId/profile', headers: _authHeaders, body: jsonEncode({'profileId': profileId}));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getUserLanguage(String userId) async {
    final res = await _get('$userBase/$userId/language', headers: _authHeaders);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> changeUserLanguage({
    required String userId,
    required String language,
  }) async {
    final res = await _put('$userBase/$userId/language', headers: _authHeaders, body: jsonEncode({'language': language}));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Chief Profile ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createChiefProfile(String name) async {
    final res = await _post(chiefBase, headers: _headers, body: jsonEncode({'name': name}));

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getChiefProfile(String id) async {
    final res = await _get('$chiefBase/$id', headers: _authHeaders);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  static String _extractError(Map<String, dynamic> data) {
    if (data['details'] != null && data['details'] is List) {
      return (data['details'] as List).join('; ');
    }
    if (data['error'] is String) return data['error'] as String;
    if (data['message'] is String) return data['message'] as String;
    return 'Something went wrong';
  }
}
