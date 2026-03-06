import 'package:circlo_app/core/network/api_client.dart';
import 'package:circlo_app/features/follow/model/follow_user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class FollowRepository {
  final Dio _dio = DioClient().dio;

  Exception _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String message;
    if (data is Map && data['message'] != null) {
      message = '${data['message']} (HTTP $statusCode)';
    } else {
      message = 'Server error (HTTP $statusCode): ${e.message}';
    }
    debugPrint('FollowRepository DioError [$statusCode]: $data');
    return Exception(message);
  }

  Future<void> followUnfollowUser(String userId) async {
    try {
      await _dio.post("/api/follow/follow/$userId");
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FollowResponseModel> getFollowers(String userId) async {
    try {
      final response = await _dio.get("/api/follow/followers/$userId");
      return FollowResponseModel.fromJson(
        response.data as Map<String, dynamic>,
        'followers',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FollowResponseModel> getFollowing(String userId) async {
    try {
      final response = await _dio.get("/api/follow/following/$userId");
      return FollowResponseModel.fromJson(
        response.data as Map<String, dynamic>,
        'following',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
