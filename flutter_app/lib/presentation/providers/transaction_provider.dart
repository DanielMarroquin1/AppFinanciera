import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import 'auth_provider.dart';

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

class TransactionNotifier extends Notifier<void> {
  late TransactionRepository _repository;

  @override
  void build() {
    _repository = ref.read(transactionRepositoryProvider);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _repository.addTransaction(transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _repository.deleteTransaction(transactionId);
  }
}

final transactionNotifierProvider = NotifierProvider<TransactionNotifier, void>(() {
  return TransactionNotifier();
});
