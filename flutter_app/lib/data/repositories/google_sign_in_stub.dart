class GoogleSignIn {
  const GoogleSignIn();
  Future<dynamic> signIn() async => null;
  Future<void> signOut() async {}
}

class GoogleSignInAccount {
  Future<dynamic> get authentication => throw UnimplementedError();
}

class GoogleSignInAuthentication {
  String? get accessToken => null;
  String? get idToken => null;
}

dynamic createGoogleSignInInstance() => const GoogleSignIn();
