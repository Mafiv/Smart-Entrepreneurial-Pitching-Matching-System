import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/pitch_detail_entity.dart';
import '../../domain/repositories/pitch_detail_repository.dart';
import '../datasources/pitch_detail_remote_datasource.dart';

class PitchDetailRepositoryImpl implements PitchDetailRepository {
  final PitchDetailRemoteDataSource _remoteDataSource;

  PitchDetailRepositoryImpl(
      {required PitchDetailRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, PitchDetailEntity>> getPitchDetail(
      String pitchId) async {
    try {
      final result = await _remoteDataSource.getPitchDetail(pitchId);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleSavedPitch(String pitchId) async {
    try {
      final result = await _remoteDataSource.toggleSavedPitch(pitchId);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isPitchSaved(String pitchId) async {
    try {
      final result = await _remoteDataSource.isPitchSaved(pitchId);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
