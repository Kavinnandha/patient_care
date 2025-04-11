import '../api_service.dart';
import '../models/blood_glucose_reading.dart';

class BloodGlucoseRepository {
  final ApiService _apiService;
  
  BloodGlucoseRepository(this._apiService);
  
  Future<List<BloodGlucoseReading>> getReadings() async {
    final response = await _apiService.get('blood-glucose');
    
    return (response as List)
        .map((item) => BloodGlucoseReading.fromJson(item))
        .toList();
  }
  
  Future<BloodGlucoseReading> addReading(BloodGlucoseReading reading) async {
    final response = await _apiService.post(
      'blood-glucose',
      reading.toJson(),
    );
    
    return BloodGlucoseReading.fromJson(response);
  }
  
  Future<BloodGlucoseReading> updateReading(BloodGlucoseReading reading) async {
    final response = await _apiService.put(
      'blood-glucose/${reading.id}',
      reading.toJson(),
    );
    
    return BloodGlucoseReading.fromJson(response);
  }
  
  Future<void> deleteReading(int id) async {
    await _apiService.delete('blood-glucose/$id');
  }
}
