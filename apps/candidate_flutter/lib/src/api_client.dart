import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'mock_data.dart';

// Configurable API base URL (empty string indicates standalone Mock Mode)
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

final candidateApiClientProvider = Provider<CandidateApiClient>((ref) {
  return CandidateApiClient(ref.watch(dioProvider));
});

class CandidateApiClient {
  final Dio _dio;
  CandidateApiClient(this._dio);

  bool get isMockMode => _dio.options.baseUrl.isEmpty;

  /// Fetch public published positions (with mock fallback for browsing)
  Future<List<Map<String, dynamic>>> getPublicPositions() async {
    if (isMockMode) return mockPositions;
    try {
      final response = await _dio.get('/positions/public');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'];
        return list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      // Graceful fallback to mock data for development browsing
    }
    return mockPositions;
  }

  /// Fetch position details by ID (with mock fallback for browsing)
  Future<Map<String, dynamic>?> getPositionById(String id) async {
    if (isMockMode) {
      return mockPositions.cast<Map<String, dynamic>?>().firstWhere(
        (p) => p?['id'] == id,
        orElse: () => null,
      );
    }
    try {
      final response = await _dio.get('/positions/$id');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
    } catch (e) {
      // Graceful fallback to mock data
    }
    return mockPositions.cast<Map<String, dynamic>?>().firstWhere(
      (p) => p?['id'] == id,
      orElse: () => null,
    );
  }

  /// Submit candidate application with resume upload.
  /// STRICT: MUST NOT fall back to a fake success ID when backend is unavailable.
  Future<Map<String, dynamic>> submitApplication({
    required String positionId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? city,
    String? state,
    String? dob,
    String? highestEducation,
    String? empStatus,
    String? totalExp,
    String? currentCompany,
    String? currentDesignation,
    String? expectedSalary,
    String? currentSalary,
    String? noticePeriod,
    String? joiningDate,
    String? additionalInfo,
    required PlatformFile resumeFile,
  }) async {
    if (isMockMode) {
      throw Exception('Backend server is not connected. Real applications require an active backend.');
    }

    final formData = FormData();

    // Form text fields
    formData.fields.addAll([
      MapEntry('positionId', positionId),
      MapEntry('firstName', firstName),
      MapEntry('lastName', lastName),
      MapEntry('email', email),
      if (phone != null && phone.isNotEmpty) MapEntry('phone', phone),
      if (city != null && city.isNotEmpty) MapEntry('city', city),
      if (state != null && state.isNotEmpty) MapEntry('state', state),
      if (dob != null && dob.isNotEmpty) MapEntry('dob', dob),
      if (highestEducation != null && highestEducation.isNotEmpty) MapEntry('highestEducation', highestEducation),
      if (empStatus != null && empStatus.isNotEmpty) MapEntry('empStatus', empStatus),
      if (totalExp != null && totalExp.isNotEmpty) MapEntry('totalExp', totalExp),
      if (currentCompany != null && currentCompany.isNotEmpty) MapEntry('currentCompany', currentCompany),
      if (currentDesignation != null && currentDesignation.isNotEmpty) MapEntry('currentDesignation', currentDesignation),
      if (expectedSalary != null && expectedSalary.isNotEmpty) MapEntry('expectedSalary', expectedSalary),
      if (currentSalary != null && currentSalary.isNotEmpty) MapEntry('currentSalary', currentSalary),
      if (noticePeriod != null && noticePeriod.isNotEmpty) MapEntry('noticePeriod', noticePeriod),
      if (joiningDate != null && joiningDate.isNotEmpty) MapEntry('joiningDate', joiningDate),
      if (additionalInfo != null && additionalInfo.isNotEmpty) MapEntry('additionalInfo', additionalInfo),
    ]);

    // Resume file attachment
    if (resumeFile.bytes != null) {
      formData.files.add(MapEntry(
        'resume',
        MultipartFile.fromBytes(resumeFile.bytes!, filename: resumeFile.name),
      ));
    }

    final response = await _dio.post('/applications', data: formData);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null &&
        response.data['success'] == true &&
        response.data['data'] != null) {
      return Map<String, dynamic>.from(response.data['data']);
    }

    throw Exception(response.data?['message'] ?? 'Unable to submit application. Please try again.');
  }
}

String getFriendlyErrorMessage(dynamic e) {
  if (e is DioException) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
      return 'Network unavailable. Unable to reach the server.';
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return 'Login failed or session expired.';
    if (statusCode == 400) return e.response?.data?['message'] ?? 'Validation error. Please check your inputs.';
    if (statusCode == 404) return 'Position not found or application window closed.';
    if (statusCode == 500) return 'Server error. Our team has been notified.';
    return e.response?.data?['message'] ?? 'Unable to submit application. Please try again.';
  }
  if (e is Exception) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      return msg.substring(11);
    }
    return msg;
  }
  return 'Unable to submit application. Please try again.';
}
