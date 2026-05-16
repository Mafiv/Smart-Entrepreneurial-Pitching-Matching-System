import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/pitch_detail_entity.dart';

abstract class PitchDetailRepository {
  /// Get detailed pitch information by ID
  /// Includes entrepreneur info, documents, video, AI context
  Future<Either<Failure, PitchDetailEntity>> getPitchDetail(String pitchId);

  /// Toggle saved pitch (add/remove from saved list)
  Future<Either<Failure, bool>> toggleSavedPitch(String pitchId);

  /// Check if pitch is saved
  Future<Either<Failure, bool>> isPitchSaved(String pitchId);
}
