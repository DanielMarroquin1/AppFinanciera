import 'package:cloud_firestore/cloud_firestore.dart';

class DebtModel {
  final String id;
  final String userId;
  final String name;
  final double installmentAmount;
  final int totalInstallments;
  final int paidInstallments;
  final String category;
  final DateTime createdAt;

  DebtModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.installmentAmount,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.category,
    required this.createdAt,
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
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
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
      'createdAt': Timestamp.fromDate(createdAt),
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
    DateTime? createdAt,
  }) {
    return DebtModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
