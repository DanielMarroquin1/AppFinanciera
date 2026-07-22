import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import 'auth_provider.dart';
import 'notification_provider.dart';
import '../../core/utils/localization.dart';
import '../../core/services/local_notification_service.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

// Stream de transacciones del usuario actual
final transactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final authState = ref.watch(authProvider);
  final repository = ref.watch(transactionRepositoryProvider);
  
  if (authState.user != null) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      return repository.watchTransactions(uid);
    }
  }
  return Stream.value([]);
});

enum BudgetAlertStatus { ok, nearLimit, limitReached }

class BudgetAlertResult {
  final BudgetAlertStatus status;
  final String categoryId;
  final String categoryName;
  final double totalSpent;
  final double budgetLimit;
  final double percentage;

  BudgetAlertResult({
    required this.status,
    required this.categoryId,
    required this.categoryName,
    required this.totalSpent,
    required this.budgetLimit,
    required this.percentage,
  });
}

class TransactionNotifier extends Notifier<void> {
  late TransactionRepository _repository;

  @override
  void build() {
    _repository = ref.read(transactionRepositoryProvider);
  }

  Future<BudgetAlertResult?> addTransaction(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
    if (!transaction.isFixed) {
      await ref.read(authProvider.notifier).incrementStreakOnAction();
    }
    // Perform category budget alerts check
    return await _checkCategoryBudgetAlert(transaction);
  }

  Future<BudgetAlertResult?> _checkCategoryBudgetAlert(TransactionModel transaction) async {
    if (transaction.type != 'expense') return null;

    final user = ref.read(authProvider).user;
    if (user == null || user.categoryBudgets == null) return null;

    // Map subcategories to main category (e.g. transport_gas -> transport)
    final mainCategory = transaction.category.split('_')[0];
    final budget = (user.categoryBudgets![mainCategory] as num?)?.toDouble() ?? 0.0;
    if (budget <= 0) return null;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    
    // Calculate current month's expenses locally from the current state list
    final existingTxs = ref.read(transactionsProvider).value ?? [];
    final now = DateTime.now();

    double spentBefore = 0.0;
    for (var tx in existingTxs) {
      if (tx.type == 'expense' &&
          tx.category.split('_')[0] == mainCategory &&
          tx.date.year == now.year &&
          tx.date.month == now.month &&
          tx.id != transaction.id) {
        spentBefore += tx.amount;
      }
    }

    final totalSpent = spentBefore + transaction.amount;
    final percentage = (totalSpent / budget) * 100;

    String getCategoryName(String catId) {
      switch (catId) {
        case 'food': return 'Comida';
        case 'transport': return 'Transporte';
        case 'bills': return 'Servicios';
        case 'home': return 'Hogar';
        case 'entertainment': return 'Entretenimiento';
        case 'health': return 'Salud';
        case 'shopping': return 'Compras';
        case 'education': return 'Educación';
        default: return 'Otros';
      }
    }
    final categoryName = getCategoryName(mainCategory);

    final loc = ref.read(localizationProvider);
    final translatedCategory = loc.translateCategory(categoryName);

    if (percentage >= 100) {
      final notifRef = FirebaseFirestore.instance.collection('notifications').doc();
      final notif = NotificationModel(
        id: notifRef.id,
        userId: uid,
        title: loc.get('notif_budget_exceeded_title'),
        body: loc.get('notif_budget_exceeded_body').replaceAll('{cat}', translatedCategory).replaceAll('{nums}', '$totalSpent / $budget'),
        createdAt: DateTime.now(),
        isRead: false,
        type: 'expense',
        relatedId: transaction.id,
        category: mainCategory,
      );
      await FirebaseFirestore.instance.collection('notifications').doc(notifRef.id).set(notif.toFirestore());
      LocalNotificationService.showNotification(
        title: notif.title,
        body: notif.body,
        id: notif.id.hashCode.abs() % 100000,
      );
      
      if (user.email.isNotEmpty) {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': user.email,
          'message': {
            'subject': loc.get('notif_budget_exceeded_title'),
            'text': loc.get('notif_budget_exceeded_body').replaceAll('{cat}', translatedCategory).replaceAll('{nums}', '$totalSpent / $budget'),
            'html': '<p>${loc.get('notif_budget_exceeded_body').replaceAll('{cat}', '<strong>"$translatedCategory"</strong>').replaceAll('{nums}', '$totalSpent / $budget')}</p>',
          },
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return BudgetAlertResult(
        status: BudgetAlertStatus.limitReached,
        categoryId: mainCategory,
        categoryName: categoryName,
        totalSpent: totalSpent,
        budgetLimit: budget,
        percentage: percentage,
      );
    } else if (percentage >= 80) {
      final notifRef = FirebaseFirestore.instance.collection('notifications').doc();
      final notif = NotificationModel(
        id: notifRef.id,
        userId: uid,
        title: loc.get('notif_budget_warning_title'),
        body: loc.get('notif_budget_warning_body').replaceAll('{cat}', translatedCategory).replaceAll('{nums}', '$totalSpent / $budget'),
        createdAt: DateTime.now(),
        isRead: false,
        type: 'expense',
        relatedId: transaction.id,
        category: mainCategory,
      );
      await FirebaseFirestore.instance.collection('notifications').doc(notifRef.id).set(notif.toFirestore());
      LocalNotificationService.showNotification(
        title: notif.title,
        body: notif.body,
        id: notif.id.hashCode.abs() % 100000,
      );
      
      if (user.email.isNotEmpty) {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': user.email,
          'message': {
            'subject': loc.get('notif_budget_warning_title'),
            'text': loc.get('notif_budget_warning_body').replaceAll('{cat}', translatedCategory).replaceAll('{nums}', '$totalSpent / $budget'),
            'html': '<p>${loc.get('notif_budget_warning_body').replaceAll('{cat}', '<strong>"$translatedCategory"</strong>').replaceAll('{nums}', '$totalSpent / $budget')}</p>',
          },
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return BudgetAlertResult(
        status: BudgetAlertStatus.nearLimit,
        categoryId: mainCategory,
        categoryName: categoryName,
        totalSpent: totalSpent,
        budgetLimit: budget,
        percentage: percentage,
      );
    }

    return BudgetAlertResult(
      status: BudgetAlertStatus.ok,
      categoryId: mainCategory,
      categoryName: categoryName,
      totalSpent: totalSpent,
      budgetLimit: budget,
      percentage: percentage,
    );
  }

  Future<BudgetAlertResult?> updateTransaction(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
    return await _checkCategoryBudgetAlert(transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _repository.deleteTransaction(transactionId);
  }
}

final transactionNotifierProvider = NotifierProvider<TransactionNotifier, void>(() {
  return TransactionNotifier();
});
