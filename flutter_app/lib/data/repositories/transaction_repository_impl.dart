import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config/database_config.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore? _customFirestore;

  TransactionRepositoryImpl({FirebaseFirestore? firestore})
    : _customFirestore = firestore;

  CollectionReference<Map<String, dynamic>> get _transactions =>
      _customFirestore != null
          ? _customFirestore.collection(DatabaseConfig.collectionName('transactions'))
          : DatabaseConfig.transactionsCollection;

  @override
  Stream<List<TransactionModel>> watchTransactions(String userId) {
    return _transactions
        .where('userId', isEqualTo: userId)
        .limit(500)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null &&
        transaction.userId.isNotEmpty &&
        transaction.userId != currentUid) {
      throw StateError('Operación no autorizada: UID de transacción inválido.');
    }
    if (transaction.id.isEmpty) {
      await _transactions.add(transaction.toFirestore());
    } else {
      await _transactions.doc(transaction.id).set(transaction.toFirestore());
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null &&
        transaction.userId.isNotEmpty &&
        transaction.userId != currentUid) {
      throw StateError('Operación no autorizada: UID de transacción inválido.');
    }
    await _transactions
        .doc(transaction.id)
        .update(transaction.toFirestore());
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError('Operación no autorizada: sesión no activa.');
    }
    await _transactions.doc(transactionId).delete();
  }
}
