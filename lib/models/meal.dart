class Meal {
  final int? id;
  final String mealDate; // 'yyyy-MM-dd'
  final bool afternoon;
  final bool evening;
  final String? createdAt;
  final String? updatedAt;

  const Meal({
    this.id,
    required this.mealDate,
    this.afternoon = false,
    this.evening = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Consumed meals for this day: 0, 1, or 2
  int get dailyTotal => (afternoon ? 1 : 0) + (evening ? 1 : 0);

  bool get hasAnyMeal => afternoon || evening;
  bool get hasBothMeals => afternoon && evening;
  bool get hasOnlyOneMeal => hasAnyMeal && !hasBothMeals;

  Meal copyWith({
    int? id,
    String? mealDate,
    bool? afternoon,
    bool? evening,
    String? createdAt,
    String? updatedAt,
  }) {
    return Meal(
      id: id ?? this.id,
      mealDate: mealDate ?? this.mealDate,
      afternoon: afternoon ?? this.afternoon,
      evening: evening ?? this.evening,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'meal_date': mealDate,
      'afternoon': afternoon ? 1 : 0,
      'evening': evening ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as int?,
      mealDate: map['meal_date'] as String,
      afternoon: (map['afternoon'] as int? ?? 0) == 1,
      evening: (map['evening'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  @override
  String toString() {
    return 'Meal(id: $id, mealDate: $mealDate, afternoon: $afternoon, evening: $evening)';
  }
}
