import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/notification.dart';
import 'auth_provider.dart';

final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authProvider).user;
  final firebaseUser = FirebaseAuth.instance.currentUser;
  
  if (user == null || firebaseUser == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: firebaseUser.uid)
      .limit(50) // Limit to the most recent 50 notifications
      .snapshots()
      .map((snapshot) {
    final list = snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  });
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsyncValue = ref.watch(notificationsProvider);
  
  return notificationsAsyncValue.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final notificationNotifierProvider = Provider<NotificationNotifier>((ref) {
  return NotificationNotifier();
});

class NotificationNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
