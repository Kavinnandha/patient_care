import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../utils/database_helper.dart';
import '../api_service.dart';

class SyncService {
  final ApiService _apiService;
  final _syncInterval = const Duration(minutes: 15);
  Timer? _syncTimer;

  SyncService(this._apiService) {
    if (!kIsWeb) {
      _startSyncTimer();
    }
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      syncAll();
    });
  }

  void dispose() {
    _syncTimer?.cancel();
  }

  // Glucose Readings
  Future<List<Map<String, dynamic>>> getGlucoseReadings() async {
    if (kIsWeb) return [];
    final db = await DatabaseHelper.instance.database;
    if (db == null) return [];
    return await DatabaseHelper.instance.queryAll('glucose_readings');
  }

  Future<void> saveGlucoseReading(Map<String, dynamic> reading) async {
    if (kIsWeb) return;
    await DatabaseHelper.instance.insert('glucose_readings', {
      'id': reading['id'],
      'patient_id': reading['patientId'],
      'glucose_level': reading['glucoseLevel'],
      'reading_type': reading['readingType'],
      'notes': reading['notes'],
      'created_at': reading['createdAt'],
      'synced': 1,
    });
  }

  // Food Intake
  Future<List<Map<String, dynamic>>> getFoodIntake() async {
    if (kIsWeb) return [];
    final db = await DatabaseHelper.instance.database;
    if (db == null) return [];
    return await DatabaseHelper.instance.queryAll('food_intake');
  }

  Future<void> saveFoodIntake(Map<String, dynamic> intake) async {
    if (kIsWeb) return;
    await DatabaseHelper.instance.insert('food_intake', {
      'id': intake['id'],
      'food_name': intake['foodName'],
      'calories': intake['calories'],
      'carbs': intake['carbs'],
      'protein': intake['protein'],
      'fat': intake['fat'],
      'meal_time': intake['mealTime'],
      'notes': intake['notes'],
      'created_at': intake['createdAt'],
      'synced': 1,
    });
  }

  // Vital Signs
  Future<List<Map<String, dynamic>>> getVitalSigns() async {
    if (kIsWeb) return [];
    final db = await DatabaseHelper.instance.database;
    if (db == null) return [];
    return await DatabaseHelper.instance.queryAll('vital_signs');
  }

  Future<void> saveVitalSigns(Map<String, dynamic> vitalSigns) async {
    if (kIsWeb) return;
    await DatabaseHelper.instance.insert('vital_signs', {
      'id': vitalSigns['id'],
      'type': vitalSigns['type'],
      'value': vitalSigns['value'],
      'unit': vitalSigns['unit'],
      'notes': vitalSigns['notes'],
      'timestamp': vitalSigns['timestamp'],
      'synced': 1,
    });
  }

  // Medication Logs
  Future<List<Map<String, dynamic>>> getMedicationLogs() async {
    if (kIsWeb) return [];
    final db = await DatabaseHelper.instance.database;
    if (db == null) return [];
    return await DatabaseHelper.instance.queryAll('medication_logs');
  }

  Future<void> logMedicationTaken(Map<String, dynamic> log) async {
    if (kIsWeb) return;
    await DatabaseHelper.instance.insert('medication_logs', {
      'id': log['id'],
      'medication_id': log['medicationId'],
      'taken_at': log['takenAt'],
      'dosage_taken': log['dosageTaken'],
      'notes': log['notes'],
      'synced': 1,
    });
  }

  Future<void> deleteGlucoseReading(String id) async {
    if (kIsWeb) return;
    final db = await DatabaseHelper.instance.database;
    if (db == null) return;
    await db.delete(
      'glucose_readings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> syncGlucoseReadings() async {
    if (kIsWeb) return;
    final unsyncedReadings = await DatabaseHelper.instance.queryUnsyncedRecords('glucose_readings');
    
    for (final reading in unsyncedReadings) {
      try {
        await _apiService.post('glucose-readings', {
          'glucoseLevel': reading['glucose_level'],
          'readingType': reading['reading_type'],
          'notes': reading['notes'],
          'createdAt': reading['created_at'],
        });
        await DatabaseHelper.instance.markAsSynced('glucose_readings', reading['id']);
      } catch (e) {
        print('Error syncing glucose reading: $e');
      }
    }
  }

  // Medications
  Future<List<Map<String, dynamic>>> getMedications() async {
    if (kIsWeb) return [];
    return await DatabaseHelper.instance.queryAll('medications');
  }

  Future<void> saveMedication(Map<String, dynamic> medication) async {
    if (kIsWeb) return;
    await DatabaseHelper.instance.insert('medications', {
      'id': medication['id'],
      'patient_id': medication['patientId'],
      'name': medication['name'],
      'dosage': medication['dosage'],
      'frequency': medication['frequency'],
      'time_of_day': medication['timeOfDay'],
      'start_date': medication['startDate'],
      'end_date': medication['endDate'],
      'prescribed_by': medication['prescribedBy'],
      'notes': medication['notes'],
      'synced': 1,
    });
  }

  // Medical Records
  Future<List<Map<String, dynamic>>> getMedicalRecords() async {
    if (kIsWeb) return [];
    return await DatabaseHelper.instance.queryAll('medical_records');
  }

  Future<void> saveMedicalRecord(Map<String, dynamic> record) async {
    if (kIsWeb) return;
    await DatabaseHelper.instance.insert('medical_records', {
      'id': record['id'],
      'patient_id': record['patientId'],
      'condition': record['condition'],
      'diagnosis_date': record['diagnosisDate'],
      'treatment_plan': record['treatmentPlan'],
      'doctor_notes': record['doctorNotes'],
      'synced': 1,
    });
  }

  // Sync all data
  Future<void> syncAll() async {
    if (kIsWeb) return;
    await syncGlucoseReadings();
    // Add other sync methods here as needed
  }
}
