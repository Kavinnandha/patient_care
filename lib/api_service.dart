import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config/env.dart';

class ApiEndpoints {
  static const String profiles = 'profiles';
  static const String medicalRecords = 'medical-records';
  static const String medications = 'medications';
  static const String vitalSigns = 'vital-signs';
  static const String glucoseReadings = 'glucose-readings';
  static const String foodIntake = 'food-intake';
  static const String insulinRecords = 'insulin-records';
  static const String waterIntake = 'water-intake';
}

class ApiService {
  final String baseUrl = EnvConfig.apiBaseUrl;
  String? _userId;

  Future<String> getUserId() async {
    if (_userId != null) return _userId!;
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '';
    return _userId!;
  }

  Future<Map<String, dynamic>> getWaterIntakeRecords(
      String userId, String startDate, String endDate) async {
    final response = await get(
        '${ApiEndpoints.waterIntake}/$userId?startDate=$startDate&endDate=$endDate');
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWaterIntakeStats(
      String userId, String startDate, String endDate) async {
    final response = await get(
        '${ApiEndpoints.waterIntake}/stats/$userId?startDate=$startDate&endDate=$endDate');
    return response as Map<String, dynamic>;
  }

  Future<void> addWaterIntakeRecord(
    String userId,
    double amount, {
    String source = 'manual',
    String? note,
    double? dailyGoal,
  }) async {
    await post(ApiEndpoints.waterIntake, {
      'userId': userId,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      'source': source,
      'note': note,
      'dailyGoal': dailyGoal,
    });
  }

  Future<void> deleteWaterIntakeRecord(String id) async {
    await delete('${ApiEndpoints.waterIntake}/$id');
  }

  // Get the auth token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    final token = await _getToken();
    final headers = Map<String, String>.from(EnvConfig.headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();
    final headers = Map<String, String>.from(EnvConfig.headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  // Generic PATCH request
  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();
    final headers = Map<String, String>.from(EnvConfig.headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();
    final headers = Map<String, String>.from(EnvConfig.headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    final token = await _getToken();
    final headers = Map<String, String>.from(EnvConfig.headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );

    return _handleResponse(response);
  }

  // Handle API responses
  bool _isRefreshing = false;

  Future<dynamic> _handleResponse(http.Response response,
      {bool isRetry = false}) async {
    try {
      // Check for empty response body
      if (response.body.isEmpty) {
        throw ApiException(
          'Empty response from server',
          response.statusCode,
          '',
        );
      }
      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        data = response.body; // Return raw string if JSON decoding fails
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Response data: $data"); // Debug log
        return data;
      } else if (response.statusCode == 401 && !isRetry && !_isRefreshing) {
        _isRefreshing = true;
        try {
          // Check if we can refresh the token
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString('refresh_token');

          if (refreshToken != null) {
            // Use direct http call to avoid recursion
            final refreshResponse = await http.post(
              Uri.parse('$baseUrl/auth/refresh'),
              headers: EnvConfig.headers,
              body: jsonEncode({'refreshToken': refreshToken}),
            );

            final refreshData = jsonDecode(refreshResponse.body);
            if (refreshResponse.statusCode == 200 &&
                refreshData['status'] == 'success') {
              final tokens = refreshData['data'];
              await prefs.setString('access_token', tokens['token']);
              await prefs.setString('refresh_token', tokens['refreshToken']);

              // Retry the original request with new token
              final headers = Map<String, String>.from(EnvConfig.headers);
              headers['Authorization'] = 'Bearer ${tokens['token']}';

              // Reconstruct the original request with the new token
              final originalMethod = response.request!.method;
              final originalUrl = response.request!.url;

              http.Response retryResponse;
              if (originalMethod == 'GET') {
                retryResponse = await http.get(originalUrl, headers: headers);
              } else if (originalMethod == 'POST') {
                retryResponse = await http.post(originalUrl,
                    headers: headers,
                    body: response.request is http.Request
                        ? (response.request as http.Request).body
                        : null);
              } else if (originalMethod == 'PUT') {
                retryResponse = await http.put(originalUrl,
                    headers: headers,
                    body: response.request is http.Request
                        ? (response.request as http.Request).body
                        : null);
              } else if (originalMethod == 'PATCH') {
                retryResponse = await http.patch(originalUrl,
                    headers: headers,
                    body: response.request is http.Request
                        ? (response.request as http.Request).body
                        : null);
              } else if (originalMethod == 'DELETE') {
                retryResponse =
                    await http.delete(originalUrl, headers: headers);
              } else {
                throw ApiException('Unsupported HTTP method', 500, '');
              }

              _isRefreshing = false;
              return _handleResponse(retryResponse, isRetry: true);
            }
          }
        } catch (e) {
          print('Token refresh failed: $e');
        } finally {
          _isRefreshing = false;
        }

        throw UnauthorizedException('Session expired. Please log in again.');
      } else {
        final errorMessage = data['error'] == 'Too many attempts'
            ? 'Too many login attempts'
            : data['error'] ?? 'An error occurred';
        throw ApiException(
          errorMessage,
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException || e is UnauthorizedException) {
        rethrow;
      }
      throw ApiException(
        'Failed to process response: ${e.toString()}',
        response.statusCode,
        response.body,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String body;

  ApiException(this.message, this.statusCode, this.body);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiService.post('auth/login', {
      'username': username,
      'password': password,
    });
    return response;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('user_profile');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }
}
