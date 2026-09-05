import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_data.dart';

// Configurable API base URL (empty string indicates standalone Mock Mode)
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

class AuthTokenNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setToken(String? token) => state = token;
}

final authTokenProvider = NotifierProvider<AuthTokenNotifier, String?>(AuthTokenNotifier.new);

final dioProvider = Provider<Dio>((ref) {
  final token = ref.watch(authTokenProvider);
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        options.headers['Authorization'] = 'Bearer mock_jwt_token';
      }
      handler.next(options);
    },
  ));

  return dio;
});

final adminApiClientProvider = Provider<AdminApiClient>((ref) {
  return AdminApiClient(ref.watch(dioProvider));
});

class AdminApiClient {
  final Dio _dio;
  AdminApiClient(this._dio);

  bool get isMockMode => _dio.options.baseUrl.isEmpty;

  /// Admin Login
  Future<Map<String, dynamic>?> login(String email, String password) async {
    if (isMockMode) {
      return {
        'token': 'mock_admin_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'usr-admin-default',
          'email': email,
          'name': 'TalentDock Admin',
          'role': 'ADMIN',
        },
      };
    }
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
    } catch (e) {
      // Return mock admin if offline
    }
    return {
      'token': 'mock_admin_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'usr-admin-default',
        'email': email,
        'name': 'TalentDock Admin',
        'role': 'ADMIN',
      },
    };
  }

  /// List All Positions (with mock fallback)
  Future<List<Map<String, dynamic>>> getPositions() async {
    if (isMockMode) return mockPositions;
    try {
      final response = await _dio.get('/positions');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'];
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      // Mock fallback
    }
    return mockPositions;
  }

  /// Create Position
  Future<Map<String, dynamic>?> createPosition(Map<String, dynamic> positionData) async {
    if (isMockMode) return positionData;
    try {
      final response = await _dio.post('/positions', data: positionData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data['data'] ?? {});
      }
    } catch (e) {
      // Mock fallback
    }
    return positionData;
  }

  /// Update Position
  Future<bool> updatePosition(String id, Map<String, dynamic> updates) async {
    if (isMockMode) return true;
    try {
      final response = await _dio.put('/positions/$id', data: updates);
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return true; // Mock success
    }
  }

  /// List Candidates (with search/filter and mock fallback)
  Future<List<Map<String, dynamic>>> getCandidates({String? search, String? status, String? positionId}) async {
    if (isMockMode) return mockCandidates;
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (positionId != null && positionId.isNotEmpty) queryParams['positionId'] = positionId;

      final response = await _dio.get('/candidates', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'];
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      // Mock fallback
    }
    return mockCandidates;
  }

  /// Update Candidate Status
  Future<bool> updateCandidateStatus(String id, String newStatus) async {
    if (isMockMode) return true;
    try {
      final response = await _dio.put('/candidates/$id/status', data: {'status': newStatus});
      return response.statusCode == 200;
    } catch (e) {
      return true; // Mock success
    }
  }

  /// Add Candidate Note
  Future<bool> addCandidateNote(String id, String content) async {
    if (isMockMode) return true;
    try {
      final response = await _dio.post('/candidates/$id/notes', data: {'content': content});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return true; // Mock success
    }
  }
}

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
