import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

Exception handleDioError(DioException e, {String caller = 'Repository'}) {
  if (e.response == null) {
    return Exception('Network error: ${e.message}');
  }

  final statusCode = e.response!.statusCode;
  final data = e.response!.data;
  final String message;

  if (data is Map && data['message'] != null) {
    message = '${data['message']} (HTTP $statusCode)';
  } else {
    message = 'Server error (HTTP $statusCode): ${e.message}';
  }

  debugPrint('$caller DioError [$statusCode]: $data');
  return Exception(message);
}
