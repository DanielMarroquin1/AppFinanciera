import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/saving_goal.dart';
import '../../domain/repositories/saving_goal_repository.dart';
import '../../data/repositories/saving_goal_repository_impl.dart';
import 'auth_provider.dart';

final savingGoalRepositoryProvider = Provider<SavingGoalRepository>((ref) {
  return SavingGoalRepositoryImpl();
});

class SavingGoalsNotifier extends AsyncNotifier<List<SavingGoal>> {
  late SavingGoalRepository _repository;
  StreamSubscription<List<SavingGoal>>? _subscription;

  @override
  Future<List<SavingGoal>> build() async {
    _repository = ref.read(savingGoalRepositoryProvider);
    final userEmail = ref.watch(authProvider.select((s) => s.user?.email));

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    if (userEmail == null || userEmail.isEmpty) {
      return [];
    }

    final completer = Completer<List<SavingGoal>>();
    _subscription?.cancel();
    _subscription = _repository
        .getUserGoals(userEmail)
        .listen(
          (goals) {
            if (!completer.isCompleted) {
              completer.complete(goals);
            } else {
              state = AsyncValue.data(goals);
            }
          },
          onError: (e, st) {
            if (!completer.isCompleted) {
              completer.completeError(e, st);
            } else {
              state = AsyncValue.error(e, st);
            }
          },
        );

    return completer.future;
  }

  Future<void> addGoal(SavingGoal goal) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final newGoal = goal.copyWith(userId: user.email);
    await _repository.addGoal(newGoal);
  }

  Future<void> updateGoal(SavingGoal goal) async {
    final user = ref.read(authProvider).user;
    if (user == null || goal.userId != user.email) return;
    await _repository.updateGoal(goal);
  }

  Future<void> deleteGoal(String goalId) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    if (_repository is SavingGoalRepositoryImpl) {
      await (_repository as SavingGoalRepositoryImpl).deleteUserGoal(
        user.email,
        goalId,
      );
    }
  }
}

final savingGoalsProvider =
    AsyncNotifierProvider<SavingGoalsNotifier, List<SavingGoal>>(() {
      return SavingGoalsNotifier();
    });
