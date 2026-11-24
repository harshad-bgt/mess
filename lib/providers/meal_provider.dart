import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/app_settings.dart';
import '../repositories/meal_repository.dart';
import '../services/meal_calculation_service.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart';
import 'settings_provider.dart';

class MealProvider with ChangeNotifier {
  final MealRepository _repository;
  final NotificationService _notificationService;

  Map<String, Meal> _mealsMap = {};
  DateTime _selectedDate = AppDateUtils.dateOnly(DateTime.now());
  DateTime _focusedDay = DateTime.now();
  bool _isLoading = true;

  MealProvider({
    MealRepository? repository,
    NotificationService? notificationService,
  })  : _repository = repository ?? MealRepository(),
        _notificationService = notificationService ?? NotificationService.instance;

  Map<String, Meal> get mealsMap => _mealsMap;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDay => _focusedDay;
  bool get isLoading => _isLoading;

  /// Get the meal for the currently selected date
  Meal? get selectedDateMeal => getMealForDate(_selectedDate);

  /// Get today's meal
  Meal? get todayMeal => getMealForDate(DateTime.now());

  /// Get all meals ordered by date descending
  List<Meal> get allMeals {
    final list = _mealsMap.values.toList();
    list.sort((a, b) => b.mealDate.compareTo(a.mealDate));
    return list;
  }

  /// Check if today's afternoon meal is marked
  bool get isAfternoonMarkedToday => todayMeal?.afternoon ?? false;

  /// Check if today's evening meal is marked
  bool get isEveningMarkedToday => todayMeal?.evening ?? false;

  /// Fast lookup of meal for any DateTime
  Meal? getMealForDate(DateTime date) {
    final dateKey = AppDateUtils.toIsoDate(date);
    return _mealsMap[dateKey];
  }

  /// Calculate summary using the provided settings
  MealCalculationResult getCalculationResult(AppSettings settings) {
    return MealCalculationService.calculate(
      meals: _mealsMap.values,
      settings: settings,
    );
  }

  /// Calculate month summary
  MonthSummaryResult getMonthSummary(int year, int month, AppSettings settings) {
    final monthStr = month.toString().padLeft(2, '0');
    final prefix = '$year-$monthStr';
    
    final mealsInMonth = _mealsMap.values.where(
      (m) => m.mealDate.startsWith(prefix),
    );

    final overall = getCalculationResult(settings);

    return MealCalculationService.calculateMonthSummary(
      mealsInMonth: mealsInMonth,
      year: year,
      month: month,
      overallRemaining: overall.remainingMeals,
    );
  }

  Future<void> loadMeals({SettingsProvider? settingsProvider}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _mealsMap = await _repository.getMealsMap();
      if (settingsProvider != null) {
        await _syncReminders(settingsProvider.settings);
      }
    } catch (e) {
      debugPrint('Error loading meals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = AppDateUtils.dateOnly(date);
    notifyListeners();
  }

  void setFocusedDay(DateTime date) {
    _focusedDay = date;
    notifyListeners();
  }

  /// Toggle Afternoon Meal for a specific date
  Future<void> toggleAfternoonMeal(
    DateTime date,
    SettingsProvider settingsProvider,
  ) async {
    final dateKey = AppDateUtils.toIsoDate(date);
    final existing = _mealsMap[dateKey];

    final newAfternoon = !(existing?.afternoon ?? false);
    final newEvening = existing?.evening ?? false;

    await _saveMealState(
      dateKey: dateKey,
      afternoon: newAfternoon,
      evening: newEvening,
      settingsProvider: settingsProvider,
    );
  }

  /// Toggle Evening Meal for a specific date
  Future<void> toggleEveningMeal(
    DateTime date,
    SettingsProvider settingsProvider,
  ) async {
    final dateKey = AppDateUtils.toIsoDate(date);
    final existing = _mealsMap[dateKey];

    final newAfternoon = existing?.afternoon ?? false;
    final newEvening = !(existing?.evening ?? false);

    await _saveMealState(
      dateKey: dateKey,
      afternoon: newAfternoon,
      evening: newEvening,
      settingsProvider: settingsProvider,
    );
  }

  Future<void> _saveMealState({
    required String dateKey,
    required bool afternoon,
    required bool evening,
    required SettingsProvider settingsProvider,
  }) async {
    final existing = _mealsMap[dateKey];

    if (!afternoon && !evening) {
      // Both unmarked: we can either delete from db or keep with 0,0
      // Deleting cleans up empty rows while preserving state
      await _repository.deleteMeal(dateKey);
      _mealsMap.remove(dateKey);
    } else {
      final updatedMeal = (existing ?? Meal(mealDate: dateKey)).copyWith(
        afternoon: afternoon,
        evening: evening,
      );
      await _repository.saveMeal(updatedMeal);
      _mealsMap[dateKey] = updatedMeal;
    }

    notifyListeners();

    // Reschedule notifications if today's meal status changed
    final todayKey = AppDateUtils.toIsoDate(DateTime.now());
    if (dateKey == todayKey) {
      await _syncReminders(settingsProvider.settings);
    }
  }

  /// Sync reminders with notification service
  Future<void> _syncReminders(AppSettings settings) async {
    try {
      await _notificationService.syncReminders(
        settings: settings,
        isAfternoonMarkedToday: isAfternoonMarkedToday,
        isEveningMarkedToday: isEveningMarkedToday,
      );
    } catch (e) {
      debugPrint('Failed to sync reminders: $e');
    }
  }

  /// Reset all meals
  Future<void> resetAllMeals(SettingsProvider settingsProvider) async {
    await _repository.deleteAllMeals();
    _mealsMap.clear();
    notifyListeners();
    await _syncReminders(settingsProvider.settings);
  }
}
