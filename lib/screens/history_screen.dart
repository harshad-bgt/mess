import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_colors.dart';
import '../utils/date_utils.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback onNavigateToCalendar;

  const HistoryScreen({super.key, required this.onNavigateToCalendar});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final monthSummary = mealProvider.getMonthSummary(
      _displayedMonth.year,
      _displayedMonth.month,
      settingsProvider.settings,
    );

    // Filter meals for the displayed month
    final monthPrefix = '${_displayedMonth.year}-${_displayedMonth.month.toString().padLeft(2, '0')}';
    final monthMeals = mealProvider.allMeals
        .where((m) => m.mealDate.startsWith(monthPrefix) && m.hasAnyMeal)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meal History',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: AppColors.primary,
                    onPressed: _previousMonth,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMMM yyyy').format(_displayedMonth),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: AppColors.primary,
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Monthly Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Summary',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryMetric(
                          icon: Icons.wb_sunny_rounded,
                          iconColor: AppColors.afternoon,
                          label: 'Afternoon',
                          value: '${monthSummary.afternoonCount}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSummaryMetric(
                          icon: Icons.nightlight_round,
                          iconColor: AppColors.evening,
                          label: 'Evening',
                          value: '${monthSummary.eveningCount}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryMetric(
                          icon: Icons.check_circle_rounded,
                          iconColor: AppColors.secondaryDark,
                          label: 'This Month',
                          value: '${monthSummary.totalConsumed} meals',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSummaryMetric(
                          icon: Icons.hourglass_bottom_rounded,
                          iconColor: AppColors.primary,
                          label: 'Overall Left',
                          value: '${monthSummary.overallRemaining} meals',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // List of Meal Entries
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recorded Entries (${monthMeals.length} days)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (monthMeals.isNotEmpty)
                  const Text(
                    'Tap to edit',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (monthMeals.isEmpty)
              _buildEmptyState(context)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monthMeals.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final meal = monthMeals[index];
                  return _buildMealHistoryTile(
                    context: context,
                    meal: meal,
                    mealProvider: mealProvider,
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.no_meals_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No meals recorded for this month',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Switch to the Calendar tab or pick a day to start logging meals.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onNavigateToCalendar,
            icon: const Icon(Icons.calendar_month, size: 18),
            label: const Text('Open Calendar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealHistoryTile({
    required BuildContext context,
    required Meal meal,
    required MealProvider mealProvider,
  }) {
    final mealDate = AppDateUtils.parseIsoDate(meal.mealDate);
    final isToday = AppDateUtils.isSameDay(mealDate, DateTime.now());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          mealProvider.setSelectedDate(mealDate);
          mealProvider.setFocusedDay(mealDate);
          widget.onNavigateToCalendar();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Date Box
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary
                      : AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '${mealDate.day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isToday ? Colors.white : AppColors.primary,
                      ),
                    ),
                    Text(
                      DateFormat('EEE').format(mealDate).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isToday ? Colors.white70 : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Meal Status Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('d MMMM yyyy').format(mealDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          const Text(
                            '(Today)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStatusChip(
                          icon: Icons.wb_sunny_rounded,
                          label: 'Lunch',
                          isMarked: meal.afternoon,
                          activeColor: AppColors.afternoon,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(
                          icon: Icons.nightlight_round,
                          label: 'Dinner',
                          isMarked: meal.evening,
                          activeColor: AppColors.evening,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Daily Count Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: meal.hasBothMeals
                      ? AppColors.secondaryLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${meal.dailyTotal} meal${meal.dailyTotal == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: meal.hasBothMeals
                        ? AppColors.secondaryDark
                        : AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required bool isMarked,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isMarked ? activeColor.withValues(alpha: 0.12) : AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isMarked ? activeColor.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isMarked ? activeColor : AppColors.textLight,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isMarked ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
