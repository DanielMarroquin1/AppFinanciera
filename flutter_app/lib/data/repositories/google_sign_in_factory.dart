import 'package:flutter/foundation.dart';
import 'google_sign_in_stub.dart' if (dart.library.io) 'google_sign_in_real.dart';

dynamic createSafeGoogleSignIn() {
  // This function is defined in both stub and real files via conditional export/import
  return createGoogleSignInInstance();
}
