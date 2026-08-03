import 'package:cloud_firestore/cloud_firestore.dart';

class DebtModel {
  final String id;
  final String userId;
  final String name;
  final double installmentAmount;
  final int totalInstallments;
  final int paidInstallments;
  final String category;
  final bool isAutoPay;
  final String? recurrenceType;
  final int? recurrenceDay;
  final int? recurrenceDay2;
  final DateTime createdAt;
  final DateTime? lastProcessedDate;

  DebtModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.installmentAmount,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.category,
    this.isAutoPay = false,
    this.recurrenceType,
    this.recurrenceDay,
    this.recurrenceDay2,
    required this.createdAt,
    this.lastProcessedDate,
  });

  factory DebtModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DebtModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      installmentAmount: (data['installmentAmount'] ?? 0).toDouble(),
      totalInstallments: data['totalInstallments'] ?? 0,
      paidInstallments: data['paidInstallments'] ?? 0,
      category: data['category'] ?? '🏦',
      isAutoPay: data['isAutoPay'] ?? false,
      recurrenceType: data['recurrenceType'],
      recurrenceDay: data['recurrenceDay'],
      recurrenceDay2: data['recurrenceDay2'],
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      lastProcessedDate: data['lastProcessedDate'] != null ? (data['lastProcessedDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'installmentAmount': installmentAmount,
      'totalInstallments': totalInstallments,
      'paidInstallments': paidInstallments,
      'category': category,
      'isAutoPay': isAutoPay,
      if (recurrenceType != null) 'recurrenceType': recurrenceType,
      if (recurrenceDay != null) 'recurrenceDay': recurrenceDay,
      if (recurrenceDay2 != null) 'recurrenceDay2': recurrenceDay2,
      'createdAt': Timestamp.fromDate(createdAt),
      if (lastProcessedDate != null) 'lastProcessedDate': Timestamp.fromDate(lastProcessedDate!),
    };
  }

  DebtModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? installmentAmount,
    int? totalInstallments,
    int? paidInstallments,
    String? category,
    bool? isAutoPay,
    String? recurrenceType,
    int? recurrenceDay,
    int? recurrenceDay2,
    DateTime? createdAt,
    DateTime? lastProcessedDate,
  }) {
    return DebtModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      category: category ?? this.category,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceDay: recurrenceDay ?? this.recurrenceDay,
      recurrenceDay2: recurrenceDay2 ?? this.recurrenceDay2,
      createdAt: createdAt ?? this.createdAt,
      lastProcessedDate: lastProcessedDate ?? this.lastProcessedDate,
    );
  }
}
