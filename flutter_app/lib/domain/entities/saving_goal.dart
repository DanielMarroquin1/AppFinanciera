class SavingGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String icon;
  final String userId;
  final List<int>? colorInts; // Storing colors as integers for Firebase

  SavingGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.icon,
    required this.userId,
    this.colorInts,
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
      colorInts: map['colorInts'] != null ? List<int>.from(map['colorInts']) : null,
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
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      icon: icon ?? this.icon,
      userId: userId ?? this.userId,
      colorInts: colorInts ?? this.colorInts,
    );
  }
}
