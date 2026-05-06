import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences prefs;
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthRepositoryImpl(this.prefs);

  @override
  Future<User?> getStoredUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      await firebaseUser.reload();
      final updatedUser = _firebaseAuth.currentUser;
      
      if (updatedUser != null && updatedUser.emailVerified) {
         try {
           final doc = await _firestore.collection('users').doc(updatedUser.uid).get();
           if (doc.exists) {
             final map = doc.data()!;
             return User(
               email: updatedUser.email ?? '',
               name: map['name'] ?? '',
               purpose: map['purpose'] ?? '',
               hasCompletedTour: map['hasCompletedTour'] ?? false,
               profileComplete: map['profileComplete'] ?? false,
               country: map['country'],
               currency: map['currency'],
               salary: map['salary'],
               salaryType: map['salaryType'],
             );
           }
         } catch (e) {
           print("Error fetching user from Firestore: $e");
         }
      }
    }
    return null;
  }

  @override
  Future<void> saveUser(User user) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      final map = {
        'email': user.email,
        'name': user.name,
        'purpose': user.purpose,
        'hasCompletedTour': user.hasCompletedTour,
        'profileComplete': user.profileComplete,
        if (user.country != null) 'country': user.country,
        if (user.currency != null) 'currency': user.currency,
        if (user.salary != null) 'salary': user.salary,
        if (user.salaryType != null) 'salaryType': user.salaryType,
      };
      await _firestore.collection('users').doc(firebaseUser.uid).set(map, SetOptions(merge: true));
    }
  }

  @override
  Future<void> removeUser() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<User> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    
    if (user != null && !user.emailVerified) {
      throw firebase_auth.FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Por favor verifica tu correo electrónico antes de iniciar sesión.',
      );
    }
    
    final storedUser = await getStoredUser();
    if (storedUser != null) {
      return storedUser;
    }
    
    final fallbackUser = User(
      email: email,
      name: email.split('@').first,
      purpose: "Finanzas",
      hasCompletedTour: false,
      profileComplete: false,
    );
    await saveUser(fallbackUser);
    return fallbackUser;
  }

  @override
  Future<User> loginWithGoogle() async {
    try {
      firebase_auth.UserCredential userCredential;
      
      // On Web, we can safely use signInWithPopup.
      userCredential = await _firebaseAuth.signInWithPopup(firebase_auth.GoogleAuthProvider());

      final firebaseUser = userCredential.user!;
      
      // Verifica si existe en Firestore
      final docSnapshot = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!docSnapshot.exists) {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'email': firebaseUser.email,
          'name': firebaseUser.displayName ?? '',
          'purpose': '',
          'profileComplete': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return User(
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? '',
          purpose: '',
          hasCompletedTour: false,
          profileComplete: false,
        );
      }
      
      final data = docSnapshot.data()!;
      return User(
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        purpose: data['purpose'] ?? '',
        hasCompletedTour: data['hasCompletedTour'] ?? false,
        profileComplete: data['profileComplete'] ?? false,
      );
    } catch (e) {
      if (e is firebase_auth.FirebaseAuthException) rethrow;
      throw firebase_auth.FirebaseAuthException(code: 'unknown', message: e.toString());
    }
  }

  @override
  Future<User> register(String email, String password, String purpose) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    
    final user = User(
      email: email,
      name: email.split('@').first,
      purpose: purpose,
      hasCompletedTour: false,
      profileComplete: false,
    );
    
    await saveUser(user);
    await credential.user?.sendEmailVerification();
    
    throw firebase_auth.FirebaseAuthException(
      code: 'email-not-verified-registered',
      message: 'Te hemos enviado un correo de verificación. Por favor revisa tu bandeja de entrada.',
    );
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
