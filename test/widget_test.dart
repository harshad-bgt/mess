import 'package:flutter_test/flutter_test.dart';
import 'package:mess/models/meal.dart';
import 'package:mess/models/app_settings.dart';

void main() {
  test('Meal and AppSettings models serializations', () {
    const meal = Meal(
      id: 1,
      mealDate: '2026-11-24',
      afternoon: true,
      evening: false,
    );

    final map = meal.toMap();
    expect(map['meal_date'], '2026-11-24');
    expect(map['afternoon'], 1);
    expect(map['evening'], 0);

    final reconstructed = Meal.fromMap(map);
    expect(reconstructed.mealDate, '2026-11-24');
    expect(reconstructed.afternoon, true);
    expect(reconstructed.evening, false);
    expect(reconstructed.dailyTotal, 1);

    const settings = AppSettings(
      id: 1,
      totalMeals: 30,
      amountPaid: 2000.0,
      afternoonReminder: '14:00',
      eveningReminder: '20:00',
      notificationsEnabled: true,
    );

    final settingsMap = settings.toMap();
    final reconstructedSettings = AppSettings.fromMap(settingsMap);
    expect(reconstructedSettings.totalMeals, 30);
    expect(reconstructedSettings.amountPaid, 2000.0);
    expect(reconstructedSettings.costPerMeal, closeTo(66.67, 0.01));
  });
}
