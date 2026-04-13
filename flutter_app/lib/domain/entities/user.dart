class User {
  final String email;
  final String name;
  final String purpose;
  final bool hasCompletedTour;
  final bool profileComplete;
  final String? country;
  final String? currency;
  final String? salary;
  final String? salaryType;

  User({
    required this.email,
    required this.name,
    required this.purpose,
    required this.hasCompletedTour,
    required this.profileComplete,
    this.country,
    this.currency,
    this.salary,
    this.salaryType,
  });

  User copyWith({
    String? email,
    String? name,
    String? purpose,
    bool? hasCompletedTour,
    bool? profileComplete,
    String? country,
    String? currency,
    String? salary,
    String? salaryType,
  }) {
    return User(
      email: email ?? this.email,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      hasCompletedTour: hasCompletedTour ?? this.hasCompletedTour,
      profileComplete: profileComplete ?? this.profileComplete,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      salary: salary ?? this.salary,
      salaryType: salaryType ?? this.salaryType,
    );
  }
}
