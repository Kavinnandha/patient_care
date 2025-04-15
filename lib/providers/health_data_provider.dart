import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../api_service.dart';

class HealthDataProvider with ChangeNotifier {
  final SyncService _syncService;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> _glucoseReadings = [];
  List<Map<String, dynamic>> _foodIntake = [];
  List<Map<String, dynamic>> _medications = [];
  List<Map<String, dynamic>> _medicationLogs = [];
  List<Map<String, dynamic>> _vitalSigns = [];

  HealthDataProvider(this._syncService) {
    _initializeData();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get glucoseReadings => _glucoseReadings;
  List<Map<String, dynamic>> get foodIntake => _foodIntake;
  List<Map<String, dynamic>> get medications => _medications;
  List<Map<String, dynamic>> get medicationLogs => _medicationLogs;
  List<Map<String, dynamic>> get vitalSigns => _vitalSigns;

  Future<void> _initializeData() async {
    await Future.wait([
      loadGlucoseReadings(),
      loadFoodIntake(),
      loadMedications(),
      loadMedicationLogs(),
      loadVitalSigns(),
    ]);
  }

  // Glucose Readings
  Future<void> addGlucoseReading(double glucoseLevel, String readingType, {String? notes}) async {
    final apiService = ApiService();
    try {
      _isLoading = true;
      notifyListeners();

      final userId = await apiService.getUserId();

      final reading = {
        'id': DateTime.now().toIso8601String(),
        'patientId': userId,
        'glucoseLevel': glucoseLevel,
        'readingType': readingType,
        'notes': notes,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _syncService.saveGlucoseReading(reading);
      await loadGlucoseReadings();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGlucoseReadings() async {
    try {
      _glucoseReadings = await _syncService.getGlucoseReadings();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Food Intake
  Future<void> addFoodIntake({
    required String foodName,
    required int calories,
    required double carbs,
    required double protein,
    required double fat,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final intake = {
        'id': DateTime.now().toIso8601String(),
        'foodName': foodName,
        'calories': calories,
        'carbs': carbs,
        'protein': protein,
        'fat': fat,
        'notes': notes,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _syncService.saveFoodIntake(intake);
      await loadFoodIntake();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFoodIntake() async {
    try {
      _foodIntake = await _syncService.getFoodIntake();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Medications
  Future<void> addMedication({
    required String name,
    required String dosage,
    required String frequency,
    required String timeOfDay,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final medication = {
        'id': DateTime.now().toIso8601String(),
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'timeOfDay': timeOfDay,
        'notes': notes,
        'startDate': DateTime.now().toIso8601String(),
      };

      await _syncService.saveMedication(medication);
      await loadMedications();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logMedicationTaken(String medicationId, String dosageTaken) async {
    try {
      _isLoading = true;
      notifyListeners();

      final log = {
        'id': DateTime.now().toIso8601String(),
        'medicationId': medicationId,
        'dosageTaken': dosageTaken,
        'takenAt': DateTime.now().toIso8601String(),
      };

      await _syncService.logMedicationTaken(log);
      await loadMedicationLogs();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMedications() async {
    try {
      _medications = await _syncService.getMedications();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadMedicationLogs() async {
    try {
      _medicationLogs = await _syncService.getMedicationLogs();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Vital Signs
  Future<void> addVitalSigns({
    required int bloodPressureSystolic,
    required int bloodPressureDiastolic,
    required int heartRate,
    required double temperature,
    required int oxygenSaturation,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final vitalSigns = {
        'id': DateTime.now().toIso8601String(),
        'type': 'full_check',
        'value': {
          'systolic': bloodPressureSystolic,
          'diastolic': bloodPressureDiastolic,
          'heartRate': heartRate,
          'temperature': temperature,
          'oxygenSaturation': oxygenSaturation,
        },
        'unit': {
          'bloodPressure': 'mmHg',
          'heartRate': 'bpm',
          'temperature': '°C',
          'oxygenSaturation': '%',
        },
        'notes': notes,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _syncService.saveVitalSigns(vitalSigns);
      await loadVitalSigns();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVitalSigns() async {
    try {
      _vitalSigns = await _syncService.getVitalSigns();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await _initializeData();
  }
}
