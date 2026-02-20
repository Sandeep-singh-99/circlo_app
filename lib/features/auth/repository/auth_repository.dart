import 'dart:io';

import 'package:circlo_app/core/network/api_client.dart';
import 'package:circlo_app/features/auth/models/auth_model.dart';
import 'package:circlo_app/features/auth/models/auth_response_model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {"email": email, "password": password},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> signup({
    required String name,
    required String email,
    required String password,
    File? image,
  }) async {
    FormData formData = FormData.fromMap({
      "name": name,
      "email": email,
      "password": password,
    });

    if (image != null) {
      formData.files.add(
        MapEntry(
          "image",
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split("/").last,
          ),
        ),
      );
    }

    final response = await _dio.post("/api/auth/register", data: formData);
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthModel> getMe() async {
    final response = await _dio.get("/api/auth/profile");
    return AuthModel.fromJson(response.data['user']);
  }
}
