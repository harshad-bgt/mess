import '../database/database_helper.dart';
import '../models/meal.dart';
import '../models/app_settings.dart';

class MealRepository {
  final DatabaseHelper _dbHelper;

  MealRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Meal>> getAllMeals() async {
    return await _dbHelper.getAllMeals();
  }

  Future<Map<String, Meal>> getMealsMap() async {
    final list = await _dbHelper.getAllMeals();
    final map = <String, Meal>{};
    for (final meal in list) {
      map[meal.mealDate] = meal;
    }
    return map;
  }

  Future<Meal?> getMealByDate(String dateStr) async {
    return await _dbHelper.getMealByDate(dateStr);
  }

  Future<List<Meal>> getMealsForMonth(int year, int month) async {
    return await _dbHelper.getMealsForMonth(year, month);
  }

  Future<void> saveMeal(Meal meal) async {
    await _dbHelper.saveMeal(meal);
  }

  Future<void> deleteMeal(String dateStr) async {
    await _dbHelper.deleteMeal(dateStr);
  }

  Future<void> deleteAllMeals() async {
    await _dbHelper.deleteAllMeals();
  }

  Future<AppSettings> getSettings() async {
    return await _dbHelper.getSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _dbHelper.saveSettings(settings);
  }

  Future<void> resetAllData({bool resetSettings = false}) async {
    await _dbHelper.resetAllData(resetSettings: resetSettings);
  }
}
