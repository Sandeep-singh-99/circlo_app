import 'dart:io';

import 'package:circlo_app/core/network/api_client.dart';
import 'package:circlo_app/features/post/models/post_response_model.dart';
import 'package:dio/dio.dart';

class PostRepository {
  final Dio _dio = DioClient().dio;

  Future<PostResponseModel> createPost(String content, File? image) async {
    FormData formData = FormData.fromMap({
      "content": content,
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
    final response = await _dio.post("/api/post/create-post", 
    data: formData);
    return PostResponseModel.fromJson(response.data);
  }


  Future<PostResponseModel> getPost() async {
    final response = await _dio.get("/api/post/get-all-posts");
    return PostResponseModel.fromJson(response.data);
  }

  Future<PostResponseModel> deletePost(String id) async {
    final response = await _dio.delete("/api/post/delete/$id");
    return PostResponseModel.fromJson(response.data);
  }

  Future<PostResponseModel> getPostById(String id) async {
    final response = await _dio.get("/api/post/get-post-byID/$id");
    return PostResponseModel.fromJson(response.data);
  }
}