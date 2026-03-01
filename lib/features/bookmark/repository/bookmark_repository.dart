import 'package:circlo_app/core/error/handle_dio_error.dart';
import 'package:circlo_app/core/network/api_client.dart';
import 'package:circlo_app/features/bookmark/models/bookmark_model.dart';
import 'package:dio/dio.dart';

class BookmarkRepository {
  final Dio _dio = DioClient().dio;

  Future<BookmarkModel> toggleBookmark(String id) async {
    try {
      final response = await _dio.post('/api/bookmark/toggle/$id');
      return BookmarkModel.fromJson(response.data);
    } on DioException catch (e) {
      throw handleDioError(e, caller: 'BookmarkRepository');
    }
  }
}
