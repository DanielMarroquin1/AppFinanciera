/// Stub implementation for platforms where google_sign_in is not available (Web)
class _StubGoogleSignIn {
  Future<void> initialize() async {}
  Future<dynamic> authenticate() async => null;
  Future<void> signOut() async {}
}

dynamic createGoogleSignInInstance() => _StubGoogleSignIn();
