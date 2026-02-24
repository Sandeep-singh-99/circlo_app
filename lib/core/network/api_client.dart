import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
            debugPrint(
              "🔑 [TOKEN: SET] ${token.substring(0, token.length.clamp(0, 20))}...",
            );
          } else {
            debugPrint(
              "🚫 [TOKEN: NULL] No token in storage — request to ${options.path} will likely fail with 401",
            );
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          debugPrint(
            "❌ [API ERROR] ${e.requestOptions.method} ${e.requestOptions.path}",
          );
          debugPrint("   Status: ${e.response?.statusCode}");
          debugPrint("   Body:   ${e.response?.data}");
          return handler.next(e);
        },
      ),
    );

    // Print full request + response in debug builds
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          error: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
  }
}

// Global instance for easy access
final api = DioClient().dio;
