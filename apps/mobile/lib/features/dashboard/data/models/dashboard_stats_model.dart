import '../../domain/entities/dashboard_stats_entity.dart';

class DashboardStatsModel extends DashboardStatsEntity {
  const DashboardStatsModel({
    required super.submissions,
    required super.totalPitches,
    required super.submittedPitches,
    required super.draftPitches,
    required super.acceptedMatchCount,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    // The submissions will be parsed separately from the submissions feature
    // This model mainly holds the statistics
    return const DashboardStatsModel(
      submissions: [], // Will be populated separately
      totalPitches: 0,
      submittedPitches: 0,
      draftPitches: 0,
      acceptedMatchCount: 0,
    );
  }

  factory DashboardStatsModel.fromEntity(DashboardStatsEntity entity) {
    return DashboardStatsModel(
      submissions: entity.submissions,
      totalPitches: entity.totalPitches,
      submittedPitches: entity.submittedPitches,
      draftPitches: entity.draftPitches,
      acceptedMatchCount: entity.acceptedMatchCount,
    );
  }
}
