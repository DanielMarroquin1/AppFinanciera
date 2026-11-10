import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/database_config.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/entities/saving_goal.dart';
import '../utils/currency_formatter.dart';
import 'local_notification_service.dart';

class RecurringTransactionService {
  static bool _isEvaluating = false;

  static Future<void> evaluateRecurringTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_isEvaluating) {
      return;
    }
    _isEvaluating = true;

    try {
      await cleanDuplicates(user.uid);

      final prefs = await SharedPreferences.getInstance();
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final String todayIso = today.toIso8601String();

      final String lastCheckStr =
          prefs.getString('last_recurring_check_${user.uid}') ?? '';

      DateTime lastCheck;
      if (lastCheckStr.isEmpty) {
        lastCheck = today.subtract(const Duration(days: 60));
      } else {
        lastCheck = DateTime.parse(lastCheckStr);
      }

      if (!lastCheck.isBefore(today)) {
        // Ya verificado hoy
        return;
      }

      // Marcar de inmediato la fecha de verificación para bloquear llamadas concurrentes
      await prefs.setString('last_recurring_check_${user.uid}', todayIso);

      final existingSnapshot = await DatabaseConfig.transactionsCollection
          .where('userId', isEqualTo: user.uid)
          .get();
      final List<TransactionModel> existingNormal = existingSnapshot.docs
          .map((d) => TransactionModel.fromFirestore(d))
          .where((t) => !t.isFixed)
          .toList();

      // Obtener transacciones fijas / recurrentes (plantillas)
      final snapshot = await DatabaseConfig.transactionsCollection
          .where('userId', isEqualTo: user.uid)
          .where('isFixed', isEqualTo: true)
          .get();

      final templates = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
      final batch = DatabaseConfig.firestore.batch();
      int addedCount = 0;

      for (var template in templates) {
        if (template.recurrenceType == null || template.recurrenceDay == null) {
          continue;
        }

        DateTime templateDate = DateTime(
          template.date.year,
          template.date.month,
          template.date.day,
        );
        DateTime start = lastCheck.isBefore(templateDate)
            ? templateDate
            : lastCheck;

        DateTime current = start.add(const Duration(days: 1));

        final String cleanDesc = template.description.trim().isNotEmpty
            ? template.description.trim()
            : (template.category.trim().isNotEmpty
                ? template.category.trim()
                : (template.type == 'income' ? 'Ingreso Fijo' : 'Cobro Fijo'));

        while (!current.isAfter(today)) {
          bool shouldAdd = false;

          if (template.recurrenceType == 'monthly') {
            if (current.day == template.recurrenceDay) {
              shouldAdd = true;
            }
          } else if (template.recurrenceType == 'bimonthly') {
            if (current.day == template.recurrenceDay ||
                current.day == template.recurrenceDay2) {
              shouldAdd = true;
            }
          } else if (template.recurrenceType == 'weekly') {
            if (current.weekday == template.recurrenceDay) {
              shouldAdd = true;
            }
          }

          if (shouldAdd) {
            final targetDesc = '$cleanDesc (Automático)';
            final alreadyExists = existingNormal.any(
              (t) =>
                  (t.description == targetDesc ||
                      t.description == cleanDesc ||
                      t.description.contains(cleanDesc)) &&
                  t.type == template.type &&
                  (t.amount - template.getAmountForDay(current.day)).abs() < 0.01 &&
                  t.date.year == current.year &&
                  t.date.month == current.month &&
                  t.date.day == current.day,
            );
            if (alreadyExists) {
              shouldAdd = false;
            }
          }

          if (shouldAdd) {
            final double amount = template.getAmountForDay(current.day);
            final String dateKey = '${current.year}_${current.month.toString().padLeft(2, '0')}_${current.day.toString().padLeft(2, '0')}';
            final String docId = 'auto_tx_${user.uid}_${template.id}_$dateKey';
            final String notifId = 'auto_notif_${user.uid}_${template.id}_$dateKey';

            final newTx = TransactionModel(
              id: docId,
              userId: user.uid,
              amount: amount,
              type: template.type,
              category: template.category,
              description: '$cleanDesc (Automático)',
              date: current,
              isFixed: false,
            );

            existingNormal.add(newTx);

            final docRef = DatabaseConfig.transactionsCollection.doc(docId);
            batch.set(docRef, newTx.toFirestore(), SetOptions(merge: true));

            // Notificación con título y descripción nunca vacíos
            final notifRef = DatabaseConfig.notificationsCollection.doc(notifId);
            final notif = NotificationModel(
              id: notifId,
              userId: user.uid,
              title: template.type == 'income'
                  ? 'Ingreso Automático'
                  : 'Cobro Automático',
              body:
                  'Se ha registrado "$cleanDesc" por un monto de ${amount.toStringAsFixed(2)}.',
              createdAt: DateTime.now(),
              isRead: false,
              type: template.type,
              relatedId: docId,
              category: template.category,
            );
            batch.set(notifRef, notif.toFirestore(), SetOptions(merge: true));

            LocalNotificationService.showNotification(
              title: notif.title,
              body: notif.body,
              id: notif.id.hashCode.abs() % 100000,
            );

            if (user.email != null) {
              final mailRef = DatabaseConfig.mailCollection.doc('mail_$docId');
              batch.set(mailRef, {
                'to': user.email,
                'message': {
                  'subject': template.type == 'income'
                      ? 'Ingreso Automático Registrado'
                      : 'Cobro Automático Registrado',
                  'text':
                      'Se ha registrado "$cleanDesc" por un monto de ${amount.toStringAsFixed(2)}.',
                  'html':
                      '<p>Se ha registrado <strong>"$cleanDesc"</strong> por un monto de ${amount.toStringAsFixed(2)}.</p>',
                },
                'createdAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }

            addedCount++;
          }

          current = current.add(const Duration(days: 1));
        }
      }

    // Now evaluate Debts with isAutoPay == true
    final debtSnapshot = await DatabaseConfig.debtsCollection
        .where('userId', isEqualTo: user.uid)
        .where('isAutoPay', isEqualTo: true)
        .get();

    final debtTemplates = debtSnapshot.docs
        .map((doc) => DebtModel.fromFirestore(doc))
        .toList();

    for (var debt in debtTemplates) {
      if (debt.recurrenceType == null || debt.recurrenceDay == null) continue;
      if (debt.paidInstallments >= debt.totalInstallments) {
        continue; // Already paid
      }

      DateTime templateDate = DateTime(
        debt.createdAt.year,
        debt.createdAt.month,
        debt.createdAt.day,
      );
      DateTime start = lastCheck.isBefore(templateDate)
          ? templateDate
          : lastCheck;
      DateTime current = start.add(const Duration(days: 1));

      int addedInstallments = 0;

      while (!current.isAfter(today) &&
          (debt.paidInstallments + addedInstallments) <
              debt.totalInstallments) {
        bool shouldAdd = false;

        if (debt.recurrenceType == 'monthly') {
          if (current.day == debt.recurrenceDay) shouldAdd = true;
        } else if (debt.recurrenceType == 'bimonthly') {
          if (current.day == debt.recurrenceDay ||
              current.day == debt.recurrenceDay2) {
            shouldAdd = true;
          }
        } else if (debt.recurrenceType == 'weekly') {
          if (current.weekday == debt.recurrenceDay) shouldAdd = true;
        }

        if (shouldAdd) {
          final targetDesc = 'Cuota de ${debt.name} (Automático)';
          final alreadyExists = existingNormal.any(
            (t) =>
                t.description == targetDesc &&
                t.date.year == current.year &&
                t.date.month == current.month &&
                t.date.day == current.day,
          );
          if (alreadyExists) {
            shouldAdd = false;
          }
        }

        if (shouldAdd) {
          final String dateKey = '${current.year}_${current.month.toString().padLeft(2, '0')}_${current.day.toString().padLeft(2, '0')}';
          final String docId = 'auto_debt_${user.uid}_${debt.id}_$dateKey';
          final String notifId = 'auto_debt_notif_${user.uid}_${debt.id}_$dateKey';

          // Create the expense transaction
          final newTx = TransactionModel(
            id: docId,
            userId: user.uid,
            amount: debt.installmentAmount,
            type: 'expense',
            category: debt.category,
            description: 'Cuota de ${debt.name} (Automático)',
            date: current,
            isFixed: false,
          );

          existingNormal.add(newTx);

          final docRef = DatabaseConfig.transactionsCollection.doc(docId);
          batch.set(docRef, newTx.toFirestore(), SetOptions(merge: true));

          // Generate notification
          final notifRef = DatabaseConfig.notificationsCollection.doc(notifId);
          final notif = NotificationModel(
            id: notifId,
            userId: user.uid,
            title: 'Pago Automático de Deuda',
            body:
                'Se ha cobrado la cuota de "${debt.name}" por un monto de ${debt.installmentAmount.toStringAsFixed(2)}.',
            createdAt: DateTime.now(),
            isRead: false,
            type: 'expense',
            relatedId: docId,
            category: debt.category,
          );
          batch.set(notifRef, notif.toFirestore(), SetOptions(merge: true));
          LocalNotificationService.showNotification(
            title: notif.title,
            body: notif.body,
            id: notif.id.hashCode.abs() % 100000,
          );

          if (user.email != null) {
            final mailRef = DatabaseConfig.mailCollection.doc('mail_$docId');
            batch.set(mailRef, {
              'to': user.email,
              'message': {
                'subject': 'Pago Automático de Deuda',
                'text':
                    'Se ha cobrado la cuota de "${debt.name}" por un monto de ${debt.installmentAmount.toStringAsFixed(2)}.',
                'html':
                    '<p>Se ha cobrado la cuota de <strong>"${debt.name}"</strong> por un monto de ${debt.installmentAmount.toStringAsFixed(2)}.</p>',
              },
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          addedInstallments++;
          addedCount++;
        }

        current = current.add(const Duration(days: 1));
      }

      // Update debt's paidInstallments if we added any
      if (addedInstallments > 0) {
        final newDebt = debt.copyWith(
          paidInstallments: debt.paidInstallments + addedInstallments,
        );
        final debtRef = DatabaseConfig.debtsCollection.doc(debt.id);
        batch.update(debtRef, {'paidInstallments': newDebt.paidInstallments});
      }
    }

    // Evaluate Saving Goals with isAutoDeduct == true
    List<DocumentSnapshot> goalDocs = [];
    if (user.email != null && user.email!.isNotEmpty) {
      try {
        final emailGoalsSnap = await DatabaseConfig.usersCollection
            .doc(user.email)
            .collection('saving_goals')
            .where('isAutoDeduct', isEqualTo: true)
            .get();
        goalDocs.addAll(emailGoalsSnap.docs);
      } catch (_) {}
    }
    try {
      final uidGoalsSnap = await DatabaseConfig.usersCollection
          .doc(user.uid)
          .collection('saving_goals')
          .where('isAutoDeduct', isEqualTo: true)
          .get();
      for (var d in uidGoalsSnap.docs) {
        if (!goalDocs.any((g) => g.id == d.id)) {
          goalDocs.add(d);
        }
      }
    } catch (_) {}

    for (var doc in goalDocs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;
      final goal = SavingGoal.fromMap(data, doc.id);

      if (goal.autoDeductAmount == null || goal.autoDeductAmount! <= 0) continue;
      if (goal.autoDeductFrequency == null || goal.autoDeductDay == null) continue;
      if (goal.currentAmount >= goal.targetAmount) continue; // Goal already reached

      DateTime templateDate = goal.lastAutoDeductDate ?? lastCheck;
      DateTime start = lastCheck.isBefore(templateDate) ? templateDate : lastCheck;
      DateTime current = start.add(const Duration(days: 1));

      double addedToGoal = 0.0;
      DateTime? latestDeductDate;

      while (!current.isAfter(today) &&
          (goal.currentAmount + addedToGoal) < goal.targetAmount) {
        bool shouldAdd = false;

        if (goal.autoDeductFrequency == 'monthly') {
          if (current.day == goal.autoDeductDay) shouldAdd = true;
        } else if (goal.autoDeductFrequency == 'biweekly') {
          final day1 = goal.autoDeductDay ?? 1;
          final day2 = goal.autoDeductDay2 ??
              ((day1 + 15) > 31 ? 30 : (day1 + 15));
          if (current.day == day1 || current.day == day2) {
            shouldAdd = true;
          }
        } else if (goal.autoDeductFrequency == 'weekly') {
          if (current.weekday == goal.autoDeductDay) shouldAdd = true;
        }

        if (shouldAdd) {
          final targetDesc = 'Ahorro Automático: ${goal.name}';
          final alreadyExists = existingNormal.any(
            (t) =>
                t.description == targetDesc &&
                t.date.year == current.year &&
                t.date.month == current.month &&
                t.date.day == current.day,
          );
          if (alreadyExists) {
            shouldAdd = false;
          }
        }

        if (shouldAdd) {
          final deductAmount = goal.autoDeductAmount!;
          final remaining = goal.targetAmount - (goal.currentAmount + addedToGoal);
          final actualDeduct =
              deductAmount > remaining ? remaining : deductAmount;

          final String dateKey = '${current.year}_${current.month.toString().padLeft(2, '0')}_${current.day.toString().padLeft(2, '0')}';
          final String docId = 'auto_save_${user.uid}_${goal.id}_$dateKey';
          final String notifId = 'auto_save_notif_${user.uid}_${goal.id}_$dateKey';

          // Create the expense transaction
          final newTx = TransactionModel(
            id: docId,
            userId: user.uid,
            amount: actualDeduct,
            type: 'expense',
            category: 'Ahorro',
            description: 'Ahorro Automático: ${goal.name}',
            date: current,
            isFixed: false,
          );

          existingNormal.add(newTx);

          final docRef = DatabaseConfig.transactionsCollection.doc(docId);
          batch.set(docRef, newTx.toFirestore(), SetOptions(merge: true));

          // In-app notification
          final notifRef = DatabaseConfig.notificationsCollection.doc(notifId);
          final notif = NotificationModel(
            id: notifId,
            userId: user.uid,
            title: '🌱 Ahorro Automático Aplicado',
            body:
                'Se descontaron ${actualDeduct.toStringAsFixed(2)} y se abonaron a tu meta "${goal.name}".',
            createdAt: DateTime.now(),
            isRead: false,
            type: 'savings',
            relatedId: docId,
            category: 'Ahorro',
          );
          batch.set(notifRef, notif.toFirestore(), SetOptions(merge: true));
          LocalNotificationService.showNotification(
            title: notif.title,
            body: notif.body,
            id: notif.id.hashCode.abs() % 100000,
          );

          if (user.email != null) {
            final mailRef = DatabaseConfig.mailCollection.doc('mail_$docId');
            batch.set(mailRef, {
              'to': user.email,
              'message': {
                'subject': 'Ahorro Automático Registrado',
                'text':
                    'Se han abonado ${actualDeduct.toStringAsFixed(2)} a tu meta "${goal.name}".',
                'html':
                    '<p>🌱 Se ha transferido automáticamente <strong>${actualDeduct.toStringAsFixed(2)}</strong> a tu meta <strong>"${goal.name}"</strong>.</p>',
              },
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          addedToGoal += actualDeduct;
          latestDeductDate = current;
          addedCount++;
        }

        current = current.add(const Duration(days: 1));
      }

      // Update goal's currentAmount and lastAutoDeductDate in batch
      if (addedToGoal > 0) {
        batch.update(doc.reference, {
          'currentAmount': goal.currentAmount + addedToGoal,
          if (latestDeductDate != null)
            'lastAutoDeductDate': latestDeductDate.toIso8601String(),
        });
      }
    }

    if (addedCount > 0) {
      await batch.commit();
    }

    await evaluateCreditCardAlerts();
    await cleanDuplicates(user.uid);
    } finally {
      _isEvaluating = false;
    }
  }

  static Future<void> cleanDuplicates(String uid) async {
    final snapshot = await DatabaseConfig.transactionsCollection
        .where('userId', isEqualTo: uid)
        .get();

    final allNormal = snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .where((t) => !t.isFixed)
        .toList();
    final Map<String, List<TransactionModel>> groups = {};

    for (var t in allNormal) {
      // Normalizar descripción quitando sufijos automáticos para encontrar duplicados exactos
      String cleanDesc = t.description.replaceAll(' (Automático)', '').trim().toLowerCase();
      if (cleanDesc.isEmpty) {
        cleanDesc = t.category.trim().toLowerCase();
      }
      final key =
          '${t.type}_${t.amount.toStringAsFixed(2)}_${t.date.year}_${t.date.month}_${t.date.day}_$cleanDesc';
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(t);
    }

    final batch = DatabaseConfig.firestore.batch();
    int deletedCount = 0;

    for (var group in groups.values) {
      if (group.length > 1) {
        // Dejar el primero, borrar duplicados
        for (int i = 1; i < group.length; i++) {
          final docRef = DatabaseConfig.transactionsCollection.doc(group[i].id);
          batch.delete(docRef);
          deletedCount++;
        }
      }
    }

    // Clean duplicate notifications
    final notifSnapshot = await DatabaseConfig.notificationsCollection
        .where('userId', isEqualTo: uid)
        .get();
    final allNotifs = notifSnapshot.docs
        .map((d) => NotificationModel.fromFirestore(d))
        .toList();
    final Map<String, List<NotificationModel>> notifGroups = {};
    for (var n in allNotifs) {
      final key =
          '${n.title}_${n.body}_${n.createdAt.year}_${n.createdAt.month}_${n.createdAt.day}';
      if (!notifGroups.containsKey(key)) notifGroups[key] = [];
      notifGroups[key]!.add(n);
    }
    for (var g in notifGroups.values) {
      if (g.length > 1) {
        for (int i = 1; i < g.length; i++) {
          batch.delete(
            DatabaseConfig.notificationsCollection.doc(g[i].id),
          );
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
      final userDoc = await DatabaseConfig.usersCollection
          .doc(user.uid)
          .get();
      final currencyCode = (userDoc.data()?['currency'] as String?) ?? 'USD';

      final cardsSnap = await DatabaseConfig.usersCollection
          .doc(user.uid)
          .collection('credit_cards')
          .get();
      if (cardsSnap.docs.isEmpty) return;

      final cards = cardsSnap.docs
          .map((d) => CreditCard.fromFirestore(d))
          .toList();

      final txSnap = await DatabaseConfig.transactionsCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      final notifSnap = await DatabaseConfig.notificationsCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Collect already generated alerts today for deduplication
      final existingTodayKeys = <String>{};
      for (var doc in notifSnap.docs) {
        final data = doc.data();
        final dt =
            (data['createdAt'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);
        if (dt.year == today.year &&
            dt.month == today.month &&
            dt.day == today.day) {
          final relId = data['relatedId'] ?? '';
          final title = data['title'] ?? '';
          existingTodayKeys.add('${relId}_$title');
        }
      }

      final batch = DatabaseConfig.firestore.batch();
      int addedAlerts = 0;

      void addAlertIfNeeded(
        CreditCard card,
        String title,
        String body,
        String notifType,
      ) {
        final key = '${card.id}_$title';
        if (!existingTodayKeys.contains(key)) {
          existingTodayKeys.add(key);
          final notifRef = DatabaseConfig.notificationsCollection.doc();
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
            final mailRef = DatabaseConfig.mailCollection.doc();
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
        final cutOff1 = DateTime(
          today.year,
          today.month,
          card.cutOffDay.clamp(1, daysInMonth(today.year, today.month)),
        );
        final cutOff2 = DateTime(
          today.year,
          today.month + 1,
          card.cutOffDay.clamp(1, daysInMonth(today.year, today.month + 1)),
        );
        for (var d in [cutOff1, cutOff2]) {
          final diff = d.difference(today).inDays;
          if (diff == 2) {
            addAlertIfNeeded(
              card,
              '⚠️ Corte en 2 días: ${card.name}',
              'Tu tarjeta realiza su corte el día ${card.cutOffDay}. Prepárate para revisar tu estado de cuenta del ciclo.',
              'info',
            );
          } else if (diff == 1) {
            addAlertIfNeeded(
              card,
              '⏳ Mañana es el corte: ${card.name}',
              'Mañana día ${card.cutOffDay} es la fecha de corte de tu tarjeta de crédito.',
              'info',
            );
          } else if (diff == 0) {
            addAlertIfNeeded(
              card,
              '📊 Hoy corta tu tarjeta: ${card.name}',
              'Hoy cierra tu ciclo de facturación. Revisa tus movimientos para conocer el saldo del periodo.',
              'info',
            );
          }
        }

        // Candidate payment dates (this month and next month)
        final pay1 = DateTime(
          today.year,
          today.month,
          card.paymentDay.clamp(1, daysInMonth(today.year, today.month)),
        );
        final pay2 = DateTime(
          today.year,
          today.month + 1,
          card.paymentDay.clamp(1, daysInMonth(today.year, today.month + 1)),
        );
        for (var d in [pay1, pay2]) {
          final diff = d.difference(today).inDays;
          if (diff == 2) {
            addAlertIfNeeded(
              card,
              '⚠️ Pago de tarjeta en 2 días: ${card.name}',
              'Faltan 2 días para el pago de tu tarjeta (Día ${card.paymentDay}). Saldo estimado: ${CurrencyFormatter.format(balance, currencyCode)}.',
              'warning',
            );
          } else if (diff == 1) {
            addAlertIfNeeded(
              card,
              '⏰ Mañana vence tu tarjeta: ${card.name}',
              'Mañana día ${card.paymentDay} es la fecha límite para pagar tu tarjeta sin intereses.',
              'warning',
            );
          } else if (diff == 0) {
            addAlertIfNeeded(
              card,
              '🚨 HOY vence tu tarjeta: ${card.name}',
              '¡Hoy es el día límite de pago para ${card.name}! Saldo actual: ${CurrencyFormatter.format(balance, currencyCode)}. Abona hoy para evitar recargos.',
              'warning',
            );
          }
        }

        // Overdue check (in mora): if today is 1 to 5 days past the payment day of this month and balance > 0
        final currentMonthPay = DateTime(
          today.year,
          today.month,
          card.paymentDay.clamp(1, daysInMonth(today.year, today.month)),
        );
        final diffOverdue = currentMonthPay.difference(today).inDays;
        if (diffOverdue < 0 && diffOverdue >= -5 && balance > 0.05) {
          addAlertIfNeeded(
            card,
            '💥 TARJETA EN MORA: ${card.name}',
            'Tu tarjeta venció el día ${card.paymentDay} y aún presenta un saldo pendiente de ${CurrencyFormatter.format(balance, currencyCode)}. ¡Abona cuanto antes para detener intereses moratorios!',
            'expense',
          );
        }
      }

      if (addedAlerts > 0) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error evaluating credit card alerts: $e');
    }
  }
}
