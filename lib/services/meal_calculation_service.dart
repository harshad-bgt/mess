import 'dart:math';
import '../models/meal.dart';
import '../models/app_settings.dart';

class MealCalculationResult {
  final int totalPrepaidMeals;
  final int consumedMeals;
  final int remainingMeals;
  final double amountPaid;
  final double costPerMeal;
  final double remainingBalance;
  final double progress; // 0.0 to 1.0
  final int totalAfternoonMeals;
  final int totalEveningMeals;

  const MealCalculationResult({
    required this.totalPrepaidMeals,
    required this.consumedMeals,
    required this.remainingMeals,
    required this.amountPaid,
    required this.costPerMeal,
    required this.remainingBalance,
    required this.progress,
    required this.totalAfternoonMeals,
    required this.totalEveningMeals,
  });

  int get progressPercentage => (progress * 100).round();
}

class MonthSummaryResult {
  final int year;
  final int month;
  final int afternoonCount;
  final int eveningCount;
  final int totalConsumed;
  final int overallRemaining;

  const MonthSummaryResult({
    required this.year,
    required this.month,
    required this.afternoonCount,
    required this.eveningCount,
    required this.totalConsumed,
    required this.overallRemaining,
  });
}

class MealCalculationService {
  /// Calculate comprehensive meal metrics across all meals
  static MealCalculationResult calculate({
    required Iterable<Meal> meals,
    required AppSettings settings,
  }) {
    int afternoonCount = 0;
    int eveningCount = 0;

    for (final meal in meals) {
      if (meal.afternoon) afternoonCount++;
      if (meal.evening) eveningCount++;
    }

    final int consumed = afternoonCount + eveningCount;
    final int total = settings.totalMeals;
    // Remaining meals must never drop below 0
    final int remaining = max(0, total - consumed);

    final double costPerMeal = settings.costPerMeal;
    final double remainingBalance = remaining * costPerMeal;
    
    final double progress = total > 0
        ? (consumed / total).clamp(0.0, 1.0)
        : 0.0;

    return MealCalculationResult(
      totalPrepaidMeals: total,
      consumedMeals: consumed,
      remainingMeals: remaining,
      amountPaid: settings.amountPaid,
      costPerMeal: costPerMeal,
      remainingBalance: remainingBalance,
      progress: progress,
      totalAfternoonMeals: afternoonCount,
      totalEveningMeals: eveningCount,
    );
  }

  /// Calculate summary for a specific month
  static MonthSummaryResult calculateMonthSummary({
    required Iterable<Meal> mealsInMonth,
    required int year,
    required int month,
    required int overallRemaining,
  }) {
    int afternoonCount = 0;
    int eveningCount = 0;

    for (final meal in mealsInMonth) {
      if (meal.afternoon) afternoonCount++;
      if (meal.evening) eveningCount++;
    }

    return MonthSummaryResult(
      year: year,
      month: month,
      afternoonCount: afternoonCount,
      eveningCount: eveningCount,
      totalConsumed: afternoonCount + eveningCount,
      overallRemaining: overallRemaining,
    );
  }
}
