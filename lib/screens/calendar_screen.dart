import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_colors.dart';
import '../utils/date_utils.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/meal_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final selectedDate = mealProvider.selectedDate;
    final focusedDay = mealProvider.focusedDay;
    final mealsMap = mealProvider.mealsMap;

    final selectedMeal = mealProvider.selectedDateMeal;
    final bool isAfternoonMarked = selectedMeal?.afternoon ?? false;
    final bool isEveningMarked = selectedMeal?.evening ?? false;
    final bool isToday = AppDateUtils.isSameDay(selectedDate, DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meal Calendar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // Jump to Today button
          if (!isToday)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () {
                  final now = DateTime.now();
                  mealProvider.setSelectedDate(now);
                  mealProvider.setFocusedDay(now);
                },
                icon: const Icon(Icons.today_rounded, size: 16),
                label: const Text('Today'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.secondaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Calendar Widget
            CalendarWidget(
              focusedDay: focusedDay,
              selectedDay: selectedDate,
              mealsMap: mealsMap,
              onDaySelected: (selected, focused) {
                mealProvider.setSelectedDate(selected);
                mealProvider.setFocusedDay(focused);
              },
              onPageChanged: (focused) {
                mealProvider.setFocusedDay(focused);
              },
            ),
            const SizedBox(height: 12),

            // Indicator Legend
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem(
                    color: AppColors.secondary,
                    label: 'Both Meals (2)',
                  ),
                  Container(
                    width: 1,
                    height: 14,
                    color: AppColors.divider,
                  ),
                  _buildLegendItem(
                    color: AppColors.warning,
                    label: 'Single Meal (1)',
                  ),
                  Container(
                    width: 1,
                    height: 14,
                    color: AppColors.divider,
                  ),
                  _buildLegendItem(
                    color: AppColors.textLight,
                    label: 'No Meals (0)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Selected Date Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppDateUtils.fullReadableFormat.format(selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'TODAY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getDailySummaryText(selectedMeal),
                        style: TextStyle(
                          fontSize: 12,
                          color: (selectedMeal?.hasAnyMeal ?? false)
                              ? AppColors.secondaryDark
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Afternoon Meal Card
            MealCard(
              type: MealType.afternoon,
              isMarked: isAfternoonMarked,
              onChanged: (_) {
                mealProvider.toggleAfternoonMeal(
                  selectedDate,
                  settingsProvider,
                );
              },
            ),
            const SizedBox(height: 12),

            // Evening Meal Card
            MealCard(
              type: MealType.evening,
              isMarked: isEveningMarked,
              onChanged: (_) {
                mealProvider.toggleEveningMeal(
                  selectedDate,
                  settingsProvider,
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static String _getDailySummaryText(Meal? meal) {
    if (meal == null || !meal.hasAnyMeal) {
      return 'No meals recorded for this date';
    }
    if (meal.hasBothMeals) {
      return 'Both meals recorded (2 meals total)';
    }
    if (meal.afternoon) {
      return 'Afternoon meal recorded (1 meal total)';
    }
    return 'Evening meal recorded (1 meal total)';
  }
}
