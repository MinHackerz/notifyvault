import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Repository for Firebase Authentication with Google Sign-In.
class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase user.
  User? get currentUser => _auth.currentUser;

  /// Whether the user is signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// Get the current user model.
  UserModel? get currentUserModel {
    final user = _auth.currentUser;
    if (user == null) return null;

    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime,
    );
  }

  /// Sign in with Google.
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) return null;

      return UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        createdAt: user.metadata.creationTime,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out from both Firebase and Google.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Delete the user account.
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
    await _googleSignIn.signOut();
  }
}
