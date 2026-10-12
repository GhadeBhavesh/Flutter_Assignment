import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthNotifier() : super(const InitialAuthState()) {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        state = AuthenticatedState(user);
      } else {
        state = const UnauthenticatedState();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const LoadingAuthState();
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      state = ErrorAuthState(_mapAuthErrorMessage(e));
    } catch (_) {
      state = const ErrorAuthState('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = const LoadingAuthState();
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      state = ErrorAuthState(_mapAuthErrorMessage(e));
    } catch (_) {
      state = const ErrorAuthState('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      state = ErrorAuthState(_mapAuthErrorMessage(e));
    } catch (_) {
      state = const ErrorAuthState('Failed to send password reset email.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _mapAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid credentials. Please verify your email and password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
