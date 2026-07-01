import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String type; // 'expense', 'income', 'system'
  final String? relatedId; // ID of the transaction/debt if applicable
  final String? category; // Category for icon/emoji purposes

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    required this.type,
    this.relatedId,
    this.category,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'system',
      relatedId: data['relatedId'],
      category: data['category'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'type': type,
      if (relatedId != null) 'relatedId': relatedId,
      if (category != null) 'category': category,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? type,
    String? relatedId,
    String? category,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      category: category ?? this.category,
    );
  }
}
