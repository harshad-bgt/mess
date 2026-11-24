import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/meal_provider.dart';
import 'providers/settings_provider.dart';
import 'repositories/meal_repository.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize notifications
  final notificationService = NotificationService.instance;
  await notificationService.initialize();
  // Request permissions in background
  notificationService.requestPermissions();

  final mealRepository = MealRepository();
  final settingsProvider = SettingsProvider(repository: mealRepository);
  final mealProvider = MealProvider(
    repository: mealRepository,
    notificationService: notificationService,
  );

  // Load persistent data from SQLite
  await settingsProvider.loadSettings();
  await mealProvider.loadMeals(settingsProvider: settingsProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<MealProvider>.value(value: mealProvider),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mess – Meal Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MessApp(),
    );
  }
}
