import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/services/recurring_transaction_service.dart';

// Provider for SharedPreferences to be injected
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepositoryImpl(prefs);
});

// AuthState to hold the user and loading status
class AuthState {
  final User? user;
  final bool isLoading;

  AuthState({this.user, this.isLoading = false});

  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Controller for Auth state (Equivalent to AuthContext methods)
class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _loadUser();
    return AuthState(isLoading: true);
  }

  Future<void> _loadUser() async {
    final user = await _repository.getStoredUser();
    state = AuthState(user: user, isLoading: false);
    if (user != null) {
      RecurringTransactionService.evaluateRecurringTransactions();
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.login(email, password);
      state = AuthState(user: user, isLoading: false);
      RecurringTransactionService.evaluateRecurringTransactions();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.loginWithGoogle();
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> register(String email, String password, String purpose) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repository.register(email, password, purpose);
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = AuthState(user: null, isLoading: false);
  }

  Future<void> completeTour() async {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(hasCompletedTour: true);
      await _repository.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> updateProfile(User data) async {
    if (state.user != null) {
      // Respect the profileComplete status from the incoming data, 
      // or evaluate if required fields are present if it's not set.
      bool isComplete = data.profileComplete || (data.country != null && data.currency != null && data.salary != null);
      final updatedUser = data.copyWith(profileComplete: isComplete);
      await _repository.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> checkStreakStatus() async {
    final user = state.user;
    if (user == null) return;

    if (user.lastActiveDate != null) {
      final now = DateTime.now();
      final lastActive = DateTime.tryParse(user.lastActiveDate!);
      if (lastActive != null) {
        final lastActiveDateOnly = DateTime(lastActive.year, lastActive.month, lastActive.day);
        final todayDateOnly = DateTime(now.year, now.month, now.day);
        final dayDiff = todayDateOnly.difference(lastActiveDateOnly).inDays;

        if (dayDiff > 1 && user.currentStreak > 0) {
          // Streak broken
          final updatedUser = user.copyWith(currentStreak: 0);
          await _repository.saveUser(updatedUser);
          state = state.copyWith(user: updatedUser);
        }
      }
    }
  }

  Future<bool> incrementStreakOnAction() async {
    final user = state.user;
    if (user == null) return false;

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (user.lastActiveDate == todayStr) {
      // Already did an action today
      return false;
    }

    int newStreak = user.currentStreak;
    int newPoints = user.points;

    if (user.lastActiveDate != null) {
      final lastActive = DateTime.tryParse(user.lastActiveDate!);
      if (lastActive != null) {
        final lastActiveDateOnly = DateTime(lastActive.year, lastActive.month, lastActive.day);
        final todayDateOnly = DateTime(now.year, now.month, now.day);
        final dayDiff = todayDateOnly.difference(lastActiveDateOnly).inDays;

        if (dayDiff == 1) {
          // Consecutive day
          newStreak += 1;
        } else if (dayDiff > 1) {
          // Streak broken
          newStreak = 1;
        } else {
            return false;
        }
      } else {
        newStreak = 1;
      }
    } else {
      // First action
      newStreak = 1;
    }

    // Award points: base 50 + 5 per consecutive day
    newPoints += 50 + (newStreak * 5);
    
    // Bonus points every 5 consecutive days
    if (newStreak % 5 == 0 && newStreak > 0) {
      newPoints += 200;
    }

    final updatedUser = user.copyWith(
      lastActiveDate: todayStr,
      currentStreak: newStreak,
      points: newPoints,
    );

    await _repository.saveUser(updatedUser);
    state = state.copyWith(user: updatedUser);

    // Return true to show the modal and animation
    return true;
  }

  Future<bool> purchaseItem(int cost, String itemId) async {
    final user = state.user;
    if (user == null) return false;

    if (user.points >= cost && !user.unlockedItems.contains(itemId)) {
      final newPoints = user.points - cost;
      final newUnlockedItems = List<String>.from(user.unlockedItems)..add(itemId);
      
      final updatedUser = user.copyWith(
        points: newPoints,
        unlockedItems: newUnlockedItems,
      );
      
      await _repository.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
      return true;
    }
    return false;
  }

  Future<void> equipAvatar(String avatarId) async {
    final user = state.user;
    if (user == null) return;
    
    if (user.unlockedItems.contains(avatarId) || avatarId == 'default') {
      final updatedUser = user.copyWith(currentAvatar: avatarId == 'default' ? null : avatarId);
      await _repository.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> updateMonthlyLimit(double limit) async {
    final user = state.user;
    if (user == null) return;
    
    final updatedUser = user.copyWith(monthlyLimit: limit);
    await _repository.saveUser(updatedUser);
    state = state.copyWith(user: updatedUser);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
