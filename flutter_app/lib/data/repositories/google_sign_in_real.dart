import 'package:flutter/foundation.dart';

// We temporary remove the real import to allow Windows compilation
// import 'package:google_sign_in/google_sign_in.dart' as real;

dynamic createGoogleSignInInstance() {
  // Return null for now to allow compilation on all platforms (Windows/Mobile)
  // Google Sign-In logic will fall back to Firebase Popup on Web/Windows
  // and will be temporarily disabled on Mobile until platform-specific files are refined.
  return null;
}
