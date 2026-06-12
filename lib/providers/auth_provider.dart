import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

// What state can auth be in?
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

// AuthProvider is the "brain" for authentication in the whole app.
// Any widget that needs to know "is the user logged in?" or "who is the user?"
// just does: context.watch<AuthProvider>()
//
// It uses TWO services:
//   AuthService     → talks to Firebase Auth (login, signup, logout)
//   FirestoreService → talks to Firestore (save/load user profile)
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _userModel;   // the full profile (name, bloodGroup, city, etc.)
  String? _errorMessage;

  // Getters — widgets read these to build their UI
  AuthStatus get status => _status;
  UserModel? get userModel => _userModel;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Called once in main.dart to check if user was already logged in
  Future<void> checkAuthState() async {
    final user = _authService.currentUser;
    if (user != null) {
      await _loadUserProfile(user.uid);
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // LOGIN
  // Called when user taps "Login" on LoginScreen
  Future<bool> signIn(String email, String password) async {
    _setLoading();
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        await _loadUserProfile(user.uid);
        return true;
      }
      _setError('Login failed. Please try again.');
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyAuthError(e.code));
      return false;
    } catch (e) {
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  // SIGNUP
  // Called when user taps "Create Account" on SignupScreen
  // Takes the full UserModel so we can save it to Firestore
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String bloodGroup,
    required String city,
  }) async {
    _setLoading();
    try {
      final user = await _authService.signUp(email, password);
      if (user != null) {
        // Create the full user profile in Firestore
        final newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          phone: phone,
          bloodGroup: bloodGroup,
          city: city,
          isAvailable: true,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUser(newUser);
        _userModel = newUser;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _setError('Signup failed. Please try again.');
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyAuthError(e.code));
      return false;
    } catch (e) {
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Update availability toggle on profile screen
  Future<void> updateAvailability(bool isAvailable) async {
    if (_userModel == null) return;
    await _firestoreService.updateUser(_userModel!.uid, {'isAvailable': isAvailable});
    _userModel = _userModel!.copyWith(isAvailable: isAvailable);
    notifyListeners();
  }

  // Reload user profile from Firestore (e.g., after editing profile)
  Future<void> refreshProfile() async {
    if (_userModel == null) return;
    await _loadUserProfile(_userModel!.uid);
  }

  // ── Private helpers ──────────────────────────────────────────────

  Future<void> _loadUserProfile(String uid) async {
    final user = await _firestoreService.getUser(uid);
    if (user != null) {
      _userModel = user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  // Convert Firebase error codes into human-readable messages
  String _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':       return 'No account found with this email.';
      case 'wrong-password':       return 'Incorrect password. Please try again.';
      case 'email-already-in-use': return 'This email is already registered.';
      case 'weak-password':        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':        return 'Please enter a valid email address.';
      case 'too-many-requests':    return 'Too many attempts. Please wait a moment.';
      default:                     return 'Authentication failed. Please try again.';
    }
  }
}
