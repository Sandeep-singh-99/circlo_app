import 'dart:io';

import 'package:circlo_app/core/network/api_client.dart';
import 'package:circlo_app/features/post/models/post_response_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PostRepository {
  final Dio _dio = DioClient().dio;

  /// Extracts a readable message from a [DioException].
  Exception _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String message;
    if (data is Map && data['message'] != null) {
      message = '${data['message']} (HTTP $statusCode)';
    } else {
      message = 'Server error (HTTP $statusCode): ${e.message}';
    }
    debugPrint('PostRepository DioError [$statusCode]: $data');
    return Exception(message);
  }

  Future<PostResponseModel> createPost(String content, File? image) async {
    try {
      final formData = FormData.fromMap({"content": content});
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
      final response = await _dio.post("/api/post/create-post", data: formData);
      return PostResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PostResponseModel> getPost() async {
    try {
      final response = await _dio.get("/api/post/get-all-posts");
      return PostResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PostResponseModel> deletePost(String id) async {
    try {
      final response = await _dio.delete("/api/post/delete/$id");
      return PostResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PostResponseModel> getPostById(String id) async {
    try {
      final response = await _dio.get("/api/post/get-post-byID/$id");
      return PostResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PostResponseModel> getOwnPosts() async {
    try {
      final response = await _dio.get("/api/post/get-own-posts");
      return PostResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
