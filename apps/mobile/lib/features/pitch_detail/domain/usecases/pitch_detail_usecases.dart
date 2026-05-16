import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/pitch_detail_entity.dart';
import '../repositories/pitch_detail_repository.dart';

class GetPitchDetailUseCase {
  final PitchDetailRepository _repository;

  GetPitchDetailUseCase(this._repository);

  Future<Either<Failure, PitchDetailEntity>> call(String pitchId) {
    return _repository.getPitchDetail(pitchId);
  }
}

class PitchDetailToggleSavedUseCase {
  final PitchDetailRepository _repository;

  PitchDetailToggleSavedUseCase(this._repository);

  /// Toggle the saved status of a pitch
  /// Returns true if now saved, false if now unsaved
  Future<Either<Failure, bool>> call(String pitchId) {
    return _repository.toggleSavedPitch(pitchId);
  }
}

class IsPitchSavedUseCase {
  final PitchDetailRepository _repository;

  IsPitchSavedUseCase(this._repository);

  Future<Either<Failure, bool>> call(String pitchId) {
    return _repository.isPitchSaved(pitchId);
  }
}
