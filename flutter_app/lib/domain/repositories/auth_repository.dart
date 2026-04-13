import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> getStoredUser();
  Future<void> saveUser(User user);
  Future<void> removeUser();
  Future<User> login(String email, String password);
  Future<User> loginWithGoogle();
  Future<User> register(String email, String password, String purpose);
  Future<void> logout();
}
