import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences prefs;

  AuthRepositoryImpl(this.prefs);

  @override
  Future<User?> getStoredUser() async {
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final map = json.decode(userJson);
      return User(
        email: map['email'],
        name: map['name'],
        purpose: map['purpose'],
        hasCompletedTour: map['hasCompletedTour'],
        profileComplete: map['profileComplete'],
      );
    }
    return null;
  }

  @override
  Future<void> saveUser(User user) async {
    final map = {
      'email': user.email,
      'name': user.name,
      'purpose': user.purpose,
      'hasCompletedTour': user.hasCompletedTour,
      'profileComplete': user.profileComplete,
    };
    await prefs.setString('user', json.encode(map));
  }

  @override
  Future<void> removeUser() async {
    await prefs.remove('user');
  }

  @override
  Future<User> login(String email, String password) async {
    // Simulación de login basada en AuthContext
    final user = User(
      email: email,
      name: email.split('@').first,
      purpose: "Aprender a ahorrar",
      hasCompletedTour: false,
      profileComplete: false,
    );
    await saveUser(user);
    return user;
  }

  @override
  Future<User> loginWithGoogle() async {
    final user = User(
      email: "usuario@gmail.com",
      name: "Usuario Demo",
      purpose: "Aprender a ahorrar",
      hasCompletedTour: false,
      profileComplete: false,
    );
    await saveUser(user);
    return user;
  }

  @override
  Future<User> register(String email, String password, String purpose) async {
    final user = User(
      email: email,
      name: email.split('@').first,
      purpose: purpose,
      hasCompletedTour: false,
      profileComplete: false,
    );
    await saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await removeUser();
  }
}
