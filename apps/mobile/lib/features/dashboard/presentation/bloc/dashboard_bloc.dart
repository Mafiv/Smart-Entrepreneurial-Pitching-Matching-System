import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../../submissions/domain/entities/submission_entity.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase _getStats;

  DashboardBloc({required GetDashboardStatsUseCase getStats})
      : _getStats = getStats,
        super(const DashboardState()) {
    on<DashboardStatsRequested>(_onStatsRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onStatsRequested(
    DashboardStatsRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading, error: null));
    final result = await _getStats();
    result.fold(
      (failure) => emit(
        state.copyWith(status: DashboardStatus.error, error: failure.message),
      ),
      (stats) => emit(
        state.copyWith(
          status: DashboardStatus.loaded,
          totalPitches: stats.totalPitches,
          submittedPitches: stats.submittedPitches,
          draftPitches: stats.draftPitches,
          acceptedMatchCount: stats.acceptedMatchCount,
          submissions: stats.submissions,
        ),
      ),
    );
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    add(const DashboardStatsRequested());
  }
}
