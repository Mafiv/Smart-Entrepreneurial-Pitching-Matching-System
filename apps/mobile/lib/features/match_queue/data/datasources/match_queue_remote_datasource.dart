import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/mock/mock_backend.dart';
import '../../../../core/network/dio_client.dart';
import '../../../matching/data/models/match_result_model.dart';

abstract class MatchQueueRemoteDataSource {
  Future<List<MatchResultModel>> list({String? status});
  Future<void> updateStatus(String matchId, String status);
}

class MatchQueueRemoteDataSourceImpl implements MatchQueueRemoteDataSource {
  final DioClient _dio;
  MatchQueueRemoteDataSourceImpl({required DioClient dioClient}) : _dio = dioClient;

  @override
  Future<List<MatchResultModel>> list({String? status}) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(ApiConfig.mockLatency);
      return MockBackend.matchQueue(status: status);
    }
    try {
      final res = await _dio.get(
        ApiConfig.matchingInvestorQueue,
        queryParameters: {if (status != null && status.isNotEmpty) 'status': status},
      );
      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        final list = (data['matches'] as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => MatchResultModel.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
      throw ServerFailure(message: 'Failed (HTTP ${res.statusCode})');
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg =
          data is Map<String, dynamic> ? data['message'] as String? : null;
      throw ServerFailure(message: msg ?? e.message ?? 'Failed to load match queue');
    }
  }

  @override
  Future<void> updateStatus(String matchId, String status) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(ApiConfig.mockLatency);
      MockBackend.updateMatchStatus(matchId, status);
      return;
    }
    try {
      final res = await _dio.patch(
        ApiConfig.matchingStatus(matchId),
        data: {'status': status},
      );
      if (res.statusCode == 200) return;
      throw ServerFailure(message: 'Failed (HTTP ${res.statusCode})');
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg =
          data is Map<String, dynamic> ? data['message'] as String? : null;
      throw ServerFailure(
          message: msg ?? e.message ?? 'Failed to update match status');
    }
  }
}

