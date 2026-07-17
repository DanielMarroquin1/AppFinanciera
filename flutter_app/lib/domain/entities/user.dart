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
  final String? currentAvatar;
  final double? monthlyLimit;
  final bool isTwoFactorEnabled;
  final String? twoFactorMethod;
  final String? twoFactorPhone;
  final Map<String, double>? categoryBudgets;
  final int autoLockMinutes;


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
    this.currentAvatar,
    this.monthlyLimit,
    this.isTwoFactorEnabled = false,
    this.twoFactorMethod,
    this.twoFactorPhone,
    this.categoryBudgets,
    this.autoLockMinutes = 1,
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
    String? currentAvatar,
    double? monthlyLimit,
    bool? isTwoFactorEnabled,
    String? twoFactorMethod,
    String? twoFactorPhone,
    Map<String, double>? categoryBudgets,
    int? autoLockMinutes,
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
      currentAvatar: currentAvatar ?? this.currentAvatar,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      twoFactorMethod: twoFactorMethod ?? this.twoFactorMethod,
      twoFactorPhone: twoFactorPhone ?? this.twoFactorPhone,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
    );
  }

  bool get isPremium => unlockedItems.contains('premium') || unlockedItems.contains('spec1') || unlockedItems.contains('vip');

  String get avatarEmoji {
    if (currentAvatar == null) return '👤';
    switch (currentAvatar) {
      case 'avatar1': return '🦸';
      case 'avatar2': return '🧙';
      case 'avatar3': return '👑';
      case 'avatar4': return '🥷';
      case 'avatar5': return '🧑‍🚀';
      case 'avatar6': return '💎';
      case 'avatar7': return '🐳';
      case 'avatar8': return '⚔️';
      case 'avatar9': return '🐉';
      case 'avatar10': return '🔥';
      default:
        if (currentAvatar!.runes.isNotEmpty && currentAvatar!.runes.first > 127) {
          return currentAvatar!;
        }
        return '👤';
    }
  }
}
