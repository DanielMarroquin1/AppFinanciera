class User {
  final String email;
  final String name;
  final String purpose;
  final bool hasCompletedTour;
  final bool profileComplete;
  final String? country;
  final String? currency;
  final String? language;
  final String? salary;
  final String? salaryType;
  
  // Rewards & Streak Fields
  final int points;
  final int currentStreak;
  final String? lastActiveDate;
  final List<String> unlockedItems;

  User({
    required this.email,
    required this.name,
    required this.purpose,
    required this.hasCompletedTour,
    required this.profileComplete,
    this.country,
    this.currency,
    this.language,
    this.salary,
    this.salaryType,
    this.points = 0,
    this.currentStreak = 0,
    this.lastActiveDate,
    this.unlockedItems = const [],
  });

  User copyWith({
    String? email,
    String? name,
    String? purpose,
    bool? hasCompletedTour,
    bool? profileComplete,
    String? country,
    String? currency,
    String? language,
    String? salary,
    String? salaryType,
    int? points,
    int? currentStreak,
    String? lastActiveDate,
    List<String>? unlockedItems,
  }) {
    return User(
      email: email ?? this.email,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      hasCompletedTour: hasCompletedTour ?? this.hasCompletedTour,
      profileComplete: profileComplete ?? this.profileComplete,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      salary: salary ?? this.salary,
      salaryType: salaryType ?? this.salaryType,
      points: points ?? this.points,
      currentStreak: currentStreak ?? this.currentStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      unlockedItems: unlockedItems ?? this.unlockedItems,
    );
  }
}
