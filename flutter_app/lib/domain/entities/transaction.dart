import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String description;
  final DateTime date;
  final bool isFixed;
  final String? recurrenceType; // 'monthly', 'bimonthly' (2 times/month), 'weekly', null
  final int? recurrenceDay; // primary day of month (1-31) or day of week (1-7 for weekly)
  final int? recurrenceDay2; // secondary day for bimonthly (e.g. pay on 15 and 30)

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
    required this.isFixed,
    this.recurrenceType,
    this.recurrenceDay,
    this.recurrenceDay2,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? 'expense',
      category: data['category'] ?? 'other',
      description: data['description'] ?? '',
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : DateTime.now(),
      isFixed: data['isFixed'] ?? false,
      recurrenceType: data['recurrenceType'],
      recurrenceDay: data['recurrenceDay'],
      recurrenceDay2: data['recurrenceDay2'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'type': type,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isFixed': isFixed,
      if (recurrenceType != null) 'recurrenceType': recurrenceType,
      if (recurrenceDay != null) 'recurrenceDay': recurrenceDay,
      if (recurrenceDay2 != null) 'recurrenceDay2': recurrenceDay2,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? type,
    String? category,
    String? description,
    DateTime? date,
    bool? isFixed,
    String? recurrenceType,
    int? recurrenceDay,
    int? recurrenceDay2,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      isFixed: isFixed ?? this.isFixed,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceDay: recurrenceDay ?? this.recurrenceDay,
      recurrenceDay2: recurrenceDay2 ?? this.recurrenceDay2,
    );
  }

  /// Human-readable recurrence label
  String get recurrenceLabel {
    if (recurrenceType == null) return 'Sin recurrencia';
    switch (recurrenceType) {
      case 'monthly':
        return 'Mensual - Día $recurrenceDay';
      case 'bimonthly':
        return 'Quincenal - Días $recurrenceDay y ${recurrenceDay2 ?? '?'}';
      case 'weekly':
        const days = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        final dayName = (recurrenceDay != null && recurrenceDay! >= 1 && recurrenceDay! <= 7) ? days[recurrenceDay!] : '?';
        return 'Semanal - $dayName';
      default:
        return recurrenceType ?? '';
    }
  }

  /// Per-payment amount (for bimonthly, amount is split in half per payment)
  double get perPaymentAmount {
    if (recurrenceType == 'bimonthly') return amount / 2;
    return amount;
  }
}
