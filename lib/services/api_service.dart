import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/users',
  );

  static String get baseUrl =>
      _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');

  final http.Client _client = http.Client();

  String? accessToken;
  String? refreshToken;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> data = await _post(
      '/login/',
      body: {
        'email': email,
        'password': password,
      },
    );

    final String? access = data['access']?.toString();
    final String? refresh = data['refresh']?.toString();

    if (access == null || refresh == null) {
      throw const ApiException(
        'استجابة تسجيل الدخول غير مكتملة من الخادم.',
      );
    }

    accessToken = access;
    refreshToken = refresh;
  }

  Future<void> registerCitizen({
    required String email,
    required String phoneNumber,
    required String password,
    required String fullName,
    required String idNumber,
    required DateTime dateOfBirth,
    required bool hasChronicDisease,
    String? chronicDiseaseDescription,
  }) async {
    await _post(
      '/register/',
      expectedStatusCodes: const {201},
      body: {
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'role': 'citizen',
        'full_name': fullName,
        'id_number': idNumber,
        'date_of_birth': _formatDate(dateOfBirth),
        'has_chronic_disease': hasChronicDisease,
        'chronic_disease_description': hasChronicDisease
            ? chronicDiseaseDescription
            : '',
      },
    );
  }

  Future<void> registerPharmacist({
    required String email,
    required String phoneNumber,
    required String password,
    required String fullName,
    required String idNumber,
    required DateTime dateOfBirth,
    required String pharmacyName,
    required String pharmacyAddress,
  }) async {
    await _post(
      '/register/',
      expectedStatusCodes: const {201},
      body: {
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'role': 'pharmacist',
        'full_name': fullName,
        'id_number': idNumber,
        'date_of_birth': _formatDate(dateOfBirth),
        'pharmacy_name': pharmacyName,
        'pharmacy_address': pharmacyAddress,
      },
    );
  }

  Future<void> requestOtp(String emailOrPhone) async {
    await _post(
      '/password/request-otp/',
      body: {'email_or_phone': emailOrPhone},
    );
  }

  Future<void> verifyOtp({
    required String emailOrPhone,
    required String otpCode,
  }) async {
    await _post(
      '/password/verify-otp/',
      body: {
        'email_or_phone': emailOrPhone,
        'otp_code': otpCode,
      },
    );
  }

  Future<void> resetPassword({
    required String emailOrPhone,
    required String otpCode,
    required String newPassword,
  }) async {
    await _post(
      '/password/reset/',
      body: {
        'email_or_phone': emailOrPhone,
        'otp_code': otpCode,
        'new_password': newPassword,
      },
    );
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    Set<int> expectedStatusCodes = const {200},
  }) async {
    try {
      final http.Response response = await _client
          .post(
            Uri.parse('$baseUrl$path'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      final dynamic decoded = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(utf8.decode(response.bodyBytes));

      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (!expectedStatusCodes.contains(response.statusCode)) {
        throw _buildApiException(response.statusCode, data);
      }

      return data;
    } on TimeoutException {
      throw const ApiException(
        'انتهت مهلة الاتصال بالخادم. تحقق من الشبكة وحاول مجددًا.',
      );
    } on http.ClientException {
      throw const ApiException(
        'تعذر الاتصال بالخادم. تأكد من تشغيل الـBackend وصحة الرابط.',
      );
    } on FormatException {
      throw const ApiException('أرسل الخادم استجابة غير صالحة.');
    }
  }

  ApiException _buildApiException(
    int statusCode,
    Map<String, dynamic> data,
  ) {
    final Map<String, String> fieldErrors = {};

    for (final MapEntry<String, dynamic> entry in data.entries) {
      final String value = _errorValueToString(entry.value);
      if (value.isNotEmpty) {
        fieldErrors[entry.key] = value;
      }
    }

    String message = fieldErrors['error'] ??
        fieldErrors['detail'] ??
        fieldErrors.values.firstOrNull ??
        'حدث خطأ أثناء الاتصال بالخادم.';

    if (message.contains('No active account found')) {
      message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }

    return ApiException(
      message,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
    );
  }

  String _errorValueToString(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }

    if (value is Map && value.isNotEmpty) {
      return _errorValueToString(value.values.first);
    }

    return value?.toString() ?? '';
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
