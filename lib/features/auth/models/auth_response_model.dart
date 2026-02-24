import 'package:circlo_app/features/auth/models/auth_model.dart';

final class AuthResponseModel {
  final String token;
  final AuthModel user;

  AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception(
        'Login succeeded but no token was returned. '
        'Server response: $json',
      );
    }
    return AuthResponseModel(
      token: token,
      user: AuthModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
