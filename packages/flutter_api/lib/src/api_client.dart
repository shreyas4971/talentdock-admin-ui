import 'package:dio/dio.dart';
import 'models/position.dart';
import 'models/api_success_response.dart';

class TalentApiClient {
  final Dio _dio;

  TalentApiClient(this._dio);

  Future<ApiSuccessResponse> publishPosition(String id) async {
    final response = await _dio.post('/positions/$id/publish');
    return ApiSuccessResponse.fromJson(response.data);
  }
}
