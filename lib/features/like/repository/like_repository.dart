import 'package:circlo_app/core/error/handle_dio_error.dart';
import 'package:circlo_app/core/network/api_client.dart';
import 'package:circlo_app/features/like/model/like_model.dart';
import 'package:dio/dio.dart';

class LikeRepository {
  final Dio _dio = DioClient().dio;

  Future<LikeModel> toggleLike(String id) async {
    try {
      final response = await _dio.post('/api/like/toggle/$id');
      return LikeModel.fromJson(response.data);
    } on DioException catch (e) {
      throw handleDioError(e, caller: 'LikeRepository');
    }
  }
}