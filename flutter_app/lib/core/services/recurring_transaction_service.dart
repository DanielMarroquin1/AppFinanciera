import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/credit_card.dart';
import '../utils/currency_formatter.dart';
import 'local_notification_service.dart';

class RecurringTransactionService {
  static Future<void> evaluateRecurringTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    await cleanDuplicates(user.uid);

    final existingSnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .get();
    final existingNormal = existingSnapshot.docs
        .map((d) => TransactionModel.fromFirestore(d))
        .where((t) => !t.isFixed)
        .toList();

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
          final targetDesc = '${template.description} (Automático)';
          final alreadyExists = existingNormal.any((t) => 
            t.description == targetDesc &&
            t.date.year == current.year &&
            t.date.month == current.month &&
            t.date.day == current.day
          );
          if (alreadyExists) {
            shouldAdd = false;
          }
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
          
          // Generate notification
          final notifRef = FirebaseFirestore.instance.collection('notifications').doc();
          final notif = NotificationModel(
            id: notifRef.id,
            userId: user.uid,
            title: template.type == 'income' ? 'Ingreso Automático' : 'Cobro Automático',
            body: 'Se ha registrado "${template.description}" por un monto de ${template.perPaymentAmount.toStringAsFixed(2)}.',
            createdAt: DateTime.now(),
            isRead: false,
            type: template.type,
            relatedId: docRef.id,
            category: template.category,
          );
          batch.set(notifRef, notif.toFirestore());
          LocalNotificationService.showNotification(
            title: notif.title,
            body: notif.body,
            id: notif.id.hashCode.abs() % 100000,
          );

          if (user.email != null) {
            final mailRef = FirebaseFirestore.instance.collection('mail').doc();
            batch.set(mailRef, {
              'to': user.email,
              'message': {
                'subject': template.type == 'income' ? 'Ingreso Automático Registrado' : 'Cobro Automático Registrado',
                'text': 'Se ha registrado "${template.description}" por un monto de ${template.perPaymentAmount.toStringAsFixed(2)}.',
                'html': '<p>Se ha registrado <strong>"${template.description}"</strong> por un monto de ${template.perPaymentAmount.toStringAsFixed(2)}.</p>',
              },
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

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
          final targetDesc = 'Cuota de ${debt.name} (Automático)';
          final alreadyExists = existingNormal.any((t) => 
            t.description == targetDesc &&
            t.date.year == current.year &&
            t.date.month == current.month &&
            t.date.day == current.day
          );
          if (alreadyExists) {
            shouldAdd = false;
          }
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
          
          // Generate notification
          final notifRef = FirebaseFirestore.instance.collection('notifications').doc();
          final notif = NotificationModel(
            id: notifRef.id,
            userId: user.uid,
            title: 'Pago Automático de Deuda',
            body: 'Se ha cobrado la cuota de "${debt.name}" por un monto de ${debt.installmentAmount.toStringAsFixed(2)}.',
            createdAt: DateTime.now(),
            isRead: false,
            type: 'expense',
            relatedId: docRef.id,
            category: debt.category,
          );
          batch.set(notifRef, notif.toFirestore());
          LocalNotificationService.showNotification(
            title: notif.title,
            body: notif.body,
            id: notif.id.hashCode.abs() % 100000,
          );

          if (user.email != null) {
            final mailRef = FirebaseFirestore.instance.collection('mail').doc();
            batch.set(mailRef, {
              'to': user.email,
              'message': {
                'subject': 'Pago Automático de Deuda',
                'text': 'Se ha cobrado la cuota de "${debt.name}" por un monto de ${debt.installmentAmount.toStringAsFixed(2)}.',
                'html': '<p>Se ha cobrado la cuota de <strong>"${debt.name}"</strong> por un monto de ${debt.installmentAmount.toStringAsFixed(2)}.</p>',
              },
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

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
    await evaluateCreditCardAlerts();
    await cleanDuplicates(user.uid);
  }

  static Future<void> cleanDuplicates(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .get();

    final allNormal = snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .where((t) => !t.isFixed)
        .toList();
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

    // Clean duplicate notifications
    final notifSnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .get();
    final allNotifs = notifSnapshot.docs.map((d) => NotificationModel.fromFirestore(d)).toList();
    final Map<String, List<NotificationModel>> notifGroups = {};
    for (var n in allNotifs) {
      final key = '${n.title}_${n.body}_${n.createdAt.year}_${n.createdAt.month}_${n.createdAt.day}';
      if (!notifGroups.containsKey(key)) notifGroups[key] = [];
      notifGroups[key]!.add(n);
    }
    for (var g in notifGroups.values) {
      if (g.length > 1) {
        for (int i = 1; i < g.length; i++) {
          batch.delete(FirebaseFirestore.instance.collection('notifications').doc(g[i].id));
          deletedCount++;
        }
      }
    }

    if (deletedCount > 0) {
      await batch.commit();
    }
  }

  static Future<void> evaluateCreditCardAlerts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final currencyCode = (userDoc.data()?['currency'] as String?) ?? 'USD';

      final cardsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('credit_cards')
          .get();
      if (cardsSnap.docs.isEmpty) return;

      final cards = cardsSnap.docs.map((d) => CreditCard.fromFirestore(d)).toList();

      final txSnap = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .get();

      final notifSnap = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Collect already generated alerts today for deduplication
      final existingTodayKeys = <String>{};
      for (var doc in notifSnap.docs) {
        final data = doc.data();
        final dt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        if (dt.year == today.year && dt.month == today.month && dt.day == today.day) {
          final relId = data['relatedId'] ?? '';
          final title = data['title'] ?? '';
          existingTodayKeys.add('${relId}_$title');
        }
      }

      final batch = FirebaseFirestore.instance.batch();
      int addedAlerts = 0;

      void addAlertIfNeeded(CreditCard card, String title, String body, String notifType) {
        final key = '${card.id}_$title';
        if (!existingTodayKeys.contains(key)) {
          existingTodayKeys.add(key);
          final notifRef = FirebaseFirestore.instance.collection('notifications').doc();
          final notif = NotificationModel(
            id: notifRef.id,
            userId: user.uid,
            title: title,
            body: body,
            createdAt: DateTime.now(),
            isRead: false,
            type: notifType,
            relatedId: card.id,
            category: 'debt',
          );
          batch.set(notifRef, notif.toFirestore());
          LocalNotificationService.showNotification(
            title: notif.title,
            body: notif.body,
            id: notif.id.hashCode.abs() % 100000,
          );

          if (user.email != null) {
            final mailRef = FirebaseFirestore.instance.collection('mail').doc();
            batch.set(mailRef, {
              'to': user.email,
              'message': {
                'subject': title,
                'text': body,
                'html': '<p>$body</p>',
              },
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          addedAlerts++;
        }
      }

      int daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;

      for (var card in cards) {
        double balance = card.currentBalance;
        for (var doc in txSnap.docs) {
          final data = doc.data();
          if (data['creditCardId'] == card.id) {
            final amount = (data['amount'] ?? 0.0).toDouble();
            if (data['type'] == 'expense') {
              balance += amount;
            } else if (data['type'] == 'cc_payment') {
              balance -= amount;
            }
          }
        }

        // Candidate cutOff dates (this month and next month)
        final cutOff1 = DateTime(today.year, today.month, card.cutOffDay.clamp(1, daysInMonth(today.year, today.month)));
        final cutOff2 = DateTime(today.year, today.month + 1, card.cutOffDay.clamp(1, daysInMonth(today.year, today.month + 1)));
        for (var d in [cutOff1, cutOff2]) {
          final diff = d.difference(today).inDays;
          if (diff == 2) {
            addAlertIfNeeded(card, '⚠️ Corte en 2 días: ${card.name}', 'Tu tarjeta realiza su corte el día ${card.cutOffDay}. Prepárate para revisar tu estado de cuenta del ciclo.', 'info');
          } else if (diff == 1) {
            addAlertIfNeeded(card, '⏳ Mañana es el corte: ${card.name}', 'Mañana día ${card.cutOffDay} es la fecha de corte de tu tarjeta de crédito.', 'info');
          } else if (diff == 0) {
            addAlertIfNeeded(card, '📊 Hoy corta tu tarjeta: ${card.name}', 'Hoy cierra tu ciclo de facturación. Revisa tus movimientos para conocer el saldo del periodo.', 'info');
          }
        }

        // Candidate payment dates (this month and next month)
        final pay1 = DateTime(today.year, today.month, card.paymentDay.clamp(1, daysInMonth(today.year, today.month)));
        final pay2 = DateTime(today.year, today.month + 1, card.paymentDay.clamp(1, daysInMonth(today.year, today.month + 1)));
        for (var d in [pay1, pay2]) {
          final diff = d.difference(today).inDays;
          if (diff == 2) {
            addAlertIfNeeded(card, '⚠️ Pago de tarjeta en 2 días: ${card.name}', 'Faltan 2 días para el pago de tu tarjeta (Día ${card.paymentDay}). Saldo estimado: ${CurrencyFormatter.format(balance, currencyCode)}.', 'warning');
          } else if (diff == 1) {
            addAlertIfNeeded(card, '⏰ Mañana vence tu tarjeta: ${card.name}', 'Mañana día ${card.paymentDay} es la fecha límite para pagar tu tarjeta sin intereses.', 'warning');
          } else if (diff == 0) {
            addAlertIfNeeded(card, '🚨 HOY vence tu tarjeta: ${card.name}', '¡Hoy es el día límite de pago para ${card.name}! Saldo actual: ${CurrencyFormatter.format(balance, currencyCode)}. Abona hoy para evitar recargos.', 'warning');
          }
        }

        // Overdue check (in mora): if today is 1 to 5 days past the payment day of this month and balance > 0
        final currentMonthPay = DateTime(today.year, today.month, card.paymentDay.clamp(1, daysInMonth(today.year, today.month)));
        final diffOverdue = currentMonthPay.difference(today).inDays;
        if (diffOverdue < 0 && diffOverdue >= -5 && balance > 0.05) {
          addAlertIfNeeded(card, '💥 TARJETA EN MORA: ${card.name}', 'Tu tarjeta venció el día ${card.paymentDay} y aún presenta un saldo pendiente de ${CurrencyFormatter.format(balance, currencyCode)}. ¡Abona cuanto antes para detener intereses moratorios!', 'expense');
        }
      }

      if (addedAlerts > 0) {
        await batch.commit();
      }
    } catch (e) {
      print('Error evaluating credit card alerts: $e');
    }
  }
}
