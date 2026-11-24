import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/meal.dart';
import '../utils/app_colors.dart';
import '../utils/date_utils.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<String, Meal> mealsMap;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final Function(DateTime focusedDay) onPageChanged;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.mealsMap,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: focusedDay,
        currentDay: DateTime.now(),
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.primary,
            size: 26,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
            size: 26,
          ),
          headerPadding: EdgeInsets.symmetric(vertical: 6),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        selectedDayPredicate: (day) => AppDateUtils.isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          isTodayHighlighted: true,
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          defaultTextStyle: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
          weekendTextStyle: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          // Custom marker builder to display meal completion indicators
          markerBuilder: (context, date, events) {
            final dateKey = AppDateUtils.toIsoDate(date);
            final meal = mealsMap[dateKey];
            if (meal == null || !meal.hasAnyMeal) {
              return null;
            }

            final isSelected = AppDateUtils.isSameDay(selectedDay, date);
            final bool bothMeals = meal.hasBothMeals;

            return Positioned(
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: bothMeals
                          ? (isSelected ? Colors.white : AppColors.secondary)
                          : (isSelected ? Colors.white : AppColors.warning),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (bothMeals ? AppColors.secondary : AppColors.warning)
                              .withValues(alpha: 0.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
