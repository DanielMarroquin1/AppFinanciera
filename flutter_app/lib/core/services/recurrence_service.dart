import 'recurring_transaction_service.dart';

/// Servicio unificado de recurrencia.
/// Delega de forma centralizada a [RecurringTransactionService] para garantizar
/// evaluación idempotente, prevención de transacciones duplicadas y deduplicación en Firestore.
class RecurrenceService {
  static Future<void> processRecurrences(String userId) async {
    await RecurringTransactionService.evaluateRecurringTransactions();
  }
}
