import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../repositories/meal_repository.dart';

class SettingsProvider with ChangeNotifier {
  final MealRepository _repository;
  AppSettings _settings = const AppSettings();
  bool _isLoading = true;

  SettingsProvider({MealRepository? repository})
      : _repository = repository ?? MealRepository();

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  int get totalMeals => _settings.totalMeals;
  double get amountPaid => _settings.amountPaid;
  String get afternoonReminder => _settings.afternoonReminder;
  String get eveningReminder => _settings.eveningReminder;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  double get costPerMeal => _settings.costPerMeal;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _repository.getSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTotalMeals(int totalMeals) async {
    if (totalMeals <= 0) return;
    _settings = _settings.copyWith(totalMeals: totalMeals);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateAmountPaid(double amount) async {
    if (amount < 0) return;
    _settings = _settings.copyWith(amountPaid: amount);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateAfternoonReminder(String time) async {
    _settings = _settings.copyWith(afternoonReminder: time);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateEveningReminder(String time) async {
    _settings = _settings.copyWith(eveningReminder: time);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await _repository.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    const defaultSettings = AppSettings();
    _settings = defaultSettings;
    await _repository.saveSettings(_settings);
    notifyListeners();
  }
}
