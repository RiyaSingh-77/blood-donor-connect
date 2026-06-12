import 'package:firebase_auth/firebase_auth.dart';

// AuthService handles ONLY Firebase Authentication calls.
// It does NOT know about Firestore or UserModel — that's FirestoreService's job.
// This separation makes testing and future changes much easier.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // The currently signed-in Firebase user (null if not logged in)
  User? get currentUser => _auth.currentUser;

  // Stream that emits whenever auth state changes (login / logout)
  // main.dart listens to this to decide which screen to show
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email + password
  // Returns the Firebase User on success, throws FirebaseAuthException on failure
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return result.user;
  }

  // Create a new Firebase Auth account
  Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return result.user;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send a password reset email
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
