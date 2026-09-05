import 'dart:convert';
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
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
});

final candidateApiClientProvider = Provider<CandidateApiClient>((ref) {
  return CandidateApiClient(ref.watch(dioProvider));
});

class CandidateApiClient {
  final Dio _dio;
  CandidateApiClient(this._dio);

  bool get isMockMode => _dio.options.baseUrl.isEmpty;

  /// Fetch public published positions (with mock fallback ONLY in standalone mock mode)
  Future<List<Map<String, dynamic>>> getPublicPositions() async {
    if (isMockMode) return mockPositions;
    final response = await _dio.get('/positions/public');
    if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
      final List<dynamic> list = response.data['data'] ?? [];
      return list.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    throw Exception(response.data?['message'] ?? 'Failed to fetch public positions');
  }

  /// Fetch position details by ID (with mock fallback ONLY in standalone mock mode)
  Future<Map<String, dynamic>?> getPositionById(String id) async {
    if (isMockMode) {
      return mockPositions.cast<Map<String, dynamic>?>().firstWhere(
        (p) => p?['id'] == id,
        orElse: () => null,
      );
    }
    try {
      final response = await _dio.get('/positions/$id');
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
    return null;
  }

  /// Checks whether an application already exists for this position and candidate email.
  Future<bool> checkAlreadyApplied({
    required String positionId,
    required String email,
  }) async {
    if (isMockMode) return false;
    try {
      final response = await _dio.get('/applications/check', queryParameters: {
        'positionId': positionId,
        'email': email.trim().toLowerCase(),
      });
      if (response.statusCode == 409 || response.data?['alreadyApplied'] == true) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return true;
      }
      rethrow;
    }
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

    if (resumeFile.bytes == null || resumeFile.bytes!.isEmpty) {
      throw Exception('Resume file content is missing or unreadable. Please select your PDF resume again.');
    }

    final formData = FormData();

    // Form text fields
    formData.fields.addAll([
      MapEntry('positionId', positionId),
      MapEntry('firstName', firstName.trim()),
      MapEntry('lastName', lastName.trim()),
      MapEntry('email', email.trim()),
      if (phone != null && phone.trim().isNotEmpty) MapEntry('phone', phone.trim()),
      if (city != null && city.trim().isNotEmpty) MapEntry('city', city.trim()),
      if (state != null && state.trim().isNotEmpty) MapEntry('state', state.trim()),
      if (dob != null && dob.trim().isNotEmpty) MapEntry('dob', dob.trim()),
      if (highestEducation != null && highestEducation.trim().isNotEmpty) MapEntry('highestEducation', highestEducation.trim()),
      if (empStatus != null && empStatus.trim().isNotEmpty) MapEntry('empStatus', empStatus.trim()),
      if (totalExp != null && totalExp.trim().isNotEmpty) MapEntry('totalExp', totalExp.trim()),
      if (currentCompany != null && currentCompany.trim().isNotEmpty) MapEntry('currentCompany', currentCompany.trim()),
      if (currentDesignation != null && currentDesignation.trim().isNotEmpty) MapEntry('currentDesignation', currentDesignation.trim()),
      if (expectedSalary != null && expectedSalary.trim().isNotEmpty) MapEntry('expectedSalary', expectedSalary.trim()),
      if (currentSalary != null && currentSalary.trim().isNotEmpty) MapEntry('currentSalary', currentSalary.trim()),
      if (noticePeriod != null && noticePeriod.trim().isNotEmpty) MapEntry('noticePeriod', noticePeriod.trim()),
      if (joiningDate != null && joiningDate.trim().isNotEmpty) MapEntry('joiningDate', joiningDate.trim()),
      if (additionalInfo != null && additionalInfo.trim().isNotEmpty) MapEntry('additionalInfo', additionalInfo.trim()),
    ]);

    final cleanFirst = firstName.trim();
    final cleanLast = lastName.trim();
    final formattedResumeName = cleanLast.isNotEmpty
        ? '$cleanFirst ${cleanLast}_Resume.pdf'
        : '${cleanFirst}_Resume.pdf';

    // Resume file attachment
    formData.files.add(MapEntry(
      'resume',
      MultipartFile.fromBytes(
        resumeFile.bytes!,
        filename: formattedResumeName,
      ),
    ));

    final response = await _dio.post('/applications', data: formData);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        response.data != null &&
        response.data['success'] == true &&
        response.data['data'] != null) {
      return Map<String, dynamic>.from(response.data['data']);
    }

    final errMsg = response.data?['message']?.toString();
    throw Exception(errMsg != null && errMsg.isNotEmpty ? errMsg : 'Unable to submit application. Please try again.');
  }
}

String getFriendlyErrorMessage(dynamic e) {
  if (e is DioException) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Network timeout. Please check your connection and try again.';
    }

    dynamic responseData = e.response?.data;
    if (responseData is String && responseData.isNotEmpty) {
      try {
        responseData = jsonDecode(responseData);
      } catch (_) {}
    }

    if (responseData is Map && responseData['message'] != null && responseData['message'].toString().isNotEmpty) {
      return responseData['message'].toString();
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 400) return 'Validation error. Please check your inputs and resume file.';
    if (statusCode == 401) return 'Session expired or unauthorized.';
    if (statusCode == 404) return 'Position not found or application window closed.';
    if (statusCode == 409) return 'You have already applied for this position.';
    if (statusCode == 413) return 'Resume file size exceeds the 2 MB limit.';
    if (statusCode == 500) return 'Server error. Our team has been notified.';

    return e.message ?? 'Unable to submit application. Please try again.';
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
