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
    defaultValue: 'https://hakim-app.onrender.com/api/users',
  );

  static String get baseUrl {
    return _configuredBaseUrl.replaceAll(
      RegExp(r'/+$'),
      '',
    );
  }

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
        'date_of_birth': _formatDate(dateOfBirth),
        'has_chronic_disease': hasChronicDisease,
        'chronic_disease_description':
        hasChronicDisease
            ? chronicDiseaseDescription ?? ''
            : '',
      },
    );
  }

  Future<void> registerPharmacist({
    required String email,
    required String phoneNumber,
    required String password,
    required String fullName,
    required DateTime dateOfBirth,
    required String pharmacyName,
    required String pharmacyAddress,
    required double pharmacyLatitude,
    required double pharmacyLongitude,
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
        'date_of_birth': _formatDate(dateOfBirth),
        'pharmacy_name': pharmacyName,
        'pharmacy_address': pharmacyAddress,
        'pharmacy_latitude': pharmacyLatitude,
        'pharmacy_longitude': pharmacyLongitude,
      },
    );
  }

  Future<void> requestOtp(
      String emailOrPhone,
      ) async {
    await _post(
      '/password/request-otp/',
      body: {
        'email_or_phone': emailOrPhone,
      },
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
      final Uri uri = Uri.parse('$baseUrl$path');

      final http.Response response = await _client
          .post(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type':
          'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      )
          .timeout(
        const Duration(seconds: 60),
      );

      final Map<String, dynamic> data =
      _decodeResponse(response);

      if (!expectedStatusCodes.contains(
        response.statusCode,
      )) {
        throw _buildApiException(
          response.statusCode,
          data,
        );
      }

      return data;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'استغرق الخادم وقتًا طويلًا في الاستجابة. انتظري قليلًا ثم حاولي مجددًا.',
      );
    } on http.ClientException {
      throw const ApiException(
        'تعذر الاتصال بالخادم. تحققي من الإنترنت وحاولي مجددًا.',
      );
    } on FormatException {
      throw const ApiException(
        'أرسل الخادم استجابة غير صالحة.',
      );
    } catch (_) {
      throw const ApiException(
        'حدث خطأ غير متوقع أثناء الاتصال بالخادم.',
      );
    }
  }

  Map<String, dynamic> _decodeResponse(
      http.Response response,
      ) {
    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final dynamic decoded = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  ApiException _buildApiException(
      int statusCode,
      Map<String, dynamic> data,
      ) {
    final Map<String, String> fieldErrors = {};

    for (final MapEntry<String, dynamic> entry
    in data.entries) {
      final String value =
      _errorValueToString(entry.value);

      if (value.isNotEmpty) {
        fieldErrors[entry.key] = value;
      }
    }

    String message =
        fieldErrors['error'] ??
            fieldErrors['detail'] ??
            fieldErrors.values.firstOrNull ??
            _statusMessage(statusCode);

    if (message.contains('No active account found')) {
      message =
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }

    return ApiException(
      message,
      statusCode: statusCode,
      fieldErrors: fieldErrors,
    );
  }

  String _statusMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'البيانات المدخلة غير صحيحة.';
      case 401:
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      case 403:
        return 'لا تملكين صلاحية لتنفيذ هذه العملية.';
      case 404:
        return 'لم يتم العثور على خدمة الـAPI المطلوبة.';
      case 409:
        return 'هذا الحساب موجود مسبقًا.';
      case 429:
        return 'تم إرسال طلبات كثيرة، حاولي لاحقًا.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'الخادم غير متاح حاليًا، حاولي بعد قليل.';
      default:
        return 'حدث خطأ أثناء الاتصال بالخادم.';
    }
  }

  String _errorValueToString(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }

    if (value is Map && value.isNotEmpty) {
      return _errorValueToString(
        value.values.first,
      );
    }

    return value?.toString() ?? '';
  }

  String _formatDate(DateTime date) {
    final String month =
    date.month.toString().padLeft(2, '0');

    final String day =
    date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
}