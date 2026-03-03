import 'package:circlo_app/core/network/api_client.dart';
import 'package:circlo_app/features/bio/models/bio_model.dart';
import 'package:dio/dio.dart';

class BioRepository {
  final Dio _dio = DioClient().dio;

  Future<BioModel> createBio({
    String? bio,
    String? location,
    String? website,
  }) async {
    final response = await _dio.post(
      '/api/auth/create-bio',
      data: {
        if (bio != null) 'bio': bio,
        if (location != null) 'location': location,
        if (website != null) 'website': website,
      },
    );
    return BioModel.fromJson(response.data['bio'] as Map<String, dynamic>);
  }

  Future<BioModel> updateBio({
    String? bio,
    String? location,
    String? website,
  }) async {
    final response = await _dio.put(
      '/api/auth/update-bio',
      data: {
        if (bio != null) 'bio': bio,
        if (location != null) 'location': location,
        if (website != null) 'website': website,
      },
    );
    return BioModel.fromJson(response.data['bio'] as Map<String, dynamic>);
  }
}
