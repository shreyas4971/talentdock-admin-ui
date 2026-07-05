import 'package:dio/dio.dart';

class SecureStorage {
  Future<String?> getToken() async {
    // Implementation placeholder for flutter_secure_storage
    return 'mock_token';
  }
  
  Future<void> clear() async {}
}

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Trigger token refresh or logout logic here
    }
    super.onError(err, handler);
  }
}
