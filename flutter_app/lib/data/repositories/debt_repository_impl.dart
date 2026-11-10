import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/config/database_config.dart';
import '../../domain/entities/debt.dart';
import '../../domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  CollectionReference<Map<String, dynamic>> get _debts =>
      DatabaseConfig.debtsCollection;

  @override
  Stream<List<DebtModel>> watchDebts(String userId) {
    return _debts
        .where('userId', isEqualTo: userId)
        .limit(200)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => DebtModel.fromFirestore(doc))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  @override
  Future<void> addDebt(DebtModel debt) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null &&
        debt.userId.isNotEmpty &&
        debt.userId != currentUid) {
      throw StateError('Operación no autorizada: UID de deuda inválido.');
    }
    await _debts.add(debt.toFirestore());
  }

  @override
  Future<void> updateDebt(DebtModel debt) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null &&
        debt.userId.isNotEmpty &&
        debt.userId != currentUid) {
      throw StateError('Operación no autorizada: UID de deuda inválido.');
    }
    await _debts
        .doc(debt.id)
        .update(debt.toFirestore());
  }

  @override
  Future<void> deleteDebt(String debtId) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError('Operación no autorizada: sesión no activa.');
    }
    await _debts.doc(debtId).delete();
  }
}
