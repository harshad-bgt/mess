class AppSettings {
  final int id;
  final int totalMeals;
  final double amountPaid;
  final String afternoonReminder; // '14:00'
  final String eveningReminder;   // '20:00'
  final bool notificationsEnabled;

  const AppSettings({
    this.id = 1,
    this.totalMeals = 30,
    this.amountPaid = 2000.0,
    this.afternoonReminder = '14:00',
    this.eveningReminder = '20:00',
    this.notificationsEnabled = true,
  });

  /// Cost per individual meal: e.g. ₹2000 / 30 = ₹66.67
  double get costPerMeal => totalMeals > 0 ? (amountPaid / totalMeals) : 0.0;

  AppSettings copyWith({
    int? id,
    int? totalMeals,
    double? amountPaid,
    String? afternoonReminder,
    String? eveningReminder,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      id: id ?? this.id,
      totalMeals: totalMeals ?? this.totalMeals,
      amountPaid: amountPaid ?? this.amountPaid,
      afternoonReminder: afternoonReminder ?? this.afternoonReminder,
      eveningReminder: eveningReminder ?? this.eveningReminder,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_meals': totalMeals,
      'amount_paid': amountPaid,
      'afternoon_reminder': afternoonReminder,
      'evening_reminder': eveningReminder,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as int? ?? 1,
      totalMeals: map['total_meals'] as int? ?? 30,
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? 2000.0,
      afternoonReminder: map['afternoon_reminder'] as String? ?? '14:00',
      eveningReminder: map['evening_reminder'] as String? ?? '20:00',
      notificationsEnabled: (map['notifications_enabled'] as int? ?? 1) == 1,
    );
  }

  @override
  String toString() {
    return 'AppSettings(totalMeals: $totalMeals, amountPaid: $amountPaid, afternoon: $afternoonReminder, evening: $eveningReminder, notifications: $notificationsEnabled)';
  }
}
