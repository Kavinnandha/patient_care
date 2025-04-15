import 'package:flutter/material.dart';
import '../api_service.dart';
import '../services/sync_service.dart';
import 'auth_provider.dart';

class BloodGlucoseReading {
  final String id;
  final String patientId;
  final double glucoseLevel;
  final DateTime timestamp;
  final String notes;
  final String readingType;

  static const List<String> validReadingTypes = [
    'fasting',
    'pre_meal',
    'post_meal',
    'bedtime',
    'random'
  ];

  BloodGlucoseReading({
    required this.id,
    required this.patientId,
    required this.glucoseLevel,
    required this.timestamp,
    this.notes = '',
    required this.readingType,
  });

  factory BloodGlucoseReading.fromJson(Map<String, dynamic> json) {
    // Handle both object and string patient IDs
    String patientId = '';
    if (json['patient'] is Map<String, dynamic>) {
      patientId = (json['patient'] as Map<String, dynamic>)['_id'] ?? '';
    } else if (json['patient'] is String) {
      patientId = json['patient'];
    }

    return BloodGlucoseReading(
      id: json['_id'] ?? '',
      patientId: patientId,
      glucoseLevel: (json['glucoseLevel'] is int)
          ? (json['glucoseLevel'] as int).toDouble()
          : (json['glucoseLevel'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      notes: json['notes'] ?? '',
      readingType: json['readingType'] ?? 'random',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient': patientId,
      'glucoseLevel': glucoseLevel,
      'readingType': readingType,
      'notes': notes,
    };
  }

  // Helper method to convert UI reading type to API format
  static String convertReadingType(String uiType) {
    switch (uiType.toLowerCase()) {
      case 'before meal':
        return 'pre_meal';
      case 'after meal':
        return 'post_meal';
      case 'fasting':
        return 'fasting';
      case 'bedtime':
        return 'bedtime';
      default:
        return 'random';
    }
  }

  // Helper method to convert API reading type to UI format
  static String convertReadingTypeToUI(String apiType) {
    switch (apiType) {
      case 'pre_meal':
        return 'Before meal';
      case 'post_meal':
        return 'After meal';
      case 'fasting':
        return 'Fasting';
      case 'bedtime':
        return 'Bedtime';
      default:
        return 'Random';
    }
  }
}

class BloodGlucoseRepository {
  final ApiService _apiService;

  BloodGlucoseRepository(this._apiService);

  Future<List<BloodGlucoseReading>> getReadings() async {
    final response = await _apiService.get(ApiEndpoints.glucoseReadings);

    if (response == null || !(response is List)) return [];

    return (response as List<dynamic>)
        .map((item) =>
            BloodGlucoseReading.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BloodGlucoseReading> addReading(BloodGlucoseReading reading) async {
    final response = await _apiService.post(
      ApiEndpoints.glucoseReadings,
      reading.toJson(),
    );

    return BloodGlucoseReading.fromJson(response);
  }

  Future<BloodGlucoseReading> updateReading(BloodGlucoseReading reading) async {
    final response = await _apiService.patch(
      '${ApiEndpoints.glucoseReadings}/${reading.id}',
      reading.toJson(),
    );

    return BloodGlucoseReading.fromJson(response);
  }

  Future<void> deleteReading(String id) async {
    await _apiService.delete('${ApiEndpoints.glucoseReadings}/$id');
  }
}

class BloodGlucoseProvider with ChangeNotifier {
  late final BloodGlucoseRepository _repository;
  List<BloodGlucoseReading> _readings = [];
  bool _isLoading = false;
  String? _error;

  final AuthProvider _authProvider;

  BloodGlucoseProvider(
      ApiService apiService, SyncService syncService, this._authProvider) {
    _repository = BloodGlucoseRepository(apiService);
  }

  String? get currentUserId => _authProvider.userProfile?.id;

  List<BloodGlucoseReading> get readings => _readings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReadings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _readings = await _repository.getReadings();
      // Sort readings by timestamp (newest first)
      _readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      _error = e is ApiException
          ? '${e.message} (Status: ${e.statusCode})'
          : 'An unexpected error occurred: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateReading(BloodGlucoseReading reading) async {
    try {
      final updatedReading = await _repository.updateReading(reading);
      final index = _readings.indexWhere((r) => r.id == reading.id);
      if (index != -1) {
        _readings[index] = updatedReading;
        // Resort the list to maintain order
        _readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
    } catch (e) {
      _error = e is ApiException
          ? '${e.message} (Status: ${e.statusCode})'
          : 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> addReading(BloodGlucoseReading reading) async {
    try {
      final newReading = await _repository.addReading(reading);
      _readings.add(newReading);
      // Sort readings by timestamp (newest first)
      _readings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      _error = e is ApiException
          ? '${e.message} (Status: ${e.statusCode})'
          : 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteReading(String id) async {
    try {
      await _repository.deleteReading(id);
      _readings.removeWhere((reading) => reading.id == id);
      notifyListeners();
    } catch (e) {
      _error = e is ApiException
          ? '${e.message} (Status: ${e.statusCode})'
          : 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
    }
  }
}
