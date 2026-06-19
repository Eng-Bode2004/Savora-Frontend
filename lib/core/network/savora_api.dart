import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../state/providers/auth_provider.dart';

class SavoraApi {
  static const String userBase    = 'https://savorauser-services-production.up.railway.app/api/v1/users';
  static const String otpBase     = 'https://savoraotp-services-production.up.railway.app/api/v1/otp';
  static const String roleBase    = 'https://savorarole-services-production.up.railway.app/api/v1/roles';
  static const String chiefBase   = 'https://savora-chiefprofileservices-production.up.railway.app/api/v2/chief-profile';

  static Map<String, String> get _headers => {'Content-Type': 'application/json'};

  static Map<String, String> get _authHeaders {
    final h = <String, String>{'Content-Type': 'application/json'};
    final token = authState.token;
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ── Auth ──────────────────────────────────────────────────────────────

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

    final res = await http.post(
      Uri.parse('$userBase/register/email'),
      headers: _headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return data;
    throw Exception(_extractError(data));
  }

  static Future<String> generateUsername() async {
    final res = await http.get(
      Uri.parse('$userBase/generate-username'),
      headers: _headers,
    );

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
    final res = await http.post(
      Uri.parse('$otpBase/send/email'),
      headers: _headers,
      body: jsonEncode({'email': email, 'userID': userId}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> sendOtpPhone({
    required String phone,
    required String userId,
  }) async {
    final res = await http.post(
      Uri.parse('$otpBase/send/phone'),
      headers: _headers,
      body: jsonEncode({'phone': phone, 'userID': userId}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> sendOtpWhatsApp({
    required String phone,
    required String userId,
  }) async {
    final res = await http.post(
      Uri.parse('$otpBase/send/whatsapp'),
      headers: _headers,
      body: jsonEncode({'phone': phone, 'userID': userId}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String userId,
    required String otpCode,
  }) async {
    final res = await http.post(
      Uri.parse('$otpBase/verify'),
      headers: _headers,
      body: jsonEncode({'userID': userId, 'otp_code': otpCode}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Roles ─────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getRolesByLanguage(String lang) async {
    final res = await http.get(
      Uri.parse('$roleBase/language/$lang'),
      headers: _headers,
    );

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
    final res = await http.put(
      Uri.parse('$userBase/$userId/role'),
      headers: _authHeaders,
      body: jsonEncode({'roleId': roleId}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> assignProfile({
    required String userId,
    required String profileId,
  }) async {
    final res = await http.put(
      Uri.parse('$userBase/$userId/profile'),
      headers: _authHeaders,
      body: jsonEncode({'profile': profileId}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getUserLanguage(String userId) async {
    final res = await http.get(
      Uri.parse('$userBase/$userId/language'),
      headers: _authHeaders,
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> changeUserLanguage({
    required String userId,
    required String language,
  }) async {
    final res = await http.put(
      Uri.parse('$userBase/$userId/language'),
      headers: _authHeaders,
      body: jsonEncode({'language': language}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Chief Profile ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createChiefProfile(String name) async {
    final res = await http.post(
      Uri.parse(chiefBase),
      headers: _headers,
      body: jsonEncode({'name': name}),
    );

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return data;
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
