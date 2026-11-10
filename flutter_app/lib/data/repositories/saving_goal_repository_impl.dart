import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/database_config.dart';
import '../../domain/entities/saving_goal.dart';
import '../../domain/repositories/saving_goal_repository.dart';

class SavingGoalRepositoryImpl implements SavingGoalRepository {
  CollectionReference<Map<String, dynamic>> get _users =>
      DatabaseConfig.usersCollection;

  @override
  Stream<List<SavingGoal>> getUserGoals(String userId) {
    return _users
        .doc(userId)
        .collection('saving_goals')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SavingGoal.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Future<void> addGoal(SavingGoal goal) async {
    await _users
        .doc(goal.userId)
        .collection('saving_goals')
        .add(goal.toMap());
  }

  @override
  Future<void> updateGoal(SavingGoal goal) async {
    await _users
        .doc(goal.userId)
        .collection('saving_goals')
        .doc(goal.id)
        .update(goal.toMap());
  }

  @override
  Future<void> deleteGoal(String id) async {
    // We would need the userId to delete correctly from the subcollection.
    // However, usually we can use a collectionGroup query if id is unique,
    // or pass userId to delete. For simplicity, assuming we only delete knowing the path.
    // A better approach is to pass userId and goalId.
    throw UnimplementedError(
      "Use deleteUserGoal(userId, goalId) instead or add it to interface",
    );
  }

  Future<void> deleteUserGoal(String userId, String goalId) async {
    await _users
        .doc(userId)
        .collection('saving_goals')
        .doc(goalId)
        .delete();
  }
}
