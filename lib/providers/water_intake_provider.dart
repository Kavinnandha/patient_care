import 'package:flutter/material.dart';
import '../api_service.dart';
import 'auth_provider.dart';

class WaterIntakeProvider with ChangeNotifier {
  final ApiService _apiService;
  final AuthProvider _authProvider;

  WaterIntakeProvider(this._apiService, this._authProvider);
  List _waterIntakeRecords = [];
  List _statistics = [];
  double _totalWaterIntake = 0.0;
  double _dailyGoal = 2500.0;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List get waterIntakeRecords => _waterIntakeRecords;
  List get statistics => _statistics;
  double get totalWaterIntake => _totalWaterIntake;
  double get dailyGoal => _dailyGoal;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  double get progressPercentage =>
      (totalWaterIntake / dailyGoal).clamp(0.0, 1.0);

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setDailyGoal(double goal) {
    if (goal >= 1000 && goal <= 5000) {
      _dailyGoal = goal;
      notifyListeners();
    }
  }

  Future<void> fetchWaterIntakeRecords(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final startDate =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final endDate = startDate.add(const Duration(days: 1));

      final response = await _apiService.getWaterIntakeRecords(
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      );

      _waterIntakeRecords =
          List<Map<String, dynamic>>.from(response['data'] ?? []);
      _calculateTotalWaterIntake();
    } catch (e) {
      print('Error fetching water intake records: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStatistics(String userId) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));

      final response = await _apiService.getWaterIntakeStats(
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      );

      _statistics = List<Map<String, dynamic>>.from(response['data'] ?? []);
      notifyListeners();
    } catch (e) {
      print('Error fetching statistics: $e');
    }
  }

  Future<void> addWaterIntakeRecord(String userId, double amount,
      {String source = 'manual', String? note}) async {
    try {
      await _apiService.addWaterIntakeRecord(
        userId,
        amount,
        source: source,
        note: note,
        dailyGoal: _dailyGoal,
      );
      await fetchWaterIntakeRecords(userId);
      await fetchStatistics(userId);
    } catch (e) {
      print('Error adding water intake record: $e');
      rethrow;
    }
  }

  Future<void> deleteWaterIntakeRecord(String id) async {
    try {
      await _apiService.deleteWaterIntakeRecord(id);
      final userId = await _apiService.getUserId();
      await fetchWaterIntakeRecords(userId);
      await fetchStatistics(userId);
    } catch (e) {
      print('Error deleting water intake record: $e');
      rethrow;
    }
  }

  void _calculateTotalWaterIntake() {
    _totalWaterIntake = _waterIntakeRecords.fold(
        0.0, (sum, record) => sum + (record['amount'] as num).toDouble());
  }

  Future<String> getUserId() async {
    return _authProvider.userProfile?.id ?? '';
  }
}
