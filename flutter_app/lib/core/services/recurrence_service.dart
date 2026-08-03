import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/transaction.dart';

class RecurrenceService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> processRecurrences(String userId) async {
    final now = DateTime.now();

    // 1. Process Debts
    try {
      final debtsQuery = await _firestore
          .collection('debts')
          .where('userId', isEqualTo: userId)
          .where('isAutoPay', isEqualTo: true)
          .get();

      for (var doc in debtsQuery.docs) {
        final debt = DebtModel.fromFirestore(doc);
        
        if (debt.paidInstallments >= debt.totalInstallments) continue;
        if (debt.recurrenceType == null) continue;
        
        bool shouldProcess = _checkRecurrence(
          debt.recurrenceType!,
          debt.recurrenceDay,
          debt.recurrenceDay2,
          debt.lastProcessedDate,
          now,
        );

        if (shouldProcess) {
          // Register payment (increment paid installments)
          final newPaid = debt.paidInstallments + 1;
          
          // Update debt
          await _firestore.collection('debts').doc(debt.id).update({
            'paidInstallments': newPaid,
            'lastProcessedDate': Timestamp.fromDate(now),
          });

          // Add transaction
          final newTxRef = _firestore.collection('transactions').doc();
          final tx = TransactionModel(
            id: newTxRef.id,
            userId: userId,
            amount: debt.installmentAmount,
            type: 'expense',
            category: debt.category,
            description: 'Cuota de ${debt.name}',
            date: now,
            isFixed: false,
          );
          
          await newTxRef.set(tx.toFirestore());
        }
      }
    } catch (e) {
      print('Error processing debts recurrences: $e');
    }

    // 2. Process Fixed Incomes
    try {
      final incomesQuery = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'income')
          .where('isFixed', isEqualTo: true)
          .get();

      for (var doc in incomesQuery.docs) {
        final income = TransactionModel.fromFirestore(doc);
        
        if (income.recurrenceType == null) continue;

        bool shouldProcess = _checkRecurrence(
          income.recurrenceType!,
          income.recurrenceDay,
          income.recurrenceDay2,
          income.lastProcessedDate,
          now,
        );

        if (shouldProcess) {
          // Update template transaction
          await _firestore.collection('transactions').doc(income.id).update({
            'lastProcessedDate': Timestamp.fromDate(now),
          });

          // Generate new income
          final newTxRef = _firestore.collection('transactions').doc();
          final newTx = TransactionModel(
            id: newTxRef.id,
            userId: userId,
            amount: income.amount,
            type: 'income',
            category: income.category,
            description: income.description,
            date: now,
            isFixed: false, // Set to false so it acts as a normal income entry for the month
          );

          await newTxRef.set(newTx.toFirestore());
        }
      }
    } catch (e) {
      print('Error processing fixed incomes recurrences: $e');
    }
  }

  static bool _checkRecurrence(
    String recurrenceType,
    int? day1,
    int? day2,
    DateTime? lastProcessed,
    DateTime now,
  ) {
    if (lastProcessed != null) {
      // Avoid processing multiple times in the same day
      if (lastProcessed.year == now.year &&
          lastProcessed.month == now.month &&
          lastProcessed.day == now.day) {
        return false;
      }
    }

    switch (recurrenceType) {
      case 'monthly':
        if (day1 == null) return false;
        // Check if we passed the day in the current month
        if (now.day >= day1) {
          // Process if not processed this month
          if (lastProcessed == null ||
              lastProcessed.year < now.year ||
              (lastProcessed.year == now.year && lastProcessed.month < now.month)) {
            return true;
          }
        }
        return false;

      case 'bimonthly':
        if (day1 == null || day2 == null) return false;
        // Check day1
        if (now.day >= day1 && now.day < day2) {
          if (lastProcessed == null || 
              lastProcessed.year < now.year || 
              (lastProcessed.year == now.year && lastProcessed.month < now.month) ||
              (lastProcessed.year == now.year && lastProcessed.month == now.month && lastProcessed.day < day1)) {
            return true;
          }
        }
        // Check day2
        if (now.day >= day2) {
          if (lastProcessed == null || 
              lastProcessed.year < now.year || 
              (lastProcessed.year == now.year && lastProcessed.month < now.month) ||
              (lastProcessed.year == now.year && lastProcessed.month == now.month && lastProcessed.day < day2)) {
            return true;
          }
        }
        return false;

      case 'weekly':
        if (day1 == null) return false; // 1 = Mon, 7 = Sun
        // If today is or after the target weekday
        if (now.weekday == day1) {
          if (lastProcessed == null || _daysBetween(lastProcessed, now) >= 6) {
             return true;
          }
        } else if (now.weekday > day1) {
           // We passed the weekday. Check if last processed was before this week's occurrence
           final daysPassed = now.weekday - day1;
           final lastOccurrenceDate = now.subtract(Duration(days: daysPassed));
           if (lastProcessed == null || lastProcessed.isBefore(DateTime(lastOccurrenceDate.year, lastOccurrenceDate.month, lastOccurrenceDate.day))) {
             return true;
           }
        }
        return false;

      default:
        return false;
    }
  }

  static int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}
