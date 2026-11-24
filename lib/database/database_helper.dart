import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/meal.dart';
import '../models/app_settings.dart';

class DatabaseHelper {
  static const String _databaseName = 'mess_tracker.db';
  static const int _databaseVersion = 1;

  static const String tableMeals = 'meals';
  static const String tableSettings = 'settings';

  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableMeals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_date TEXT NOT NULL,
        afternoon INTEGER DEFAULT 0,
        evening INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        UNIQUE(meal_date)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableSettings (
        id INTEGER PRIMARY KEY,
        total_meals INTEGER DEFAULT 30,
        amount_paid REAL DEFAULT 2000.0,
        afternoon_reminder TEXT DEFAULT '14:00',
        evening_reminder TEXT DEFAULT '20:00',
        notifications_enabled INTEGER DEFAULT 1
      )
    ''');

    // Insert default settings
    await db.insert(
      tableSettings,
      const AppSettings().toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ===================== MEALS OPERATIONS =====================

  Future<List<Meal>> getAllMeals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      orderBy: 'meal_date DESC',
    );
    return maps.map((m) => Meal.fromMap(m)).toList();
  }

  Future<Meal?> getMealByDate(String dateStr) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      where: 'meal_date = ?',
      whereArgs: [dateStr],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Meal.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Meal>> getMealsForMonth(int year, int month) async {
    final db = await database;
    final monthStr = month.toString().padLeft(2, '0');
    final pattern = '$year-$monthStr-%';
    final List<Map<String, dynamic>> maps = await db.query(
      tableMeals,
      where: 'meal_date LIKE ?',
      whereArgs: [pattern],
      orderBy: 'meal_date ASC',
    );
    return maps.map((m) => Meal.fromMap(m)).toList();
  }

  /// Upsert meal: if both afternoon & evening are false, we can either keep or delete.
  /// Keeping with 0 & 0 or upserting ensures date tracking.
  Future<int> saveMeal(Meal meal) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final existing = await getMealByDate(meal.mealDate);
    if (existing == null) {
      final newMeal = meal.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      return await db.insert(
        tableMeals,
        newMeal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      final updatedMeal = meal.copyWith(
        id: existing.id,
        createdAt: existing.createdAt ?? now,
        updatedAt: now,
      );
      return await db.update(
        tableMeals,
        updatedMeal.toMap(),
        where: 'meal_date = ?',
        whereArgs: [meal.mealDate],
      );
    }
  }

  Future<int> deleteMeal(String dateStr) async {
    final db = await database;
    return await db.delete(
      tableMeals,
      where: 'meal_date = ?',
      whereArgs: [dateStr],
    );
  }

  Future<int> deleteAllMeals() async {
    final db = await database;
    return await db.delete(tableMeals);
  }

  // ===================== SETTINGS OPERATIONS =====================

  Future<AppSettings> getSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSettings,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return AppSettings.fromMap(maps.first);
    }
    // Return default and ensure it is saved
    const defaultSettings = AppSettings();
    await saveSettings(defaultSettings);
    return defaultSettings;
  }

  Future<int> saveSettings(AppSettings settings) async {
    final db = await database;
    return await db.insert(
      tableSettings,
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Reset all meal records and restore settings if requested
  Future<void> resetAllData({bool resetSettings = false}) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(tableMeals);
      if (resetSettings) {
        await txn.delete(tableSettings);
        await txn.insert(
          tableSettings,
          const AppSettings().toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
