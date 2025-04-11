import 'package:flutter/foundation.dart';
import '../api_service.dart';
import '../services/sync_service.dart';
import '../models/dashboard_data.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService;
  final SyncService _syncService;
  bool _isLoading = false;
  String? _error;
  DashboardData _dashboardData = DashboardData.empty();

  DashboardProvider(this._apiService, this._syncService) {
    refreshDashboard();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardData get dashboardData => _dashboardData;

  // Forward getters from DashboardData
  double get currentGlucoseLevel => _dashboardData.currentGlucoseLevel;
  double get averageGlucoseToday => _dashboardData.averageGlucoseToday;
  Map<String, dynamic>? get latestVitals => _dashboardData.latestVitals;
  int get medicationsTaken => _dashboardData.medicationsTaken;
  int get totalMedications => _dashboardData.totalMedications;
  double get totalCaloriesToday => _dashboardData.totalCaloriesToday;

  Future<void> refreshDashboard() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load local data if not on web
      List<Map<String, dynamic>> localGlucoseReadings = [];
      List<Map<String, dynamic>> localMedications = [];
      List<Map<String, dynamic>> localVitalSigns = [];
      List<Map<String, dynamic>> localFoodIntake = [];

      if (!kIsWeb) {
        localGlucoseReadings = await _syncService.getGlucoseReadings();
        localMedications = await _syncService.getMedications();
        localVitalSigns = await _syncService.getVitalSigns();
        localFoodIntake = await _syncService.getFoodIntake();
      }

      // Fetch from API
      final response = await _apiService.get('dashboard');
      
      _dashboardData = DashboardData(
        recentGlucoseReadings: response['glucoseReadings'] ?? localGlucoseReadings,
        todaysMedications: response['medications'] ?? localMedications,
        recentFoodIntake: response['foodIntake'] ?? localFoodIntake,
        vitalSigns: response['vitalSigns'] ?? localVitalSigns,
        stats: response['stats'] ?? {
          'averageGlucose': 0.0,
          'medicationAdherence': 0.0,
          'lastVitalCheck': null,
        },
        lastUpdated: DateTime.now(),
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
      
      // If API fails, use local data as fallback
      if (!kIsWeb) {
        try {
          final localGlucoseReadings = await _syncService.getGlucoseReadings();
          final localMedications = await _syncService.getMedications();
          final localVitalSigns = await _syncService.getVitalSigns();
          final localFoodIntake = await _syncService.getFoodIntake();

          _dashboardData = DashboardData(
            recentGlucoseReadings: localGlucoseReadings,
            todaysMedications: localMedications,
            recentFoodIntake: localFoodIntake,
            vitalSigns: localVitalSigns,
            stats: {
              'averageGlucose': _calculateAverageGlucose(localGlucoseReadings),
              'medicationAdherence': _calculateMedicationAdherence(localMedications),
              'lastVitalCheck': _getLastVitalCheck(localVitalSigns),
            },
            lastUpdated: DateTime.now(),
          );
        } catch (localError) {
          print('Error loading local data: $localError');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _calculateAverageGlucose(List<Map<String, dynamic>> readings) {
    if (readings.isEmpty) return 0.0;
    final sum = readings.fold<double>(
      0.0,
      (sum, reading) => sum + (reading['glucoseLevel'] as num).toDouble(),
    );
    return sum / readings.length;
  }

  double _calculateMedicationAdherence(List<Map<String, dynamic>> medications) {
    if (medications.isEmpty) return 0.0;
    final takenCount = medications.where((med) => med['taken'] == true).length;
    return (takenCount / medications.length) * 100;
  }

  DateTime? _getLastVitalCheck(List<Map<String, dynamic>> vitalSigns) {
    if (vitalSigns.isEmpty) return null;
    return DateTime.parse(vitalSigns.last['timestamp'] as String);
  }

  Future<void> refresh() async {
    await refreshDashboard();
  }
}
