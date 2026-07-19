import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'http://localhost:3000/api/v1'));
});

String getFriendlyErrorMessage(dynamic e) {
  if (e is DioException) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
      return 'Network unavailable. Please check your connection.';
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return 'Login failed or session expired.';
    if (statusCode == 400) return 'Validation error. Please check your inputs.';
    if (statusCode == 500) return 'Server error. Our team has been notified.';
    return e.response?.data?['message'] ?? 'An unexpected server error occurred.';
  }
  return 'An unexpected error occurred.';
}
