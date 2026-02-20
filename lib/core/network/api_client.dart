import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class DioClient {
  final Dio dio = Dio();
  final SecureStorageService _storage = SecureStorageService();

  DioClient() {
    dio.options.baseUrl = "https://circlo-backend-latest.onrender.com";

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
      ),
    );
  }
}
// Global instance for easy access
final api = DioClient().dio;
