import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_colors.dart';
import '../utils/date_utils.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/meal_card.dart';
import '../widgets/progress_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToCalendar;

  const HomeScreen({super.key, required this.onNavigateToCalendar});

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon 🍱';
    } else {
      return 'Good Evening 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    if (mealProvider.isLoading || settingsProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final calculation = mealProvider.getCalculationResult(settingsProvider.settings);
    final now = DateTime.now();
    final todayMeal = mealProvider.todayMeal;
    final isAfternoonMarked = todayMeal?.afternoon ?? false;
    final isEveningMarked = todayMeal?.evening ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mess',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Meal Tracker',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.textDark,
                size: 20,
              ),
            ),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await mealProvider.loadMeals(settingsProvider: settingsProvider);
          await settingsProvider.loadSettings();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Current Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTimeGreeting(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppDateUtils.fullReadableFormat.format(now),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Hero Progress Card
              ProgressCard(calculation: calculation),
              const SizedBox(height: 24),

              // Today's Meal Quick Action Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Meals",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      mealProvider.setSelectedDate(DateTime.now());
                      onNavigateToCalendar();
                    },
                    icon: const Icon(Icons.calendar_month, size: 16),
                    label: const Text('View Calendar'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Afternoon Meal Card
              MealCard(
                type: MealType.afternoon,
                isMarked: isAfternoonMarked,
                onChanged: (_) {
                  mealProvider.toggleAfternoonMeal(
                    DateTime.now(),
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
                    DateTime.now(),
                    settingsProvider,
                  );
                },
              ),
              const SizedBox(height: 26),

              // Financial & Prepaid Overview Header
              const Text(
                'Plan & Consumption Overview',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              // 2x2 or 2x3 Metric Grid
              Row(
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      title: 'TOTAL PREPAID',
                      value: '${calculation.totalPrepaidMeals}',
                      subtitle: 'Prepaid meal package',
                      icon: Icons.confirmation_number_outlined,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.secondaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardStatCard(
                      title: 'CONSUMED',
                      value: '${calculation.consumedMeals}',
                      subtitle: '${calculation.totalAfternoonMeals} lunch • ${calculation.totalEveningMeals} dinner',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.secondaryDark,
                      iconBgColor: AppColors.secondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      title: 'AMOUNT PAID',
                      value: '₹${calculation.amountPaid.toStringAsFixed(0)}',
                      subtitle: 'For ${calculation.totalPrepaidMeals} total meals',
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.secondaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardStatCard(
                      title: 'COST PER MEAL',
                      value: '₹${calculation.costPerMeal.toStringAsFixed(2)}',
                      subtitle: 'Flat rate per meal',
                      icon: Icons.price_change_outlined,
                      iconColor: AppColors.warning,
                      iconBgColor: AppColors.warningLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      title: 'REMAINING MEALS',
                      value: '${calculation.remainingMeals}',
                      subtitle: calculation.remainingMeals == 0
                          ? 'Package completed! 🎉'
                          : '${calculation.remainingMeals} meals to go',
                      icon: Icons.hourglass_bottom_rounded,
                      iconColor: calculation.remainingMeals > 5
                          ? AppColors.primary
                          : AppColors.warning,
                      iconBgColor: calculation.remainingMeals > 5
                          ? AppColors.secondaryLight
                          : AppColors.warningLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DashboardStatCard(
                      title: 'REMAINING BALANCE',
                      value: '₹${calculation.remainingBalance.toStringAsFixed(0)}',
                      subtitle: 'Approximate value left',
                      icon: Icons.savings_outlined,
                      iconColor: AppColors.secondaryDark,
                      iconBgColor: AppColors.secondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
