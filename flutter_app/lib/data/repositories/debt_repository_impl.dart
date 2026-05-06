import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/debt.dart';
import '../../domain/repositories/debt_repository.dart';

class DebtRepositoryImpl implements DebtRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<DebtModel>> watchDebts(String userId) {
    return _firestore
        .collection('debts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => DebtModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> addDebt(DebtModel debt) async {
    await _firestore.collection('debts').add(debt.toFirestore());
  }

  @override
  Future<void> updateDebt(DebtModel debt) async {
    await _firestore.collection('debts').doc(debt.id).update(debt.toFirestore());
  }

  @override
  Future<void> deleteDebt(String debtId) async {
    await _firestore.collection('debts').doc(debtId).delete();
  }
}
