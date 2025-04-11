import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
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
  final ApiService _apiService;
  bool _isAuthenticated = false;
  String? _token;
  String? _username;
  String? _email;
  UserProfile? _userProfile;
  bool _isLoading = false;

  AuthProvider(this._apiService) {
    _checkAuthStatus();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get username => _username;
  String? get email => _email;
  String? get token => _token;
  UserProfile? get userProfile => _userProfile;

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _username = prefs.getString('username');
    _email = prefs.getString('email');
    
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(json.decode(profileJson));
    }
    
    _isAuthenticated = _token != null;
    
    if (_isAuthenticated) {
      // Fetch latest profile data from server
      await _fetchUserProfile();
    }
    
    notifyListeners();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await _apiService.get('auth/me');
      
      if (response['user'] != null && response['profile'] != null) {
        _username = response['user']['username'];
        _email = response['user']['email'];
        _userProfile = UserProfile.fromJson(response['profile']);
        
        // Update stored profile
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', _username!);
        await prefs.setString('email', _email!);
        await prefs.setString('user_profile', json.encode(_userProfile!.toJson()));
        
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.post('auth/login', {
        'username': username,
        'password': password,
      });

      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        await prefs.setString('username', response['user']['username']);
        await prefs.setString('email', response['user']['email']);
        await prefs.setString('user_profile', json.encode(response['profile']));

        _token = response['token'];
        _username = response['user']['username'];
        _email = response['user']['email'];
        _userProfile = UserProfile.fromJson(response['profile']);
        _isAuthenticated = true;
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> register({
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

      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        await prefs.setString('username', response['user']['username']);
        await prefs.setString('email', response['user']['email']);
        await prefs.setString('user_profile', json.encode(response['profile']));

        _token = response['token'];
        _username = response['user']['username'];
        _email = response['user']['email'];
        _userProfile = UserProfile.fromJson(response['profile']);
        _isAuthenticated = true;
        
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _token = null;
      _username = null;
      _email = null;
      _userProfile = null;
      _isAuthenticated = false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
