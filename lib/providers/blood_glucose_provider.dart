import 'package:flutter/foundation.dart';
import '../api_service.dart';
import '../services/sync_service.dart';

class BloodGlucoseProvider with ChangeNotifier {
  final ApiService _apiService;
  final SyncService _syncService;
  bool _isLoading = false;
  List<Map<String, dynamic>> _readings = [];
  String? _error;

  BloodGlucoseProvider(this._apiService, this._syncService) {
    _loadReadings();
  }

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get readings => _readings;
  String? get error => _error;

  Future<void> _loadReadings() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Load local readings if not on web
      if (!kIsWeb) {
        _readings = await _syncService.getGlucoseReadings();
      }

      // Fetch from API
      final response = await _apiService.get('glucose-readings');
      if (response['readings'] != null) {
        _readings = List<Map<String, dynamic>>.from(response['readings']);
        notifyListeners();
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReading({
    required double glucoseLevel,
    required String readingType,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = {
        'glucoseLevel': glucoseLevel,
        'readingType': readingType,
        if (notes != null) 'notes': notes,
      };

      // Save to API first
      final response = await _apiService.post('glucose-readings', data);
      
      // Save locally if not on web
      if (!kIsWeb) {
        await _syncService.saveGlucoseReading(response['reading']);
      }

      await _loadReadings();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReading(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.delete('glucose-readings/$id');
      
      if (!kIsWeb) {
        await _syncService.deleteGlucoseReading(id);
      }

      await _loadReadings();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncReadings() async {
    if (kIsWeb) return; // Skip sync for web platform

    try {
      _isLoading = true;
      notifyListeners();

      await _syncService.syncGlucoseReadings();
      await _loadReadings();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
