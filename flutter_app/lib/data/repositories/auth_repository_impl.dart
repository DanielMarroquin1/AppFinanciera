import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'google_sign_in_factory.dart';
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
               language: map['language'],
               salary: map['salary'],
               salaryType: map['salaryType'],
               points: map['points'] ?? 0,
               currentStreak: map['currentStreak'] ?? 0,
               lastActiveDate: map['lastActiveDate'],
               unlockedItems: List<String>.from(map['unlockedItems'] ?? []),
               currentAvatar: map['currentAvatar'],
               monthlyLimit: map['monthlyLimit'] != null ? (map['monthlyLimit'] as num).toDouble() : null,
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
        if (user.language != null) 'language': user.language,
        if (user.salary != null) 'salary': user.salary,
        if (user.salaryType != null) 'salaryType': user.salaryType,
        'points': user.points,
        'currentStreak': user.currentStreak,
        if (user.lastActiveDate != null) 'lastActiveDate': user.lastActiveDate,
        'unlockedItems': user.unlockedItems,
        'currentAvatar': user.currentAvatar,
        'monthlyLimit': user.monthlyLimit,
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
    // Only save if it doesn't exist, to avoid overwriting existing properties with nulls
    // Since getStoredUser() returned null, we might just have unverified email,
    // but if it's actually missing we save it.
    await saveUser(fallbackUser);
    return fallbackUser;
  }

  @override
  Future<User> loginWithGoogle() async {
    try {
      firebase_auth.UserCredential userCredential;

      if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
        // On Web or Windows, use signInWithPopup (or similar Firebase flow)
        // Note: For Windows, this might still need configuration, but it prevents native package errors
        userCredential = await _firebaseAuth.signInWithPopup(firebase_auth.GoogleAuthProvider());
      } else {
        // On Android/iOS, use the GoogleSignIn package via safe factory
        final dynamic googleSignIn = createSafeGoogleSignIn();
        
        if (googleSignIn == null) {
          throw firebase_auth.FirebaseAuthException(
            code: 'unsupported-platform',
            message: 'Google Sign-In no está soportado en esta plataforma.',
          );
        }

        final dynamic googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          // User cancelled the sign-in flow
          throw firebase_auth.FirebaseAuthException(
            code: 'sign-in-cancelled',
            message: 'Inicio de sesión con Google cancelado.',
          );
        }

        final dynamic googleAuth = await googleUser.authentication;

        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }

      final firebaseUser = userCredential.user!;
      
      // Verifica si existe en Firestore
      final docSnapshot = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!docSnapshot.exists) {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'email': firebaseUser.email,
          'name': firebaseUser.displayName ?? '',
          'purpose': '',
          'profileComplete': false,
          'hasCompletedTour': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return User(
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? '',
          purpose: '',
          hasCompletedTour: false,
          profileComplete: false,
          points: 0,
          currentStreak: 0,
          unlockedItems: [],
          currentAvatar: null,
          monthlyLimit: null,
        );
      }
      
      final data = docSnapshot.data()!;
      return User(
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        purpose: data['purpose'] ?? '',
        hasCompletedTour: data['hasCompletedTour'] ?? false,
        profileComplete: data['profileComplete'] ?? false,
        country: data['country'],
        currency: data['currency'],
        language: data['language'],
        salary: data['salary'],
        salaryType: data['salaryType'],
        points: data['points'] ?? 0,
        currentStreak: data['currentStreak'] ?? 0,
        lastActiveDate: data['lastActiveDate'],
        unlockedItems: List<String>.from(data['unlockedItems'] ?? []),
        currentAvatar: data['currentAvatar'],
        monthlyLimit: data['monthlyLimit'] != null ? (data['monthlyLimit'] as num).toDouble() : null,
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
    try {
      if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows) {
        final dynamic googleSignIn = createSafeGoogleSignIn();
        if (googleSignIn != null) {
          await googleSignIn.signOut();
        }
      }
    } catch (_) {
      // Ignore errors from Google sign out
    }
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is firebase_auth.FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          throw firebase_auth.FirebaseAuthException(
            code: 'user-not-found',
            message: 'No hay ninguna cuenta registrada con este correo.',
          );
        } else if (e.code == 'invalid-email') {
          throw firebase_auth.FirebaseAuthException(
            code: 'invalid-email',
            message: 'El correo electrónico no es válido.',
          );
        }
        rethrow;
      }
      throw Exception('Ocurrió un error al enviar el enlace de recuperación.');
    }
  }
}
