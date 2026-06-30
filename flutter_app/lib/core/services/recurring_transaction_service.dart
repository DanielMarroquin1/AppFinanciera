import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/debt.dart';

class RecurringTransactionService {
  static Future<void> evaluateRecurringTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    await cleanDuplicates(user.uid);

    final prefs = await SharedPreferences.getInstance();
    final String lastCheckStr = prefs.getString('last_recurring_check_${user.uid}') ?? '';
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    
    DateTime lastCheck;
    if (lastCheckStr.isEmpty) {
      // First time running this engine, look back 60 days to catch missed ones
      // but we will restrict it to not generate before the template was created.
      lastCheck = today.subtract(const Duration(days: 60));
    } else {
      lastCheck = DateTime.parse(lastCheckStr);
    }

    if (!lastCheck.isBefore(today)) {
      // Already checked today
      return;
    }

    // Get all fixed transactions (templates)
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('isFixed', isEqualTo: true)
        .get();

    final templates = snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    final batch = FirebaseFirestore.instance.batch();
    int addedCount = 0;

    for (var template in templates) {
      if (template.recurrenceType == null || template.recurrenceDay == null) continue;

      // We need to check if any required dates fell between lastCheck (exclusive) and today (inclusive)
      // Since it could be months, we iterate day by day.
      // Do not generate transactions before the template was created.
      DateTime templateDate = DateTime(template.date.year, template.date.month, template.date.day);
      DateTime start = lastCheck.isBefore(templateDate) ? templateDate : lastCheck;
      
      // We start checking from start + 1 day
      DateTime current = start.add(const Duration(days: 1));
      
      while (!current.isAfter(today)) {
        bool shouldAdd = false;

        if (template.recurrenceType == 'monthly') {
          if (current.day == template.recurrenceDay) {
            shouldAdd = true;
          }
        } else if (template.recurrenceType == 'bimonthly') {
          if (current.day == template.recurrenceDay || current.day == template.recurrenceDay2) {
            shouldAdd = true;
          }
        } else if (template.recurrenceType == 'weekly') {
          // Simplification: if recurrenceDay represents weekday (1 = Monday, 7 = Sunday)
          // For now, let's assume recurrenceDay is not used for weekly, or it represents weekday.
          // In AddExpenseModal, recurrenceDay is 1-31. Let's assume weekly is not supported yet or skips.
        }

        if (shouldAdd) {
          // Create a new normal transaction (not fixed, so it doesn't duplicate the template)
          final newTx = TransactionModel(
            id: '',
            userId: user.uid,
            amount: template.perPaymentAmount,
            type: template.type,
            category: template.category,
            description: '${template.description} (Automático)',
            date: current,
            isFixed: false, // It's an instantiated transaction, not a template
          );

          final docRef = FirebaseFirestore.instance.collection('transactions').doc();
          batch.set(docRef, newTx.toFirestore());
          addedCount++;
        }

        current = current.add(const Duration(days: 1));
      }
    }

    // Now evaluate Debts with isAutoPay == true
    final debtSnapshot = await FirebaseFirestore.instance
        .collection('debts')
        .where('userId', isEqualTo: user.uid)
        .where('isAutoPay', isEqualTo: true)
        .get();

    final debtTemplates = debtSnapshot.docs.map((doc) => DebtModel.fromFirestore(doc)).toList();

    for (var debt in debtTemplates) {
      if (debt.recurrenceType == null || debt.recurrenceDay == null) continue;
      if (debt.paidInstallments >= debt.totalInstallments) continue; // Already paid

      DateTime templateDate = DateTime(debt.createdAt.year, debt.createdAt.month, debt.createdAt.day);
      DateTime start = lastCheck.isBefore(templateDate) ? templateDate : lastCheck;
      DateTime current = start.add(const Duration(days: 1));
      
      int addedInstallments = 0;

      while (!current.isAfter(today) && (debt.paidInstallments + addedInstallments) < debt.totalInstallments) {
        bool shouldAdd = false;

        if (debt.recurrenceType == 'monthly') {
          if (current.day == debt.recurrenceDay) shouldAdd = true;
        } else if (debt.recurrenceType == 'bimonthly') {
          if (current.day == debt.recurrenceDay || current.day == debt.recurrenceDay2) shouldAdd = true;
        } else if (debt.recurrenceType == 'weekly') {
          // simplified weekday
        }

        if (shouldAdd) {
          // Create the expense transaction
          final newTx = TransactionModel(
            id: '',
            userId: user.uid,
            amount: debt.installmentAmount,
            type: 'expense',
            category: debt.category,
            description: 'Cuota de ${debt.name} (Automático)',
            date: current,
            isFixed: false,
          );

          final docRef = FirebaseFirestore.instance.collection('transactions').doc();
          batch.set(docRef, newTx.toFirestore());
          
          addedInstallments++;
          addedCount++;
        }

        current = current.add(const Duration(days: 1));
      }

      // Update debt's paidInstallments if we added any
      if (addedInstallments > 0) {
        final newDebt = debt.copyWith(paidInstallments: debt.paidInstallments + addedInstallments);
        final debtRef = FirebaseFirestore.instance.collection('debts').doc(debt.id);
        batch.update(debtRef, {'paidInstallments': newDebt.paidInstallments});
      }
    }

    if (addedCount > 0) {
      await batch.commit();
    }

    await prefs.setString('last_recurring_check_${user.uid}', today.toIso8601String());
  }

  static Future<void> cleanDuplicates(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .where('isFixed', isEqualTo: false)
        .get();

    final allNormal = snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    final Map<String, List<TransactionModel>> groups = {};

    for (var t in allNormal) {
      final key = '${t.type}_${t.category}_${t.description}_${t.amount}_${t.date.year}_${t.date.month}_${t.date.day}';
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(t);
    }

    final batch = FirebaseFirestore.instance.batch();
    int deletedCount = 0;

    for (var group in groups.values) {
      if (group.length > 1) {
        // keep the first one, delete the rest
        for (int i = 1; i < group.length; i++) {
          final docRef = FirebaseFirestore.instance.collection('transactions').doc(group[i].id);
          batch.delete(docRef);
          deletedCount++;
        }
      }
    }

    if (deletedCount > 0) {
      await batch.commit();
    }
  }
}
