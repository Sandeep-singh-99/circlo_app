import 'package:circlo_app/features/auth/models/auth_model.dart';

abstract class AuthState {}

class AuthStateInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthModel user;

  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}
