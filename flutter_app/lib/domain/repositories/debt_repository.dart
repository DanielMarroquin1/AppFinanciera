import '../entities/debt.dart';

abstract class DebtRepository {
  Stream<List<DebtModel>> watchDebts(String userId);
  Future<void> addDebt(DebtModel debt);
  Future<void> updateDebt(DebtModel debt);
  Future<void> deleteDebt(String debtId);
}
