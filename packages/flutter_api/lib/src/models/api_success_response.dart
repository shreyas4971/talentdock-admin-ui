class ApiSuccessResponse {
  final bool success;
  final String requestId;
  final String message;
  final Map<String, dynamic> data;

  ApiSuccessResponse({
    required this.success,
    required this.requestId,
    required this.message,
    required this.data,
  });

  factory ApiSuccessResponse.fromJson(Map<String, dynamic> json) {
    return ApiSuccessResponse(
      success: json['success'] as bool,
      requestId: json['requestId'] as String,
      message: json['message'] ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }
}
