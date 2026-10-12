import 'package:firebase_auth/firebase_auth.dart';

sealed class AuthState {
  const AuthState();
}

class InitialAuthState extends AuthState {
  const InitialAuthState();
}

class AuthenticatedState extends AuthState {
  final User user;
  const AuthenticatedState(this.user);
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class LoadingAuthState extends AuthState {
  const LoadingAuthState();
}

class ErrorAuthState extends AuthState {
  final String message;
  const ErrorAuthState(this.message);
}
