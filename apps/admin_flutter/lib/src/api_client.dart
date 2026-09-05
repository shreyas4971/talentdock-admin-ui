import 'dart:typed_data';
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

class AuthUserNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;
  void setUser(Map<String, dynamic>? user) => state = user;
}

final authUserProvider = NotifierProvider<AuthUserNotifier, Map<String, dynamic>?>(AuthUserNotifier.new);

final dioProvider = Provider<Dio>((ref) {
  final token = ref.watch(authTokenProvider);
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
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
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (isMockMode) {
      return {
        'token': 'mock_admin_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'usr-admin-default',
          'email': email.isNotEmpty ? email : 'admin@talentdock.local',
          'name': 'TalentDock Admin',
          'role': 'ADMIN',
        },
      };
    }

    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    throw Exception(response.data?['message'] ?? 'Login failed');
  }

  /// List All Positions
  Future<List<Map<String, dynamic>>> getPositions() async {
    if (isMockMode) return mockPositions;
    final response = await _dio.get('/positions');
    if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
      final List<dynamic> list = response.data['data'] ?? [];
      return list.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    throw Exception(response.data?['message'] ?? 'Failed to fetch positions');
  }

  /// Get Position by ID
  Future<Map<String, dynamic>?> getPositionById(String id) async {
    if (isMockMode) {
      return mockPositions.cast<Map<String, dynamic>?>().firstWhere(
        (p) => p?['id'] == id,
        orElse: () => null,
      );
    }
    final response = await _dio.get('/positions/$id');
    if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    return null;
  }

  /// Create Position
  Future<Map<String, dynamic>> createPosition(Map<String, dynamic> positionData) async {
    if (isMockMode) return positionData;
    final response = await _dio.post('/positions', data: positionData);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null &&
        response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    }
    throw Exception(response.data?['message'] ?? 'Failed to create position');
  }

  /// Update Position
  Future<Map<String, dynamic>> updatePosition(String id, Map<String, dynamic> updates) async {
    if (isMockMode) return updates;
    final response = await _dio.put('/positions/$id', data: updates);
    if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data'] ?? updates);
    }
    throw Exception(response.data?['message'] ?? 'Failed to update position');
  }

  /// Delete / Remove Position
  Future<void> deletePosition(String id) async {
    if (isMockMode) return;
    final response = await _dio.delete('/positions/$id');
    if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
      return;
    }
    throw Exception(response.data?['message'] ?? 'Failed to delete position');
  }

  /// List Candidates (with search/filter)
  Future<List<Map<String, dynamic>>> getCandidates({String? search, String? status, String? positionId}) async {
    if (isMockMode) return mockCandidates;
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty && status != 'All Statuses') queryParams['status'] = status;
    if (positionId != null && positionId.isNotEmpty && positionId != 'All Positions') queryParams['positionId'] = positionId;

    final response = await _dio.get('/candidates', queryParameters: queryParams);
    if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
      final List<dynamic> list = response.data['data'] ?? [];
      return list.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    throw Exception(response.data?['message'] ?? 'Failed to fetch candidates');
  }

  /// Candidate Details
  Future<Map<String, dynamic>> getCandidateDetails(String id) async {
    if (isMockMode) {
      final mock = mockCandidates.firstWhere((c) => c['id'] == id, orElse: () => mockCandidates.first);
      return {
        'candidate': {
          'id': mock['id'],
          'firstName': mock['name']?.toString().split(' ').first ?? 'Candidate',
          'lastName': mock['name']?.toString().split(' ').skip(1).join(' ') ?? 'User',
          'email': mock['email'] ?? 'candidate@example.com',
          'phone': mock['phone'] ?? '+1 555-0198',
          'city': mock['location'] ?? 'Chicago',
          'state': 'IL',
          'totalExperience': mock['experience'] ?? '3 Years',
          'currentCompany': 'TechCorp',
          'currentDesignation': 'Software Engineer',
          'expectedSalary': '\$120,000',
          'noticePeriod': mock['notice'] ?? '30 Days',
        },
        'application': {
          'id': mock['id'],
          'referenceId': mock['referenceId'] ?? 'REC-2026-000001',
          'status': mock['status'] ?? 'APPLIED',
        },
        'position': {
          'title': mock['position'] ?? 'Software Developer',
          'department': 'Engineering',
        },
        'documents': [
          {
            'id': 'doc-mock-1',
            'fileName': 'resume.pdf',
            'fileSize': 1024 * 450,
          }
        ],
        'notes': [
          {
            'id': 'note-1',
            'authorId': 'Admin',
            'content': 'Strong technical background.',
            'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          }
        ],
        'timeline': [
          {
            'id': 'tl-1',
            'eventType': 'APPLICATION_SUBMITTED',
            'description': 'Application submitted',
            'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          }
        ],
      };
    }

    final response = await _dio.get('/candidates/$id');
    if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    throw Exception(response.data?['message'] ?? 'Failed to fetch candidate details');
  }

  /// Update Candidate Status
  Future<bool> updateCandidateStatus(String id, String newStatus) async {
    if (isMockMode) return true;
    final response = await _dio.put('/candidates/$id/status', data: {'status': newStatus});
    if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
      return true;
    }
    throw Exception(response.data?['message'] ?? 'Failed to update candidate status');
  }

  /// Add Candidate Note
  Future<Map<String, dynamic>> addCandidateNote(String id, String content) async {
    if (isMockMode) {
      return {
        'id': 'note-${DateTime.now().millisecondsSinceEpoch}',
        'candidateId': id,
        'content': content,
        'createdAt': DateTime.now().toIso8601String(),
      };
    }
    final response = await _dio.post('/candidates/$id/notes', data: {'content': content});
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null &&
        response.data['success'] == true) {
      return Map<String, dynamic>.from(response.data['data'] ?? {});
    }
    throw Exception(response.data?['message'] ?? 'Failed to add note');
  }

  /// Download Resume Bytes from R2 via Worker
  Future<Uint8List> downloadResumeBytes(String candidateOrAppId) async {
    if (isMockMode) {
      return Uint8List.fromList([37, 80, 68, 70, 45]); // %PDF-
    }
    final response = await _dio.get<List<int>>(
      '/candidates/$candidateOrAppId/resume',
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.statusCode == 200 && response.data != null) {
      return Uint8List.fromList(response.data!);
    }
    throw Exception('Failed to download resume from storage');
  }
}

String getFriendlyErrorMessage(dynamic e) {
  if (e is DioException) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
      return 'Network unavailable. Please check your connection.';
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return 'Invalid email or password.';
    if (statusCode == 400) return e.response?.data?['message'] ?? 'Validation error. Please check your inputs.';
    if (statusCode == 404) return e.response?.data?['message'] ?? 'Requested resource was not found.';
    if (statusCode == 500) return 'Server error. Our team has been notified.';
    return e.response?.data?['message'] ?? 'An unexpected server error occurred.';
  }
  if (e is Exception) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      return msg.substring(11);
    }
    return msg;
  }
  return 'An unexpected error occurred.';
}

