import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../submissions/domain/entities/submission_entity.dart';
import '../../../submissions/domain/repositories/submissions_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final SubmissionsRepository submissionsRepository;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.submissionsRepository,
  });

  @override
  Future<Either<Failure, DashboardStatsEntity>> getDashboardStats() async {
    try {
      // Get submissions
      final submissionsResult = await submissionsRepository.listMySubmissions();
      final submissions = submissionsResult.getOrElse(() => []);

      // Get match count
      final matchCount = await remoteDataSource.getAcceptedMatchCount();

      // Calculate statistics
      final totalPitches = submissions.length;
      final draftPitches =
          submissions.where((s) => s.status == SubmissionStatus.draft).toList().length;
      final submittedPitches = totalPitches - draftPitches;

      return Right(DashboardStatsEntity(
        submissions: submissions,
        totalPitches: totalPitches,
        submittedPitches: submittedPitches,
        draftPitches: draftPitches,
        acceptedMatchCount: matchCount,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
