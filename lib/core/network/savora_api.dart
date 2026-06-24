import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../state/providers/auth_provider.dart';

class SavoraApi {
  // Set to your local IP when testing OTP locally (e.g. 'http://192.168.1.100:5003')
  // Set to null to use Railway production
  // static const String? localOtpUrl = null;
  static const String? localOtpUrl = 'http://192.168.1.5:5003';

  static String get otpBase => localOtpUrl != null
      ? '$localOtpUrl/api/v1/otp'
      : 'https://savoraotp-services-production.up.railway.app/api/v1/otp';

  static const String userBase    = 'https://savorauser-services-production.up.railway.app/api/v1/users';
  static const String roleBase    = 'https://savorarole-services-production.up.railway.app/api/v1/roles';
  static const String chiefBase   = 'https://savora-chiefprofileservices-production.up.railway.app/api/v2/chief-profile';
  static const String driverBase  = 'https://savoradriverprofile-services-production.up.railway.app/api/v2/driver-profile';
  static const String dishBase    = 'https://savoradish-services-production.up.railway.app/api/v1/dishes';
  static const String prefChiefBase = 'https://savoradishprefered-services-production.up.railway.app/api/v1/preferred-dishes-chief';
  static const String categoryBase = 'https://savora-categoryservices-production.up.railway.app/api/v1/categories';
  static const String subcategoryBase = 'https://savora-subcategoriesservices-production.up.railway.app/api/v1/subcategories';
  static const String customerBase = 'https://savoracustomerprofile-services-production.up.railway.app/api/v1/customer-profile';
  static const String paymentProviderBase = 'https://savorapaymentprovider-services-production.up.railway.app/api/v1/payment-provider';
  static const String imagesBase  = 'https://savora-imageservices-production.up.railway.app/api/v2/images';
  static const String addressBase = 'https://savoraaddress-services-production.up.railway.app/api/v1/address';
  static const String nationalIdBase = 'https://savoranationalid-services-production.up.railway.app/api/v2/national-id';
  static const String azBase = 'https://savora-availabilityzoneservices-production.up.railway.app/api/v1/az';

  static const Duration _timeout = Duration(seconds: 30);

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

  static Future<http.Response> _delete(String url, {Map<String, String>? headers}) =>
      http.delete(Uri.parse(url), headers: headers).timeout(_timeout);

  static Future<http.Response> _patch(String url, {Map<String, String>? headers, Object? body}) =>
      http.patch(Uri.parse(url), headers: headers, body: body).timeout(_timeout);

  static String _mimeFromName(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg': case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'webp': return 'image/webp';
      default: return 'image/jpeg';
    }
  }

  static Future<Map<String, dynamic>> _uploadBytes(String url, List<int> bytes, String filename, {Map<String, String>? fields}) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    if (fields != null) request.fields.addAll(fields);
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename, contentType: MediaType.parse(_mimeFromName(filename))));
    final streamed = await request.send().timeout(const Duration(seconds: 120));
    final res = await http.Response.fromStream(streamed);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return data;
    throw Exception(_extractError(data));
  }

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

  // ── Phone Login (OTP) ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> findOrCreateByPhone(String phone) async {
    final res = await _post('$userBase/find-or-create-by-phone', headers: _headers, body: jsonEncode({'phone': phone}));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> phoneLogin(String userId) async {
    final res = await _post('$userBase/phone-login', headers: _headers, body: jsonEncode({'userId': userId}));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Forgot / Reset Password ───────────────────────────────────────────

  static Future<Map<String, dynamic>> forgotPassword(String identifier) async {
    final res = await _post('$userBase/forgot-password', headers: _headers, body: jsonEncode({'identifier': identifier}));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> resetPassword(String userId, String newPassword) async {
    final res = await _post('$userBase/reset-password', headers: _headers, body: jsonEncode({'userId': userId, 'newPassword': newPassword}));
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

  static Future<Map<String, dynamic>> getUserById(String userId) async {
    final res = await _get('$userBase/$userId', headers: _authHeaders);
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

  static Future<Map<String, dynamic>> createCustomerProfile(Map<String, dynamic> data) async {
    final res = await _post(customerBase, headers: _headers, body: jsonEncode(data));

    final result = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return result;
    throw Exception(_extractError(result));
  }

  static Future<Map<String, dynamic>> getChiefProfile(String id) async {
    final res = await _get('$chiefBase/$id', headers: _authHeaders);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> updateChiefProfile(
      String id, Map<String, dynamic> data) async {
    final res = await _put('$chiefBase/$id',
        headers: _authHeaders, body: jsonEncode(data));
    final result = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return result;
    throw Exception(_extractError(result));
  }

  static Future<Map<String, dynamic>> uploadChiefProfileImage(
      List<int> bytes, String filename) async {
    return _uploadBytes('$imagesBase/chief-profile-image', bytes, filename);
  }

  static Future<Map<String, dynamic>> uploadCustomerProfileImage(
      List<int> bytes, String filename) async {
    return _uploadBytes('$imagesBase/customer-profile-image', bytes, filename);
  }

  // ── Driver Profile ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createDriverProfile(String name) async {
    final res = await _post(driverBase, headers: _headers, body: jsonEncode({'name': name}));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getDriverProfile(String id) async {
    final res = await _get('$driverBase/$id', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> updateDriverProfile(String id, Map<String, dynamic> data) async {
    final res = await _put('$driverBase/$id', headers: _authHeaders, body: jsonEncode(data));
    final result = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return result;
    throw Exception(_extractError(result));
  }

  static Future<Map<String, dynamic>> verifyDriverStep(String id, String step, String status) async {
    final res = await _patch('$driverBase/$id/verify-step', headers: _authHeaders, body: jsonEncode({
      'step': step,
      'status': status,
    }));
    final result = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return result;
    throw Exception(_extractError(result));
  }

  static Future<Map<String, dynamic>> uploadDriverVehicleImage(List<int> bytes, String filename) {
    return _uploadBytes('$imagesBase/driver-vehicle-image', bytes, filename);
  }

  static Future<Map<String, dynamic>> uploadDriverIdFront(List<int> bytes, String filename) {
    return _uploadBytes('$imagesBase/driver-id-front', bytes, filename);
  }

  static Future<Map<String, dynamic>> uploadDriverIdBack(List<int> bytes, String filename) {
    return _uploadBytes('$imagesBase/driver-id-back', bytes, filename);
  }

  static Future<Map<String, dynamic>> uploadDriverLicenseFront(List<int> bytes, String filename) {
    return _uploadBytes('$imagesBase/driver-license-front', bytes, filename);
  }

  static Future<Map<String, dynamic>> uploadDriverLicenseBack(List<int> bytes, String filename) {
    return _uploadBytes('$imagesBase/driver-license-back', bytes, filename);
  }

  static Future<Map<String, dynamic>> uploadDriverVehicleLicense(List<int> bytes, String filename) {
    return _uploadBytes('$imagesBase/driver-vehicle-license', bytes, filename);
  }

  // ── Driver Orders ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAvailableOrdersForDriver() async {
    final res = await _get('$chiefBase/order/available/driver', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> acceptOrderDriver(String orderId, String driverId) async {
    final res = await _patch('$chiefBase/order/$orderId/driver-accept', headers: _authHeaders, body: jsonEncode({
      'driver_id': driverId,
    }));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> deliverOrderDriver(String orderId) async {
    final res = await _patch('$chiefBase/order/$orderId/driver-deliver', headers: _authHeaders, body: jsonEncode({}));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> submitOrderRating(String orderId, {required int rating, int? driverRating, String? comment}) async {
    final body = <String, dynamic>{'rating': rating};
    if (driverRating != null) body['driver_rating'] = driverRating;
    if (comment != null) body['comment'] = comment;
    final res = await _post('$chiefBase/order/$orderId/rate', headers: _authHeaders, body: jsonEncode(body));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Customer Profile ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getCustomerProfileByAuthId(String authId) async {
    final res = await _get('$customerBase/auth/$authId', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> updateCustomerVerificationStep({
    required String profileId,
    required String step,
  }) async {
    final res = await _patch('$customerBase/$profileId/verify-step', headers: _authHeaders, body: jsonEncode({'step': step}));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> updateCustomerProfile({
    required String profileId,
    required Map<String, dynamic> data,
  }) async {
    final res = await _put('$customerBase/$profileId', headers: _authHeaders, body: jsonEncode(data));
    final result = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return result;
    throw Exception(_extractError(result));
  }

  // ── Payment Providers ────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getActivePaymentProviders() async {
    const fallbackKeys = {
      'Vodafone Cash': '0100 000 0000',
      'Orange Cash': '0120 000 0000',
      'Etisalat Cash': '0110 000 0000',
      'Bank Transfer': 'EGP 1234 5678 9012 3456 7890',
    };
    try {
      final res = await _get('$paymentProviderBase/active', headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = data['data'];
        if (list is List) {
          final providers = list.cast<Map<String, dynamic>>();
          for (final p in providers) {
            final name = (p['name'] as String?) ?? (p['Provider'] as String?) ?? '';
            p.putIfAbsent('key', () => fallbackKeys[name] ?? '');
          }
          return providers;
        }
        return [];
      }
      throw Exception(_extractError(jsonDecode(res.body)));
    } catch (_) {
      return [
        {'name': 'Vodafone Cash', 'Provider': 'Vodafone Cash', 'key': fallbackKeys['Vodafone Cash']},
        {'name': 'Orange Cash', 'Provider': 'Orange Cash', 'key': fallbackKeys['Orange Cash']},
        {'name': 'Etisalat Cash', 'Provider': 'Etisalat Cash', 'key': fallbackKeys['Etisalat Cash']},
        {'name': 'Bank Transfer', 'Provider': 'Bank Transfer', 'key': fallbackKeys['Bank Transfer']},
      ];
    }
  }

  // ── Address ──────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createAddress(Map<String, dynamic> addressData) async {
    final res = await _post(addressBase, headers: _headers, body: jsonEncode(addressData));
    if (res.statusCode == 201) return jsonDecode(res.body) as Map<String, dynamic>;
    final raw = res.body;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      throw Exception(_extractError(data));
    } catch (_) {
      throw Exception('Address service returned ${res.statusCode}: ${raw.length > 200 ? raw.substring(0, 200) : raw}');
    }
  }

  // ── Delivery Fee & Zones ─────────────────────────────────────────────

  /// Returns average delivery fee from zone stats
  static Future<double> getAverageDeliveryFee() async {
    try {
      final res = await _get('$azBase/stats/overview', headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final fee = (data['avgBaseFee'] as num?)?.toDouble() ?? 20.0;
        return fee;
      }
      return 20.0;
    } catch (_) {
      return 20.0;
    }
  }

  // ── Dishes ───────────────────────────────────────────────────────────—

  static Future<Map<String, dynamic>> createDish(Map<String, dynamic> dish) async {
    final res = await _post(dishBase, headers: _headers, body: jsonEncode(dish));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getAllDishes() async {
    final res = await _get(dishBase, headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getDishesByLanguage(String lang) async {
    final res = await _get('$dishBase/language/$lang', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getDishById(String id) async {
    final res = await _get('$dishBase/$id', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getDishesBySubcategory(String subcategoryId) async {
    final res = await _get('$dishBase/by-subcategory/$subcategoryId', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> updateDish(String id, Map<String, dynamic> dish) async {
    final res = await _put('$dishBase/$id', headers: _headers, body: jsonEncode(dish));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> deleteDish(String id) async {
    final res = await _delete('$dishBase/$id', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Categories ───────────────────────────────────────────────────────—

  static Future<Map<String, dynamic>> getCategoriesByLanguage(String lang) async {
    final res = await _get('$categoryBase/language/$lang', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Subcategories ────────────────────────────────────────────────────—

  static Future<Map<String, dynamic>> getSubcategoriesByCategory(String categoryId) async {
    final res = await _get('$subcategoryBase/by-category/$categoryId', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Chief Profile Step Verification ───────────────────────────────────—

  static Future<Map<String, dynamic>> getVerificationSteps(String profileId) async {
    final res = await _get('$chiefBase/$profileId/verification-steps', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> verifyStep({
    required String profileId,
    required String step,
    required String status,
  }) async {
    final res = await _patch('$chiefBase/$profileId/verify-step', headers: _authHeaders, body: jsonEncode({
      'step': step, 'status': status,
    }));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> uploadHealthCertificateImage(List<int> bytes, String filename) async {
    return _uploadBytes('$imagesBase/chief-health-certificate', bytes, filename);
  }

  static Future<Map<String, dynamic>> assignHealthCertificateUrl({
    required String profileId,
    required String certificateUrl,
  }) async {
    final res = await _patch('$chiefBase/$profileId/health-certificate', headers: _authHeaders, body: jsonEncode({
      'certificateUrl': certificateUrl,
    }));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Payment Method ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> uploadPaymentMethod({
    required String profileId,
    required String provider,
    required String details,
  }) async {
    final res = await _patch('$chiefBase/$profileId/payment-method', headers: _authHeaders, body: jsonEncode({
      'provider': provider,
      'details': details,
    }));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── National ID Images ──────────────────────────────────────────────

  static Future<Map<String, dynamic>> uploadFrontIdImage(List<int> bytes, String filename) async {
    return _uploadBytes('$imagesBase/chief-frontID', bytes, filename);
  }

  static Future<Map<String, dynamic>> uploadBackIdImage(List<int> bytes, String filename) async {
    return _uploadBytes('$imagesBase/chief-backID', bytes, filename);
  }

  static Future<Map<String, dynamic>> createNationalId({
    required String frontImageURL,
    required String backImageURL,
  }) async {
    final res = await _post(nationalIdBase, headers: _headers, body: jsonEncode({
      'frontImageURL': frontImageURL,
      'backImageURL': backImageURL,
    }));
    if (res.statusCode == 201) return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception(_extractError(jsonDecode(res.body)));
  }

  static Future<Map<String, dynamic>> assignNationalIdUrls({
    required String profileId,
    required String frontImageURL,
    required String backImageURL,
  }) async {
    final res = await _patch('$chiefBase/$profileId/national-id', headers: _authHeaders, body: jsonEncode({
      'frontImageURL': frontImageURL,
      'backImageURL': backImageURL,
    }));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Admin Verification ───────────────────────────────────────────────

  /// Chef: submit completed verification for admin review
  static Future<Map<String, dynamic>> submitForReview(String profileId) async {
    final res = await _patch('$chiefBase/$profileId/submit-verification', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  /// Admin: get all chiefs pending review
  static Future<List<dynamic>> getPendingVerifications() async {
    final res = await _get('$chiefBase/admin/pending-verifications', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      final list = data['profiles'];
      if (list is List) return list;
      return [];
    }
    throw Exception(_extractError(data));
  }

  /// Admin: approve a chief's verification
  static Future<Map<String, dynamic>> approveVerification(String profileId) async {
    final res = await _patch('$chiefBase/$profileId/approve-verification', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  /// Admin: reject a chief's verification with optional reason
  static Future<Map<String, dynamic>> rejectVerification(String profileId, {String? reason}) async {
    final res = await _patch('$chiefBase/$profileId/reject-verification',
        headers: _authHeaders,
        body: reason != null ? jsonEncode({'reason': reason}) : null);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Orders ───────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> uploadPaymentImage(List<int> bytes, String filename) async {
    return _uploadBytes('$imagesBase/payment-image', bytes, filename);
  }

  static Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final res = await _post('$chiefBase/order', headers: _authHeaders, body: jsonEncode(orderData));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getChefOrders(String chefId) async {
    final res = await _get('$chiefBase/order/chef/$chefId', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getCustomerOrders(String customerId) async {
    final res = await _get('$chiefBase/order/customer/$customerId', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final res = await _get('$chiefBase/order/$orderId', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> verifyPayment(String orderId, String status) async {
    final res = await _patch('$chiefBase/order/$orderId/payment-verify', headers: _authHeaders, body: jsonEncode({'status': status}));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> acceptOrder(String orderId) async {
    final res = await _patch('$chiefBase/order/$orderId/accept', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> updateOrderStatus(String orderId, String orderStatus) async {
    final res = await _patch('$chiefBase/order/$orderId/status', headers: _authHeaders, body: jsonEncode({'order_status': orderStatus}));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<List<dynamic>> getPendingPayments() async {
    final res = await _get('$chiefBase/admin/pending-payments', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      final list = data['orders'];
      if (list is List) return list;
      return [];
    }
    throw Exception(_extractError(data));
  }

  // ── Daily Availability ───────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAvailabilityByChiefAndDate(String chiefId, String date) async {
    final res = await _get('$prefChiefBase/availability/chief/$chiefId/date/$date', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Preferred Dishes Chief ───────────────────────────────────────────—

  static Future<Map<String, dynamic>> setPreferredDish({
    required String chiefId,
    required String dishId,
    bool preferred = true,
  }) async {
    final res = await _post('$prefChiefBase/preferred', headers: _headers, body: jsonEncode({
      'chiefId': chiefId, 'dishId': dishId, 'preferred': preferred,
    }));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getPreferredDishes(String chiefId) async {
    final res = await _get('$prefChiefBase/preferred/$chiefId', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> setDailyAvailability({
    required String chiefId,
    required String dishId,
    required String date,
    required int piecesAvailable,
  }) async {
    final res = await _post('$prefChiefBase/availability', headers: _headers, body: jsonEncode({
      'chiefId': chiefId, 'dishId': dishId, 'date': date, 'piecesAvailable': piecesAvailable,
    }));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> removePreferredDish({
    required String chiefId,
    required String dishId,
  }) async {
    final res = await _delete('$prefChiefBase/preferred/$chiefId/$dishId', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  static Future<Map<String, dynamic>> getDashboard(String date) async {
    final res = await _get('$prefChiefBase/dashboard/$date', headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Best Chef Assignment ─────────────────────────────────────────────

  static Future<Map<String, dynamic>> findBestChef({
    required List<Map<String, dynamic>> items,
    required String date,
  }) async {
    final res = await _post('$prefChiefBase/best-chef', headers: _headers, body: jsonEncode({
      'items': items, 'date': date,
    }));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Chef Earnings ────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getChefEarnings(String chefId) async {
    final res = await _get('$chiefBase/order/chef/$chefId/earnings', headers: _authHeaders);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw Exception(_extractError(data));
  }

  // ── Kitchen Status ───────────────────────────────────────────────────

  static Future<Map<String, dynamic>> setKitchenStatus(String profileId, bool open) async {
    final res = await _patch('$chiefBase/$profileId/kitchen-status',
        headers: _authHeaders,
        body: jsonEncode({'kitchen_open': open}));
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
