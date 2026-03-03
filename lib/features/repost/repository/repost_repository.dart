import 'package:circlo_app/core/error/handle_dio_error.dart';
import 'package:circlo_app/core/network/api_client.dart';
import 'package:circlo_app/features/post/models/post_model.dart';
import 'package:circlo_app/features/repost/model/repost_model.dart';
import 'package:dio/dio.dart';

class RepostRepository {
  final Dio _dio = DioClient().dio;

  Future<RepostModel> toggleRepost(String postId) async {
    try {
      final response = await _dio.post('/api/repost/toggle/$postId');
      return RepostModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e, caller: 'RepostRepository.toggle');
    }
  }

  /// Returns the reposted posts.
  /// Backend: GET /api/repost/get-reposts
  /// Response: { reposts: [{ id, postId, userId, createdAt, post: { ...PostModel fields } }] }
  Future<List<PostModel>> getReposts() async {
    try {
      final response = await _dio.get('/api/repost/get-reposts');
      final data = response.data;
      final List<dynamic> reposts =
          (data is Map ? data['reposts'] : null) as List<dynamic>? ?? [];
      return reposts
          .where((r) => r is Map && r['post'] != null)
          .map((r) => PostModel.fromJson(r['post'] as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e, caller: 'RepostRepository.getReposts');
    } catch (e) {
      throw Exception('Failed to load reposts: $e');
    }
  }
}
