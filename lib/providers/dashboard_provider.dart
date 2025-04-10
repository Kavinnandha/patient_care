import 'package:flutter/material.dart';
import '../api_service.dart';

class DashboardSummary {
  final double currentGlucoseLevel;
  final String glucoseUnit;
  final int medicationsTaken;
  final int totalMedications;
  final String nextMedication;
  final String nextMedicationTime;
  final double waterIntake;
  final double waterGoal;
  final int steps;
  final int stepGoal;
  final int caloriesConsumed;
  final int mealsLogged;
  final int snacksLogged;

  DashboardSummary({
    required this.currentGlucoseLevel,
    this.glucoseUnit = 'mg/dL',
    required this.medicationsTaken,
    required this.totalMedications,
    required this.nextMedication,
    required this.nextMedicationTime,
    required this.waterIntake,
    required this.waterGoal,
    required this.steps,
    required this.stepGoal,
    required this.caloriesConsumed,
    required this.mealsLogged,
    required this.snacksLogged,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      currentGlucoseLevel: json['current_glucose_level'].toDouble(),
      glucoseUnit: json['glucose_unit'] ?? 'mg/dL',
      medicationsTaken: json['medications_taken'],
      totalMedications: json['total_medications'],
      nextMedication: json['next_medication'],
      nextMedicationTime: json['next_medication_time'],
      waterIntake: json['water_intake'].toDouble(),
      waterGoal: json['water_goal'].toDouble(),
      steps: json['steps'],
      stepGoal: json['step_goal'],
      caloriesConsumed: json['calories_consumed'],
      mealsLogged: json['meals_logged'],
      snacksLogged: json['snacks_logged'],
    );
  }
}

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService;
  DashboardSummary? _summary;
  bool _isLoading = false;
  String? _error;

  DashboardProvider(this._apiService);

  DashboardSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiEndpoints.dashboard);
      _summary = DashboardSummary.fromJson(response);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 