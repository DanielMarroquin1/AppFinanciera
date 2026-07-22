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

        if (dayDiff == 2 && user.currentStreak > 0) {
          final hasFreeze = user.unlockedItems.contains('spec2') || user.unlockedItems.contains('streak_freeze');
          if (!hasFreeze) {
            // Si pasaron 24h (estamos en dayDiff == 2) y NO tiene comprado el escudo congelador, se pierde la racha
            final updatedUser = user.copyWith(currentStreak: 0);
            await _repository.saveUser(updatedUser);
            state = state.copyWith(user: updatedUser);
          }
          // Si tiene escudo congelador (hasFreeze == true), se mantiene en dayDiff == 2 con racha congelada en UI
        } else if (dayDiff > 2 && user.currentStreak > 0) {
          // Si pasaron más de 48h (dayDiff > 2), se pierde la racha haya tenido escudo o no
          final updatedUnlocked = List<String>.from(user.unlockedItems)
            ..remove('spec2')
            ..remove('streak_freeze');
          final updatedUser = user.copyWith(
            currentStreak: 0,
            unlockedItems: updatedUnlocked,
          );
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
      return false;
    }

    int newStreak = user.currentStreak;
    int newPoints = user.points;
    List<String> updatedUnlocked = List<String>.from(user.unlockedItems);

    if (user.lastActiveDate != null) {
      final lastActive = DateTime.tryParse(user.lastActiveDate!);
      if (lastActive != null) {
        final lastActiveDateOnly = DateTime(lastActive.year, lastActive.month, lastActive.day);
        final todayDateOnly = DateTime(now.year, now.month, now.day);
        final dayDiff = todayDateOnly.difference(lastActiveDateOnly).inDays;

        if (dayDiff == 1) {
          newStreak += 1;
        } else if (dayDiff == 2) {
          final hasFreeze = updatedUnlocked.contains('spec2') || updatedUnlocked.contains('streak_freeze');
          if (hasFreeze) {
            // Se consume el escudo para descongelar y continuar sumando racha
            updatedUnlocked.remove('spec2');
            updatedUnlocked.remove('streak_freeze');
            newStreak += 1;
          } else {
            newStreak = 1;
          }
        } else if (dayDiff > 2) {
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
      unlockedItems: updatedUnlocked,
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

  Future<void> addPoints(int amountToAdd) async {
    final user = state.user;
    if (user == null) return;
    final updatedUser = user.copyWith(points: user.points + amountToAdd);
    await _repository.saveUser(updatedUser);
    state = state.copyWith(user: updatedUser);
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

  Future<void> upgradeToPremium() async {
    final user = state.user;
    if (user == null) return;
    final newUnlocked = List<String>.from(user.unlockedItems);
    if (!newUnlocked.contains('premium')) newUnlocked.add('premium');
    final updatedUser = user.copyWith(unlockedItems: newUnlocked);
    await _repository.saveUser(updatedUser);
    state = state.copyWith(user: updatedUser);
  }

  Future<void> cancelSubscription() async {
    final user = state.user;
    if (user == null) return;
    final newUnlocked = List<String>.from(user.unlockedItems)
      ..remove('premium')
      ..remove('spec1')
      ..remove('vip');
    final updatedUser = user.copyWith(unlockedItems: newUnlocked);
    await _repository.saveUser(updatedUser);
    state = state.copyWith(user: updatedUser);
  }

  Future<void> resetUnlockedThemes() async {
    final user = state.user;
    if (user == null) return;
    final newUnlocked = List<String>.from(user.unlockedItems)
      ..removeWhere((item) => item.startsWith('theme') && item != 'theme_default');
    final updatedUser = user.copyWith(
      unlockedItems: newUnlocked,
      points: user.points < 500 ? 500 : user.points,
    );
    await _repository.saveUser(updatedUser);
    state = state.copyWith(user: updatedUser);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
