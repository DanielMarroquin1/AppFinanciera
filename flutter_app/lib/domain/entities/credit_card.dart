import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreditCard {
  final String id;
  final String name;
  final double limit;
  final double currentBalance;
  final int cutOffDay;
  final int paymentDay;
  final String network; // e.g. Visa, Mastercard, Amex
  final Color color;
  final DateTime createdAt;

  CreditCard({
    required this.id,
    required this.name,
    required this.limit,
    required this.currentBalance,
    required this.cutOffDay,
    required this.paymentDay,
    required this.network,
    required this.color,
    required this.createdAt,
  });

  factory CreditCard.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CreditCard(
      id: doc.id,
      name: data['name'] ?? '',
      limit: (data['limit'] ?? 0.0).toDouble(),
      currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
      cutOffDay: data['cutOffDay'] ?? 1,
      paymentDay: data['paymentDay'] ?? 1,
      network: data['network'] ?? 'Visa',
      color: Color(data['color'] ?? 0xFF1E3A8A),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'limit': limit,
      'currentBalance': currentBalance,
      'cutOffDay': cutOffDay,
      'paymentDay': paymentDay,
      'network': network,
      'color': color.value,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  CreditCard copyWith({
    String? name,
    double? limit,
    double? currentBalance,
    int? cutOffDay,
    int? paymentDay,
    String? network,
    Color? color,
  }) {
    return CreditCard(
      id: id,
      name: name ?? this.name,
      limit: limit ?? this.limit,
      currentBalance: currentBalance ?? this.currentBalance,
      cutOffDay: cutOffDay ?? this.cutOffDay,
      paymentDay: paymentDay ?? this.paymentDay,
      network: network ?? this.network,
      color: color ?? this.color,
      createdAt: createdAt,
    );
  }
}
