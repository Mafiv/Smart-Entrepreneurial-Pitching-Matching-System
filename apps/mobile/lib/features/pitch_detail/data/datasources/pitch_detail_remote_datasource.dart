import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/mock/mock_backend.dart';
import '../../../../core/network/dio_client.dart';
import '../models/pitch_detail_model.dart';

abstract class PitchDetailRemoteDataSource {
  Future<PitchDetailModel> getPitchDetail(String pitchId);
  Future<bool> toggleSavedPitch(String pitchId);
  Future<bool> isPitchSaved(String pitchId);
}

class PitchDetailRemoteDataSourceImpl implements PitchDetailRemoteDataSource {
  final DioClient _dio;

  PitchDetailRemoteDataSourceImpl({required DioClient dioClient})
      : _dio = dioClient;

  @override
  Future<PitchDetailModel> getPitchDetail(String pitchId) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(ApiConfig.mockLatency);
      final pitch = MockBackend.getSubmissionById(pitchId);
      // Convert SubmissionModel to PitchDetailModel
      final json = pitch.toJson();
      return PitchDetailModel.fromJson(json);
    }

    try {
      final res = await _dio.get('${ApiConfig.submissions}/$pitchId');
      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        final pitchData = data['submission'] ?? data['data'] ?? data;
        return PitchDetailModel.fromJson(pitchData as Map<String, dynamic>);
      }
      throw ServerFailure(message: 'Failed (HTTP ${res.statusCode})');
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg =
          (data is Map ? data['message'] : null) as String? ?? 'Network error';
      throw ServerFailure(message: msg);
    } catch (e) {
      throw ServerFailure(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<bool> toggleSavedPitch(String pitchId) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(ApiConfig.mockLatency);
      // Mock: always return true (saved)
      return true;
    }

    try {
      final res = await _dio.post(
        '${ApiConfig.investorSavedPitches}/$pitchId',
      );
      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        return (data['isSaved'] ?? data['is_saved'] ?? false) as bool;
      }
      throw ServerFailure(message: 'Failed (HTTP ${res.statusCode})');
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg =
          (data is Map ? data['message'] : null) as String? ?? 'Network error';
      throw ServerFailure(message: msg);
    } catch (e) {
      throw ServerFailure(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<bool> isPitchSaved(String pitchId) async {
    if (ApiConfig.useMockData) {
      await Future<void>.delayed(ApiConfig.mockLatency);
      // Mock: check in mock saved list
      return false;
    }

    try {
      // Fetch saved pitches and check if this one is in the list
      final res = await _dio.get(ApiConfig.investorSavedPitches);
      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        final savedPitches =
            (data['data'] ?? data['savedPitches'] ?? []) as List?;
        if (savedPitches == null) return false;

        final savedIds = savedPitches
            .whereType<Map<String, dynamic>>()
            .map((p) => (p['_id'] ?? p['id']) as String)
            .toList();

        return savedIds.contains(pitchId);
      }
      throw ServerFailure(message: 'Failed (HTTP ${res.statusCode})');
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg =
          (data is Map ? data['message'] : null) as String? ?? 'Network error';
      throw ServerFailure(message: msg);
    } catch (e) {
      throw ServerFailure(message: 'Unexpected error: $e');
    }
  }
}
