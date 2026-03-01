import 'package:circlo_app/core/error/handle_dio_error.dart';
import 'package:circlo_app/core/network/api_client.dart';
import 'package:circlo_app/features/comment/model/comment_model.dart';
import 'package:dio/dio.dart';

class CommentRepository {
  final Dio _dio = DioClient().dio;

  Future<CommentModel> addComment(String postId, String content) async {
    try {
      final response = await _dio.post(
        '/api/comment/$postId',
        data: {'content': content},
      );
      return CommentModel.fromJson(
        response.data['comment'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw handleDioError(e, caller: 'CommentRepository');
    }
  }

  Future<String> deleteComment(String id) async {
    try {
      final response = await _dio.delete('/api/comment/$id');
      return response.data['message'] as String;
    } on DioException catch (e) {
      throw handleDioError(e, caller: 'CommentRepository');
    }
  }

  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final response = await _dio.get('/api/comment/$postId');
      return (response.data as List)
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e, caller: 'CommentRepository');
    }
  }

  Future<CommentModel> updateComment(String id, String content) async {
    try {
      final response = await _dio.put(
        '/api/comment/$id',
        data: {'content': content},
      );
      return CommentModel.fromJson(
        response.data['updatedComment'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw handleDioError(e, caller: 'CommentRepository');
    }
  }
}
