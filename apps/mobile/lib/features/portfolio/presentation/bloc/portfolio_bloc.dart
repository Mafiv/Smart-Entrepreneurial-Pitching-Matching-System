import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/portfolio_entity.dart';
import '../../domain/usecases/portfolio_usecases.dart';

part 'portfolio_event.dart';
part 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final GetPortfolioSummaryUseCase _getPortfolioSummary;
  final GetRecentLedgerUseCase _getRecentLedger;
  final GetProjectDetailsUseCase _getProjectDetails;

  PortfolioBloc({
    required GetPortfolioSummaryUseCase getPortfolioSummary,
    required GetRecentLedgerUseCase getRecentLedger,
    required GetProjectDetailsUseCase getProjectDetails,
  })  : _getPortfolioSummary = getPortfolioSummary,
        _getRecentLedger = getRecentLedger,
        _getProjectDetails = getProjectDetails,
        super(const PortfolioState.initial()) {
    on<PortfolioSummaryRequested>(_onSummaryRequested);
    on<PortfolioRefresh>(_onRefresh);
    on<RecentLedgerRequested>(_onRecentLedgerRequested);
    on<ProjectDetailsRequested>(_onProjectDetailsRequested);
  }

  Future<void> _onSummaryRequested(
    PortfolioSummaryRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(state.copyWith(status: PortfolioStatus.loading, errorMessage: null));

    final result = await _getPortfolioSummary();

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: PortfolioStatus.error,
          errorMessage: failure.message,
        ));
      },
      (summary) {
        emit(state.copyWith(
          status: PortfolioStatus.loaded,
          summary: summary,
          recentLedger: summary.recentLedger,
        ));
      },
    );
  }

  Future<void> _onRefresh(
    PortfolioRefresh event,
    Emitter<PortfolioState> emit,
  ) async {
    final result = await _getPortfolioSummary();

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: PortfolioStatus.error,
          errorMessage: failure.message,
        ));
      },
      (summary) {
        emit(state.copyWith(
          status: PortfolioStatus.loaded,
          summary: summary,
          recentLedger: summary.recentLedger,
        ));
      },
    );
  }

  Future<void> _onRecentLedgerRequested(
    RecentLedgerRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    final result = await _getRecentLedger(limit: event.limit);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: PortfolioStatus.error,
          errorMessage: failure.message,
        ));
      },
      (ledger) {
        emit(state.copyWith(
          recentLedger: ledger,
        ));
      },
    );
  }

  Future<void> _onProjectDetailsRequested(
    ProjectDetailsRequested event,
    Emitter<PortfolioState> emit,
  ) async {
    final result = await _getProjectDetails(event.projectId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: PortfolioStatus.error,
          errorMessage: failure.message,
        ));
      },
      (project) {
        emit(state.copyWith(
          selectedProject: project,
        ));
      },
    );
  }
}
