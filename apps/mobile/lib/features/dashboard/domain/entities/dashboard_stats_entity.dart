import 'package:equatable/equatable.dart';

import '../../../submissions/domain/entities/submission_entity.dart';

class DashboardStatsEntity extends Equatable {
  final List<SubmissionEntity> submissions;
  final int totalPitches;
  final int submittedPitches;
  final int draftPitches;
  final int acceptedMatchCount;

  const DashboardStatsEntity({
    required this.submissions,
    required this.totalPitches,
    required this.submittedPitches,
    required this.draftPitches,
    required this.acceptedMatchCount,
  });

  @override
  List<Object?> get props => [
        submissions,
        totalPitches,
        submittedPitches,
        draftPitches,
        acceptedMatchCount,
      ];
}
