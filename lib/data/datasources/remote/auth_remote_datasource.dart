import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<User?> signInWithGoogle();
  Future<User?> signInAsGuest();
  Future<void> signOut();
  User? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn =
           googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']);

  @override
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Token Google tidak tersedia.');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<User?> signInAsGuest() async {
    try {
      final result = await _firebaseAuth.signInAnonymously();
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_googleSignIn.signOut(), _firebaseAuth.signOut()]);
  }

  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;
}

String _mapFirebaseError(String code) {
  switch (code) {
    case 'account-exists-with-different-credential':
      return 'account-exists';
    case 'network-request-failed':
      return 'network';
    case 'sign_in_cancelled':
    case 'sign_in_failed':
      return code;
    default:
      return 'Login gagal: $code';
  }
}
