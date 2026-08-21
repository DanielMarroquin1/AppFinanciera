import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/transaction.dart';
import 'local_notification_service.dart';
import '../../domain/entities/credit_card.dart';

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

        // NOTIFICACION MENSUAL DE DEUDA
        if (debt.recurrenceDay != null) {
          await LocalNotificationService.scheduleMonthlyReminder(
            id: debt.id.hashCode,
            dayOfMonth: debt.recurrenceDay!,
            title: 'Recordatorio de Deuda 🏦',
            body: 'Hoy es el día de pago para: ${debt.name} (${debt.installmentAmount})',
          );
        }
      }
    } catch (e) {
      print('Error processing debts recurrences: $e');
    }

    // 2. Process Fixed Transactions (Incomes and Expenses)
    try {
      final fixedTxQuery = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('isFixed', isEqualTo: true)
          .get();

      for (var doc in fixedTxQuery.docs) {
        final txTemplate = TransactionModel.fromFirestore(doc);
        
        // NOTIFICACION MENSUAL DE GASTO/INGRESO FIJO
        if (txTemplate.recurrenceDay != null) {
          await LocalNotificationService.scheduleMonthlyReminder(
            id: txTemplate.id.hashCode,
            dayOfMonth: txTemplate.recurrenceDay!,
            title: txTemplate.type == 'income' ? 'Ingreso Fijo 💰' : 'Gasto Fijo 📉',
            body: 'Hoy se procesa tu ${txTemplate.type == 'income' ? 'ingreso' : 'gasto'}: ${txTemplate.description} (${txTemplate.amount})',
          );
        }

        if (txTemplate.recurrenceType == null) continue;

        bool shouldProcess = _checkRecurrence(
          txTemplate.recurrenceType!,
          txTemplate.recurrenceDay,
          txTemplate.recurrenceDay2,
          txTemplate.lastProcessedDate,
          now,
        );

        if (shouldProcess) {
          // Update template transaction
          await _firestore.collection('transactions').doc(txTemplate.id).update({
            'lastProcessedDate': Timestamp.fromDate(now),
          });

          // Generate new transaction
          final newTxRef = _firestore.collection('transactions').doc();
          final newTx = TransactionModel(
            id: newTxRef.id,
            userId: userId,
            amount: txTemplate.amount,
            type: txTemplate.type,
            category: txTemplate.category,
            description: txTemplate.description,
            date: now,
            isFixed: false, // Set to false so it acts as a normal entry for the month
          );

          await newTxRef.set(newTx.toFirestore());
        }
      }
    } catch (e) {
      print('Error processing fixed transactions recurrences: $e');
    }

    // 3. Process Credit Cards Notifications
    try {
      final cardsQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('credit_cards')
          .get();
          
      for (var doc in cardsQuery.docs) {
        try {
          final card = CreditCard.fromFirestore(doc);
          // Notificación de corte
          await LocalNotificationService.scheduleMonthlyReminder(
            id: '${card.id}_corte'.hashCode,
            dayOfMonth: card.cutOffDay,
            title: 'Corte de Tarjeta 💳',
            body: 'Hoy es la fecha de corte de tu ${card.name}.',
          );
          // Notificación de pago
          await LocalNotificationService.scheduleMonthlyReminder(
            id: '${card.id}_pago'.hashCode,
            dayOfMonth: card.paymentDay,
            title: 'Pago de Tarjeta 💳',
            body: 'Hoy es la fecha límite de pago para tu ${card.name}. ¡Evita intereses!',
          );
        } catch (_) {}
      }
    } catch (e) {
      print('Error processing credit card notifications: $e');
    }
  }

    static bool _checkRecurrence(
    String recurrenceType,
    int? day1,
    int? day2,
    DateTime? lastProcessed,
    DateTime now,
  ) {
    if (day1 == null) return false;
    
    // If never processed, check if today is the day
    if (lastProcessed == null) {
      if (recurrenceType == 'monthly' && now.day == day1) return true;
      if (recurrenceType == 'weekly' && now.weekday == day1) return true;
      if (recurrenceType == 'bimonthly' && (now.day == day1 || now.day == day2)) return true;
      return false;
    }

    // Iterate from lastProcessed + 1 day up to now
    DateTime current = DateTime(lastProcessed.year, lastProcessed.month, lastProcessed.day).add(const Duration(days: 1));
    DateTime today = DateTime(now.year, now.month, now.day);
    
    while (!current.isAfter(today)) {
      if (recurrenceType == 'monthly' && current.day == day1) return true;
      if (recurrenceType == 'weekly' && current.weekday == day1) return true;
      if (recurrenceType == 'bimonthly' && (current.day == day1 || current.day == day2)) return true;
      current = current.add(const Duration(days: 1));
    }

    return false;
  }


}
