class GoogleSignIn {
  const GoogleSignIn();
  Future<GoogleSignInAccount?> signIn() => throw UnimplementedError();
  Future<void> signOut() => throw UnimplementedError();
}

class GoogleSignInAccount {
  Future<GoogleSignInAuthentication> get authentication => throw UnimplementedError();
}

class GoogleSignInAuthentication {
  String? get accessToken => throw UnimplementedError();
  String? get idToken => throw UnimplementedError();
}
