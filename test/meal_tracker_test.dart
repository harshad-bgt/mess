import 'package:flutter_test/flutter_test.dart';
import 'package:mess/models/meal.dart';
import 'package:mess/models/app_settings.dart';
import 'package:mess/services/meal_calculation_service.dart';

void main() {
  group('Meal Calculation Logic & Scenario Tests', () {
    const settings = AppSettings(
      totalMeals: 30,
      amountPaid: 2000.0,
      afternoonReminder: '14:00',
      eveningReminder: '20:00',
      notificationsEnabled: true,
    );

    test('Initial state: 0 consumed, 30 remaining, ₹2000 balance', () {
      final result = MealCalculationService.calculate(
        meals: [],
        settings: settings,
      );

      expect(result.totalPrepaidMeals, 30);
      expect(result.consumedMeals, 0);
      expect(result.remainingMeals, 30);
      expect(result.costPerMeal, closeTo(66.67, 0.01));
      expect(result.remainingBalance, closeTo(2000.0, 0.01));
      expect(result.progress, 0.0);
    });

    test('Scenario 1 & 2: Mark afternoon meal -> consumed count increases by 1', () {
      final meals = [
        const Meal(mealDate: '2026-11-20', afternoon: true, evening: false),
      ];

      final result = MealCalculationService.calculate(
        meals: meals,
        settings: settings,
      );

      expect(result.consumedMeals, 1);
      expect(result.remainingMeals, 29);
      expect(result.totalAfternoonMeals, 1);
      expect(result.totalEveningMeals, 0);
      expect(result.remainingBalance, closeTo(29 * 66.6666, 0.1));
    });

    test('Scenario 3: Unmark a meal -> consumed count decreases by 1', () {
      // First marked both
      var meals = [
        const Meal(mealDate: '2026-11-20', afternoon: true, evening: true),
      ];
      var result = MealCalculationService.calculate(
        meals: meals,
        settings: settings,
      );
      expect(result.consumedMeals, 2);

      // Unmarked afternoon
      meals = [
        const Meal(mealDate: '2026-11-20', afternoon: false, evening: true),
      ];
      result = MealCalculationService.calculate(
        meals: meals,
        settings: settings,
      );
      expect(result.consumedMeals, 1);
      expect(result.remainingMeals, 29);
    });

    test('Scenario 4: Mark both meals -> consumed count increases by 2', () {
      final meals = [
        const Meal(mealDate: '2026-11-20', afternoon: true, evening: true),
        const Meal(mealDate: '2026-11-21', afternoon: true, evening: false),
      ];

      final result = MealCalculationService.calculate(
        meals: meals,
        settings: settings,
      );

      expect(result.consumedMeals, 3);
      expect(result.remainingMeals, 27);
      expect(result.totalAfternoonMeals, 2);
      expect(result.totalEveningMeals, 1);
    });

    test('Scenario 6: Change previous month meal -> dashboard recalculates', () {
      final meals = [
        const Meal(mealDate: '2026-10-15', afternoon: true, evening: true), // previous month
        const Meal(mealDate: '2026-11-20', afternoon: true, evening: false), // current month
      ];

      final result = MealCalculationService.calculate(
        meals: meals,
        settings: settings,
      );

      expect(result.consumedMeals, 3);
      expect(result.remainingMeals, 27);

      // Calculate monthly summary for October
      final octSummary = MealCalculationService.calculateMonthSummary(
        mealsInMonth: meals.where((m) => m.mealDate.startsWith('2026-10')),
        year: 2026,
        month: 10,
        overallRemaining: result.remainingMeals,
      );

      expect(octSummary.totalConsumed, 2);
      expect(octSummary.afternoonCount, 1);
      expect(octSummary.eveningCount, 1);
    });

    test('Scenario 7: Complete all 30 meals -> remaining count becomes zero (never negative)', () {
      // 16 days with 2 meals = 32 meals (more than 30)
      final List<Meal> meals = List.generate(
        16,
        (i) => Meal(
          mealDate: '2026-11-${(i + 1).toString().padLeft(2, '0')}',
          afternoon: true,
          evening: true,
        ),
      );

      final result = MealCalculationService.calculate(
        meals: meals,
        settings: settings,
      );

      expect(result.consumedMeals, 32);
      // Remaining must be capped at 0 and never become negative
      expect(result.remainingMeals, 0);
      expect(result.remainingBalance, 0.0);
      expect(result.progress, 1.0);
    });

    test('Configurable settings: Total meals 40, Amount ₹2400', () {
      const customSettings = AppSettings(
        totalMeals: 40,
        amountPaid: 2400.0,
      );

      expect(customSettings.costPerMeal, 60.0);

      final meals = [
        const Meal(mealDate: '2026-11-20', afternoon: true, evening: true),
      ];

      final result = MealCalculationService.calculate(
        meals: meals,
        settings: customSettings,
      );

      expect(result.totalPrepaidMeals, 40);
      expect(result.consumedMeals, 2);
      expect(result.remainingMeals, 38);
      expect(result.costPerMeal, 60.0);
      expect(result.remainingBalance, 38 * 60.0);
    });
  });
}
