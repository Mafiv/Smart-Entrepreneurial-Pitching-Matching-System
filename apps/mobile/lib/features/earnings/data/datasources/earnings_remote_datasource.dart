import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/mock/mock_backend.dart';
import '../../../../core/network/dio_client.dart';

abstract class EarningsRemoteDataSource {
  Future<Map<String, dynamic>> getEntrepreneurSummary();
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final DioClient _dio;

  EarningsRemoteDataSourceImpl({required DioClient dioClient}) : _dio = dioClient;

  @override
  Future<Map<String, dynamic>> getEntrepreneurSummary() async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(ApiConfig.mockLatency);
      return MockBackend.getEntrepreneurSummary();
    }
    try {
      final res = await _dio.get(ApiConfig.entrepreneurSummary);
      if (res.statusCode == 200) {
        return res.data as Map<String, dynamic>;
      }
      throw ServerFailure(message: 'Failed (HTTP ${res.statusCode})');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        throw const AuthFailure(message: 'Not authorized');
      }
      final data = e.response?.data;
      final msg =
          data is Map<String, dynamic> ? data['message'] as String? : null;
      throw ServerFailure(
          message: msg ?? e.message ?? 'Failed to load earnings summary');
    }
  }
}
