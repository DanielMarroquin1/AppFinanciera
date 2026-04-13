import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

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
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    final user = await _repository.login(email, password);
    state = AuthState(user: user, isLoading: false);
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);
    final user = await _repository.loginWithGoogle();
    state = AuthState(user: user, isLoading: false);
  }

  Future<void> register(String email, String password, String purpose) async {
    state = state.copyWith(isLoading: true);
    final user = await _repository.register(email, password, purpose);
    state = AuthState(user: user, isLoading: false);
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
      bool isComplete = data.country != null && data.currency != null && data.salary != null;
      final updatedUser = data.copyWith(profileComplete: isComplete);
      await _repository.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
