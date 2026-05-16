part of 'earnings_bloc.dart';

enum EarningsStatus { initial, loading, loaded, error }

class EarningsState extends Equatable {
  final EarningsStatus status;
  final String? error;
  final double totalReceived;
  final double pendingRelease;
  final List<dynamic> recentPayouts;
  final List<dynamic> pendingMilestones;

  const EarningsState({
    this.status = EarningsStatus.initial,
    this.error,
    this.totalReceived = 0.0,
    this.pendingRelease = 0.0,
    this.recentPayouts = const [],
    this.pendingMilestones = const [],
  });

  EarningsState copyWith({
    EarningsStatus? status,
    String? error,
    double? totalReceived,
    double? pendingRelease,
    List<dynamic>? recentPayouts,
    List<dynamic>? pendingMilestones,
  }) {
    return EarningsState(
      status: status ?? this.status,
      error: error,
      totalReceived: totalReceived ?? this.totalReceived,
      pendingRelease: pendingRelease ?? this.pendingRelease,
      recentPayouts: recentPayouts ?? this.recentPayouts,
      pendingMilestones: pendingMilestones ?? this.pendingMilestones,
    );
  }

  @override
  List<Object?> get props => [
        status,
        error,
        totalReceived,
        pendingRelease,
        recentPayouts,
        pendingMilestones,
      ];
}
