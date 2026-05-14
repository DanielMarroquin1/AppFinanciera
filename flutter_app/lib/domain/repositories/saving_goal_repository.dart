import '../entities/saving_goal.dart';

abstract class SavingGoalRepository {
  Stream<List<SavingGoal>> getUserGoals(String userId);
  Future<void> addGoal(SavingGoal goal);
  Future<void> updateGoal(SavingGoal goal);
  Future<void> deleteGoal(String id);
}
