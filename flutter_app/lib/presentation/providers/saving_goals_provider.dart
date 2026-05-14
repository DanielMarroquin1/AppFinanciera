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

  @override
  Future<List<SavingGoal>> build() async {
    _repository = ref.read(savingGoalRepositoryProvider);
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return [];
    }

    // Subscribe to the stream and update the state
    _repository.getUserGoals(user.email).listen((goals) {
      state = AsyncValue.data(goals);
    }, onError: (e, st) {
      state = AsyncValue.error(e, st);
    });

    // Return empty list initially while stream fetches data
    return [];
  }

  Future<void> addGoal(SavingGoal goal) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    
    final newGoal = goal.copyWith(userId: user.email);
    await _repository.addGoal(newGoal);
  }

  Future<void> updateGoal(SavingGoal goal) async {
    await _repository.updateGoal(goal);
  }

  Future<void> deleteGoal(String goalId) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    
    if (_repository is SavingGoalRepositoryImpl) {
      await (_repository as SavingGoalRepositoryImpl).deleteUserGoal(user.email, goalId);
    }
  }
}

final savingGoalsProvider = AsyncNotifierProvider<SavingGoalsNotifier, List<SavingGoal>>(() {
  return SavingGoalsNotifier();
});
