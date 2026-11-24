import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/meal_provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_colors.dart';

class MessApp extends StatefulWidget {
  const MessApp({super.key});

  @override
  State<MessApp> createState() => _MessAppState();
}

class _MessAppState extends State<MessApp> {
  int _currentIndex = 0;
  StreamSubscription<String?>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    _notificationSubscription = NotificationService
        .instance.selectNotificationStream.stream
        .listen((String? payload) {
      if (payload == 'today_meal' && mounted) {
        // Tapping the notification opens the app and navigates to today's selected meal
        final mealProvider = context.read<MealProvider>();
        mealProvider.setSelectedDate(DateTime.now());
        mealProvider.setFocusedDay(DateTime.now());
        setState(() {
          _currentIndex = 1; // Calendar tab
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _navigateToCalendar() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onNavigateToCalendar: _navigateToCalendar),
      const CalendarScreen(),
      HistoryScreen(onNavigateToCalendar: _navigateToCalendar),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: AppColors.secondaryLight,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_rounded, color: AppColors.primary),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
