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

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 1;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 1;
    return 1;
  }

  static Color _parseColor(dynamic val) {
    if (val is int) return Color(val);
    if (val is String) {
      final intVal = int.tryParse(val);
      if (intVal != null) return Color(intVal);
    }
    return const Color(0xFF1E3A8A);
  }

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is DateTime) return val;
    if (val is String) {
      return DateTime.tryParse(val) ?? DateTime.now();
    }
    if (val is int) {
      return DateTime.fromMillisecondsSinceEpoch(val);
    }
    return DateTime.now();
  }

  factory CreditCard.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = (doc.data() as Map<String, dynamic>?) ?? {};
      return CreditCard(
        id: doc.id,
        name: (data['name'] ?? 'Tarjeta').toString(),
        limit: _parseDouble(data['limit']),
        currentBalance: _parseDouble(data['currentBalance']),
        cutOffDay: _parseInt(data['cutOffDay']),
        paymentDay: _parseInt(data['paymentDay']),
        network: (data['network'] ?? 'Visa').toString(),
        color: _parseColor(data['color']),
        createdAt: _parseDate(data['createdAt']),
      );
    } catch (e) {
      return CreditCard(
        id: doc.id,
        name: 'Tarjeta',
        limit: 0,
        currentBalance: 0,
        cutOffDay: 1,
        paymentDay: 1,
        network: 'Visa',
        color: const Color(0xFF1E3A8A),
        createdAt: DateTime.now(),
      );
    }
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
