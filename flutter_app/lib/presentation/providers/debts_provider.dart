import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/debt.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../data/repositories/debt_repository_impl.dart';
import 'auth_provider.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepositoryImpl();
});

// Stream de deudas del usuario actual
final debtsProvider = StreamProvider<List<DebtModel>>((ref) {
  final userEmail = ref.watch(authProvider.select((s) => s.user?.email));
  final repository = ref.watch(debtRepositoryProvider);

  if (userEmail != null) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      return repository.watchDebts(uid);
    }
  }
  return Stream.value([]);
});

class DebtNotifier extends Notifier<void> {
  late DebtRepository _repository;

  @override
  void build() {
    _repository = ref.read(debtRepositoryProvider);
  }

  Future<void> addDebt(DebtModel debt) async {
    await _repository.addDebt(debt);
  }

  Future<void> updateDebt(DebtModel debt) async {
    await _repository.updateDebt(debt);
  }

  Future<void> deleteDebt(String debtId) async {
    await _repository.deleteDebt(debtId);
  }
}

final debtNotifierProvider = NotifierProvider<DebtNotifier, void>(() {
  return DebtNotifier();
});
