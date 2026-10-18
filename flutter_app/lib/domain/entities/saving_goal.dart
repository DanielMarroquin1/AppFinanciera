class SavingGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String icon;
  final String userId;
  final List<int>? colorInts; // Storing colors as integers for Firebase
  final bool isAutoDeduct;
  final double? autoDeductAmount;
  final String? autoDeductFrequency; // 'weekly', 'biweekly', 'monthly'
  final int? autoDeductDay; // 1-31 for month, 1-7 for week
  final DateTime? lastAutoDeductDate;

  SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.icon,
    required this.userId,
    this.colorInts,
    this.isAutoDeduct = false,
    this.autoDeductAmount,
    this.autoDeductFrequency,
    this.autoDeductDay,
    this.lastAutoDeductDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'icon': icon,
      'userId': userId,
      'colorInts': colorInts,
      'isAutoDeduct': isAutoDeduct,
      'autoDeductAmount': autoDeductAmount,
      'autoDeductFrequency': autoDeductFrequency,
      'autoDeductDay': autoDeductDay,
      'lastAutoDeductDate': lastAutoDeductDate?.toIso8601String(),
    };
  }

  factory SavingGoal.fromMap(Map<String, dynamic> map, String id) {
    return SavingGoal(
      id: id,
      name: map['name'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0.0).toDouble(),
      icon: map['icon'] ?? '🎯',
      userId: map['userId'] ?? '',
      colorInts: map['colorInts'] != null
          ? List<int>.from(map['colorInts'])
          : null,
      isAutoDeduct: map['isAutoDeduct'] ?? false,
      autoDeductAmount: map['autoDeductAmount'] != null
          ? (map['autoDeductAmount'] as num).toDouble()
          : null,
      autoDeductFrequency: map['autoDeductFrequency'],
      autoDeductDay: map['autoDeductDay'],
      lastAutoDeductDate: map['lastAutoDeductDate'] != null
          ? DateTime.tryParse(map['lastAutoDeductDate'])
          : null,
    );
  }

  SavingGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    String? icon,
    String? userId,
    List<int>? colorInts,
    bool? isAutoDeduct,
    double? autoDeductAmount,
    String? autoDeductFrequency,
    int? autoDeductDay,
    DateTime? lastAutoDeductDate,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      icon: icon ?? this.icon,
      userId: userId ?? this.userId,
      colorInts: colorInts ?? this.colorInts,
      isAutoDeduct: isAutoDeduct ?? this.isAutoDeduct,
      autoDeductAmount: autoDeductAmount ?? this.autoDeductAmount,
      autoDeductFrequency: autoDeductFrequency ?? this.autoDeductFrequency,
      autoDeductDay: autoDeductDay ?? this.autoDeductDay,
      lastAutoDeductDate: lastAutoDeductDate ?? this.lastAutoDeductDate,
    );
  }
}
