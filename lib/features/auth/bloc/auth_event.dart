import 'dart:io';

abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({required this.email, required this.password});
}

class AuthSignupRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final File? image;

  AuthSignupRequested({required this.name, required this.email, required this.password, this.image});
}


class AuthLogoutRequested extends AuthEvent {}
