import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import '../api_service.dart';
import '../models/auth_response.dart';
import 'dart:convert';

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final double? height;
  final double? weight;
  final String? bloodType;
  final List<String> medicalConditions;
  final List<String> allergies;
  final List<String> currentMedications;
  final Map<String, String>? emergencyContact;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.height,
    this.weight,
    this.bloodType,
    this.medicalConditions = const [],
    this.allergies = const [],
    this.currentMedications = const [],
    this.emergencyContact,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      bloodType: json['bloodType'],
      medicalConditions: List<String>.from(json['medicalConditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      currentMedications: List<String>.from(json['currentMedications'] ?? []),
      emergencyContact: json['emergencyContact'] != null
          ? Map<String, String>.from(json['emergencyContact'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'bloodType': bloodType,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'emergencyContact': emergencyContact,
    };
  }
}

class AuthProvider with ChangeNotifier {
  static final _log = Logger('AuthProvider');
  
  final ApiService _apiService;
  bool _isAuthenticated = false;
  String? _accessToken;
  String? _refreshToken;
  String? _username;
  String? _email;
  UserProfile? _userProfile;
  bool _isLoading = false;
  DateTime? _tokenExpiration;

  AuthProvider(this._apiService) {
    _checkAuthStatus();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get username => _username;
  String? get email => _email;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserProfile? get userProfile => _userProfile;

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      _username = prefs.getString('username');
      _email = prefs.getString('email');
      final expirationStr = prefs.getString('token_expiration');
      final profileStr = prefs.getString('user_profile');
      
      if (_accessToken == null || _refreshToken == null || expirationStr == null) {
        _isAuthenticated = false;
        notifyListeners();
        return;
      }

      _tokenExpiration = DateTime.parse(expirationStr);
      
      // Set initial state from stored data
      _isAuthenticated = true;
      if (profileStr != null) {
        _userProfile = UserProfile.fromJson(json.decode(profileStr));
      }
      notifyListeners();

      // Check if token is expired or about to expire (within 5 minutes)
      if (_tokenExpiration!.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
        // Try to refresh token
        final success = await _refreshAccessToken();
        if (!success) {
          _isAuthenticated = false;
          await _clearStorageAndState();
          notifyListeners();
          return;
        }
      }
      
      // Try to fetch profile to validate token
      
      try {
        final response = await _apiService.get('auth/me');
        
        if (response['status'] == 'success' && response['data'] != null) {
          _username = response['data']['user']['username'];
          _email = response['data']['user']['email'];
          _userProfile = UserProfile.fromJson(response['data']['profile']);
          
          // Update stored profile
          await prefs.setString('username', _username!);
          await prefs.setString('email', _email!);
          await prefs.setString('user_profile', json.encode(_userProfile!.toJson()));
        } else {
          _log.warning('Invalid response format from auth/me endpoint');
          _isAuthenticated = false;
          await _clearStorageAndState();
        }
      } catch (e) {
        _log.warning('Failed to validate token', e);
        _isAuthenticated = false;
        await _clearStorageAndState();
      }
    } catch (e) {
      _log.severe('Error checking auth status', e);
      await logout();
    }
    
    notifyListeners();
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final response = await _apiService.post('auth/refresh', {
        'refreshToken': _refreshToken,
      });
      
      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'];
        final prefs = await SharedPreferences.getInstance();
        _accessToken = data['token'];
        _refreshToken = data['refreshToken'];
        _tokenExpiration = DateTime.now().add(const Duration(hours: 1));
        
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        await prefs.setString('token_expiration', _tokenExpiration!.toIso8601String());
        
        return true;
      }
      return false;
    } catch (e) {
      _log.warning('Failed to refresh token', e);
      return false;
    }
  }

  Future<AuthResponse> login(String username, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.post('auth/login', {
        'username': username,
        'password': password,
      });

      _log.info('Login response: $response'); // Debug log
      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'];
        final tokens = data['tokens'];
        final prefs = await SharedPreferences.getInstance();
        
        _accessToken = tokens['accessToken'];
        _refreshToken = tokens['refreshToken'];
        _tokenExpiration = DateTime.now().add(const Duration(hours: 1));
        _username = data['user']['username'];
        _email = data['user']['email'];
        
        if (data['profile'] != null) {
          _userProfile = UserProfile.fromJson(data['profile']);
        }

        // Set authenticated and notify before saving to storage
        _isAuthenticated = true;
        notifyListeners();  // Notify immediately for AuthWrapper to react

        // Save to storage
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        await prefs.setString('token_expiration', _tokenExpiration!.toIso8601String());
        await prefs.setString('username', _username!);
        await prefs.setString('email', _email!);
        if (data['profile'] != null) {
          await prefs.setString('user_profile', json.encode(data['profile']));
        }
        
        _isLoading = false;
        notifyListeners();
        
        return AuthResponse(success: true, message: response['message']);
      }

      _isLoading = false;
      notifyListeners();
      return AuthResponse(
        success: false, 
        message: response['message'] ?? 'Login failed',
        error: response['error']
      );
    } catch (e) {
      _log.severe('Login error', e);
      _isLoading = false;
      notifyListeners();
      return AuthResponse(
        success: false,
        message: 'An error occurred during login',
        error: e.toString()
      );
    }
  }

  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String gender,
    double? height,
    double? weight,
    String? bloodType,
    List<String>? medicalConditions,
    List<String>? allergies,
    List<String>? currentMedications,
    Map<String, String>? emergencyContact,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.post('auth/register', {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
        if (bloodType != null) 'bloodType': bloodType,
        if (medicalConditions != null) 'medicalConditions': medicalConditions,
        if (allergies != null) 'allergies': allergies,
        if (currentMedications != null) 'currentMedications': currentMedications,
        if (emergencyContact != null) 'emergencyContact': emergencyContact,
      });

      if (response['status'] == 'success' && response['data'] != null) {
        final data = response['data'];
        final tokens = data['tokens'];
        final prefs = await SharedPreferences.getInstance();
        
        _accessToken = tokens['accessToken'];
        _refreshToken = tokens['refreshToken'];
        _tokenExpiration = DateTime.now().add(const Duration(hours: 1));
        _username = data['user']['username'];
        _email = data['user']['email'];
        
        if (data['profile'] != null) {
          _userProfile = UserProfile.fromJson(data['profile']);
        }

        // Set authenticated and notify before saving to storage
        _isAuthenticated = true;
        notifyListeners();  // Notify immediately for AuthWrapper to react

        // Save to storage
        await prefs.setString('access_token', _accessToken!);
        await prefs.setString('refresh_token', _refreshToken!);
        await prefs.setString('token_expiration', _tokenExpiration!.toIso8601String());
        await prefs.setString('username', _username!);
        await prefs.setString('email', _email!);
        if (data['profile'] != null) {
          await prefs.setString('user_profile', json.encode(data['profile']));
        }
        
        _isLoading = false;
        notifyListeners();
        
        return AuthResponse(success: true, message: response['message']);
      }

      _isLoading = false;
      notifyListeners();
      return AuthResponse(
        success: false,
        message: response['message'] ?? 'Registration failed',
        error: response['error']
      );
    } catch (e) {
      _log.severe('Registration error', e);
      _isLoading = false;
      notifyListeners();
      return AuthResponse(
        success: false,
        message: 'An error occurred during registration',
        error: e.toString()
      );
    }
  }

  Future<void> _clearStorageAndState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expiration');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('user_profile');

    _accessToken = null;
    _refreshToken = null;
    _tokenExpiration = null;
    _username = null;
    _email = null;
    _userProfile = null;
    
    notifyListeners();
  }

  Future<AuthResponse> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Call server logout endpoint to invalidate token
      if (_accessToken != null) {
        await _apiService.post('auth/logout', {
          'token': _accessToken
        });
      }

      _isAuthenticated = false;
      await _clearStorageAndState();
      
      _isLoading = false;
      notifyListeners();  // Notify about loading state change
      
      return AuthResponse(success: true, message: 'Logged out successfully');
    } catch (e) {
      _log.severe('Logout error', e);
      _isLoading = false;
      notifyListeners();
      return AuthResponse(
        success: false,
        message: 'An error occurred during logout',
        error: e.toString()
      );
    }
  }
}
