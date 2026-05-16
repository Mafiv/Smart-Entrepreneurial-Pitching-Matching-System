part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final String? error;
  final int totalPitches;
  final int submittedPitches;
  final int draftPitches;
  final int acceptedMatchCount;
  final List<SubmissionEntity> submissions;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.error,
    this.totalPitches = 0,
    this.submittedPitches = 0,
    this.draftPitches = 0,
    this.acceptedMatchCount = 0,
    this.submissions = const [],
  });

  DashboardState copyWith({
    DashboardStatus? status,
    String? error,
    int? totalPitches,
    int? submittedPitches,
    int? draftPitches,
    int? acceptedMatchCount,
    List<SubmissionEntity>? submissions,
  }) {
    return DashboardState(
      status: status ?? this.status,
      error: error,
      totalPitches: totalPitches ?? this.totalPitches,
      submittedPitches: submittedPitches ?? this.submittedPitches,
      draftPitches: draftPitches ?? this.draftPitches,
      acceptedMatchCount: acceptedMatchCount ?? this.acceptedMatchCount,
      submissions: submissions ?? this.submissions,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        totalPitches,
        submittedPitches,
        draftPitches,
        acceptedMatchCount,
        submissions,
      ];
}
