# Mess – Meal Tracker 🍱

A production-quality, offline-first Android application designed for college students and mess members to track prepaid meals, monitor consumed and remaining counts, calculate meal finances, and receive smart daily meal reminders.

Developed with **Flutter**, **Dart**, **SQLite (sqflite)**, **Local Notifications**, and **Material 3**.

---

## 🌟 Key Features

### 1. Home Dashboard
- **Real-Time Financial & Consumption Metrics:**
  - Total Prepaid Meals (Default: 30)
  - Consumed Meals (Dynamically calculated from SQLite)
  - Remaining Meals (Guaranteed $\ge 0$, never goes negative)
  - Total Amount Paid (Default: ₹2,000)
  - Cost Per Meal (Default: ₹66.67)
  - Approximate Remaining Balance in ₹
- **Large Circular Progress Ring:** Visualizes percentage of prepaid meals consumed.
- **Quick Meal Checkboxes:** Immediate toggle for Today's Afternoon (Lunch) and Evening (Dinner) meals.

### 2. Interactive Monthly Calendar (Main Feature)
- Monthly calendar powered by `table_calendar` with navigation.
- **Visual Completion Indicators:**
  - 🟢 **Green Indicator:** Both Afternoon & Evening meals marked.
  - 🟠 **Orange Indicator:** Exactly one meal marked.
  - ⚪ **No Indicator:** No meals recorded.
- **Date Detail Section:**
  - Select any date (past, present, or future) to inspect or modify entries.
  - Two meal cards (☀️ Afternoon, 🌙 Evening) with smooth checkbox toggling.
  - Immediate SQLite persistence on every tap.

### 3. Smart Daily Notification & Reminder System
- **Schedule:**
  - 🍱 **Afternoon Reminder:** 2:00 PM (Configurable)
  - 🌙 **Evening Reminder:** 8:00 PM (Configurable)
- **Smart Skip:** If the user has already eaten and marked the meal for today, today's reminder is automatically bypassed.
- **Reboot Rescheduling:** Notifications survive device restarts via `RECEIVE_BOOT_COMPLETED` receivers.
- **Interactive Routing:** Tapping the notification opens the app and directly highlights today's meal entry.
- **Test Alert Button:** Instant trigger button in Settings to verify device permissions.

### 4. Meal History & Monthly Summaries
- Monthly breakdown:
  - Total Afternoon meals in that month
  - Total Evening meals in that month
  - Total meals consumed in that month
  - Overall remaining package balance
- Chronological list of recorded days with meal badges and meal count.
- Tap any entry to jump straight into the Calendar for quick editing.

### 5. Configurable Settings & Data Management
- Customize Total Prepaid Meals (e.g., 30, 40, 50 meals for new terms).
- Customize Total Amount Paid (recalculates cost per meal and balances dynamically).
- Time pickers for Afternoon and Evening reminders.
- Global notification toggle.
- Safe data reset with confirmation dialog.

---

## 🛠️ Technology Stack & Architecture

- **Framework:** Flutter 3.47 (Channel stable)
- **Language:** Dart 3.13
- **Local Database:** SQLite via `sqflite` (Database: `mess_tracker.db`)
- **State Management:** `provider`
- **Calendar:** `table_calendar`
- **Notifications:** `flutter_local_notifications` + `timezone`
- **Date Formatting:** `intl`
- **Platform:** Android 8.0+ (API 26+)
- **Design System:** Material 3 with Forest Green (`#14532D`), Fresh Green (`#22C55E`), and Charcoal theme.

### Project Structure

```
lib/
├── app.dart                   # Navigation and notification routing
├── database/
│   └── database_helper.dart   # SQLite database schema, migrations & queries
├── main.dart                  # Application entry point & provider bootstrapping
├── models/
│   ├── app_settings.dart      # Settings data model & calculations
│   └── meal.dart              # Daily meal record data model
├── providers/
│   ├── meal_provider.dart     # Meal state management & reactive calendar
│   └── settings_provider.dart # Persistent user configuration provider
├── repositories/
│   └── meal_repository.dart   # Data abstraction layer for SQLite
├── screens/
│   ├── calendar_screen.dart   # Monthly calendar with indicators & meal cards
│   ├── history_screen.dart    # Historical records & monthly totals
│   ├── home_screen.dart       # Dashboard with circular progress & stat cards
│   └── settings_screen.dart   # Plan configuration, reminders & reset
├── services/
│   ├── meal_calculation_service.dart # Financial & meal count math
│   └── notification_service.dart     # Local notifications & time scheduling
├── utils/
│   ├── app_colors.dart        # Unified brand color palette
│   ├── app_theme.dart         # Material 3 theme configurations
│   └── date_utils.dart        # ISO date utilities and relative formatting
└── widgets/
    ├── calendar_widget.dart   # TableCalendar wrapper with custom markers
    ├── dashboard_stat_card.dart # Rounded metric cards
    ├── meal_card.dart         # Animated meal checkboxes (Afternoon / Evening)
    └── progress_card.dart     # Hero circular consumption progress
```

---

## 🚀 Build & Run Instructions

### Prerequisites
1. [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2. Android SDK with Platform 34/35/36 installed.
3. Java 17/21 JDK configured (`JAVA_HOME`).

### Getting Started
```bash
# Clone or navigate to the repository
cd D:\mess

# Fetch dependencies
flutter pub get

# Run unit test suite
flutter test

# Run code analysis
flutter analyze

# Run on a connected Android phone or emulator
flutter run
```

### Building the Release APK
To compile the standalone production APK:
```bash
flutter build apk --release
```
The output file is generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Verification & Test Suite

The project includes unit tests verifying all core requirements:
- Mark afternoon meal: consumed count increases by 1.
- Mark evening meal: consumed count increases by 1.
- Unmark meal: consumed count decreases by 1.
- Mark both meals: consumed count increases by 2.
- Month-to-month changes: recalculates dashboard stats.
- Meal completion: remaining count stops at 0 and never goes negative.
- Model serialization & deserialization.

Run tests using:
```bash
flutter test
```
