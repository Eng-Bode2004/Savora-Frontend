import 'dart:convert';
import 'package:http/http.dart' as http;

// Add to pubspec.yaml:  http: ^1.2.0
class AuthApi {
  // Android emulator  -> 10.0.2.2 maps to your PC's localhost
  // iOS simulator     -> use 'http://localhost:5000'
  // Real device       -> use your PC's LAN IP, e.g. 'http://192.168.1.10:5000'
  static const String _base = 'http://10.0.2.2:5000/api/v1/en/users';

  static Map<String, String> get _headers => {'Content-Type': 'application/json'};

  /// Calls POST /generate-username  body: { "name": "..." }
  /// Returns the AI/algorithmic username string.
  static Future<String> generateUsername(String seed) async {
    final res = await http.post(
      Uri.parse('$_base/generate-username'),
      headers: _headers,
      body: jsonEncode({'name': seed.isEmpty ? 'user' : seed}),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      final username = body['data']?['username'] as String?;
      if (username != null && username.isNotEmpty) return username;
      throw Exception('Empty username returned');
    }
    throw Exception(body['error'] ?? 'Could not generate username');
  }

  /// Calls POST /register
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      }),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return body;
    throw Exception(body['error'] ?? body['message'] ?? 'Registration failed');
  }

  /// Calls POST /login  (you'll need to add this route on the backend)
  /// Accepts phone OR username in `identifier`.
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/login'),
      headers: _headers,
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return body;
    throw Exception(body['error'] ?? body['message'] ?? 'Login failed');
  }
}