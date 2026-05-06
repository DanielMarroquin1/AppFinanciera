import '../entities/transaction.dart';

abstract class TransactionRepository {
  Stream<List<TransactionModel>> watchTransactions(String userId);
  Future<void> addTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId);
}
