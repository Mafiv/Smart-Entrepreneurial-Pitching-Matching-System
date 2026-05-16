import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_entrepreneur_summary_usecase.dart';

part 'earnings_event.dart';
part 'earnings_state.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final GetEntrepreneurSummaryUseCase _getSummary;

  EarningsBloc({required GetEntrepreneurSummaryUseCase getSummary})
      : _getSummary = getSummary,
        super(const EarningsState()) {
    on<EarningsSummaryRequested>(_onSummaryRequested);
    on<EarningsRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onSummaryRequested(
    EarningsSummaryRequested event,
    Emitter<EarningsState> emit,
  ) async {
    emit(state.copyWith(status: EarningsStatus.loading, error: null));
    final result = await _getSummary();
    result.fold(
      (failure) => emit(
        state.copyWith(status: EarningsStatus.error, error: failure.message),
      ),
      (summary) => emit(
        state.copyWith(
          status: EarningsStatus.loaded,
          totalReceived: summary.totalReceived,
          pendingRelease: summary.pendingRelease,
          recentPayouts: summary.recentPayouts,
          pendingMilestones: summary.pendingMilestones,
        ),
      ),
    );
  }

  Future<void> _onRefreshRequested(
    EarningsRefreshRequested event,
    Emitter<EarningsState> emit,
  ) async {
    add(const EarningsSummaryRequested());
  }
}
