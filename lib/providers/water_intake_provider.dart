import 'package:flutter/material.dart';
import '../api_service.dart';

class WaterIntakeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List _waterIntakeRecords = [];
  double _totalWaterIntake = 0.0;

  List get waterIntakeRecords => _waterIntakeRecords;
  double get totalWaterIntake => _totalWaterIntake;

  Future<void> fetchWaterIntakeRecords(String userId) async {
    final records = await _apiService.getWaterIntakeRecords(userId);
    _waterIntakeRecords = records;
    _calculateTotalWaterIntake();
    notifyListeners();
  }

  Future<void> addWaterIntakeRecord(String userId, double amount) async {
    await _apiService.addWaterIntakeRecord(userId, amount);
    await fetchWaterIntakeRecords(userId);
  }

  Future<void> deleteWaterIntakeRecord(String id) async {
    await _apiService.deleteWaterIntakeRecord(id);
    final userId = await _apiService.getUserId();
    await fetchWaterIntakeRecords(userId);
  }

  void _calculateTotalWaterIntake() {
    _totalWaterIntake =
        _waterIntakeRecords.fold(0, (sum, record) => sum + record['amount']);
  }
}
