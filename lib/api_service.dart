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
}

class ApiService {
  final String baseUrl = EnvConfig.apiBaseUrl;
  
  // Get the auth token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
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
  dynamic _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Authentication required');
      } else {
        throw ApiException(
          data['error'] ?? 'API Error: ${response.statusCode}',
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
  
  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.post('auth/login', {
        'username': username,
        'password': password,
      });
      
      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        await prefs.setString('username', response['user']['username']);
        await prefs.setString('email', response['user']['email']);
        await prefs.setString('user_profile', jsonEncode(response['profile']));
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('user_profile');
  }
  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}
