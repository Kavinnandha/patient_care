import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) {
      // Return null for web platform as we'll use API directly
      return null;
    }

    if (_database != null) return _database;
    _database = await _initDB('patient_care.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const integerType = 'INTEGER';
    const realType = 'REAL';
    const boolType = 'INTEGER';

    await db.execute('''
    CREATE TABLE glucose_readings (
      id $idType,
      patient_id $textType,
      glucose_level $realType,
      reading_type $textType,
      notes $textType,
      created_at $textType,
      synced $boolType DEFAULT 0
    )
    ''');

    await db.execute('''
    CREATE TABLE medications (
      id $idType,
      patient_id $textType,
      name $textType,
      dosage $textType,
      frequency $textType,
      start_date $textType,
      end_date $textType,
      prescribed_by $textType,
      notes $textType,
      synced $boolType DEFAULT 0
    )
    ''');

    await db.execute('''
    CREATE TABLE medical_records (
      id $idType,
      patient_id $textType,
      condition $textType,
      diagnosis_date $textType,
      treatment_plan $textType,
      doctor_notes $textType,
      synced $boolType DEFAULT 0
    )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add upgrade logic
    }
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    if (kIsWeb) return -1; // Skip for web platform

    final db = await database;
    if (db == null) return -1;

    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    if (kIsWeb) return []; // Return empty list for web platform

    final db = await database;
    if (db == null) return [];

    return await db.query(table, orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> queryUnsyncedRecords(String table) async {
    if (kIsWeb) return []; // Return empty list for web platform

    final db = await database;
    if (db == null) return [];

    return await db.query(
      table,
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC'
    );
  }

  Future<void> markAsSynced(String table, String id) async {
    if (kIsWeb) return; // Skip for web platform

    final db = await database;
    if (db == null) return;

    await db.update(
      table,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<void> batchMarkAsSynced(String table, List<String> ids) async {
    if (kIsWeb) return; // Skip for web platform

    final db = await database;
    if (db == null) return;

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final id in ids) {
        batch.update(
          table,
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [id]
        );
      }
      await batch.commit();
    });
  }

  Future<void> clearAllTables() async {
    if (kIsWeb) return; // Skip for web platform

    final db = await database;
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.execute('DELETE FROM glucose_readings');
      await txn.execute('DELETE FROM medications');
      await txn.execute('DELETE FROM medical_records');
    });
  }

  Future<void> close() async {
    if (kIsWeb) return; // Skip for web platform

    final db = await database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
