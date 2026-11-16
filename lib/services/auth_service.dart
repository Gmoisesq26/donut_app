import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // Pega aquí tu Web client ID
  static const String _serverClientId =
      '304123715260-qdeubsje12et1sgvs3fop9m3ofd1pnp7.apps.googleusercontent.com';

  static bool _initialized = false;

  // En v7 hay que inicializar antes de cualquier otra llamada
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
    _initialized = true;
  }

  /// Devuelve null si el usuario cancela.
  static Future<UserCredential?> signInWithGoogle() async {
    await _ensureInitialized();
    try {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      debugPrint(
        'GoogleSignInException -> code: ${e.code}, '
        'description: ${e.description}, details: ${e.details}',
      );
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _ensureInitialized();
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
  }
}
