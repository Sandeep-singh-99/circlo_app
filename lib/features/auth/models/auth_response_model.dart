import 'package:circlo_app/features/auth/models/auth_model.dart';

final class AuthResponseModel {
  final String token;
  final AuthModel user;

  AuthResponseModel({
    required this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'],
      user: AuthModel.fromJson(json['user']),
    );
  }
}
