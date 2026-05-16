part of 'portfolio_bloc.dart';

enum PortfolioStatus { initial, loading, loaded, error }

class PortfolioState extends Equatable {
  final PortfolioStatus status;
  final PortfolioSummaryEntity? summary;
  final List<LedgerEntryEntity>? recentLedger;
  final PortfolioProjectEntity? selectedProject;
  final String? errorMessage;

  const PortfolioState({
    required this.status,
    this.summary,
    this.recentLedger,
    this.selectedProject,
    this.errorMessage,
  });

  const PortfolioState.initial()
      : status = PortfolioStatus.initial,
        summary = null,
        recentLedger = null,
        selectedProject = null,
        errorMessage = null;

  PortfolioState copyWith({
    PortfolioStatus? status,
    PortfolioSummaryEntity? summary,
    List<LedgerEntryEntity>? recentLedger,
    PortfolioProjectEntity? selectedProject,
    String? errorMessage,
  }) {
    return PortfolioState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      recentLedger: recentLedger ?? this.recentLedger,
      selectedProject: selectedProject ?? this.selectedProject,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == PortfolioStatus.loading;

  @override
  List<Object?> get props =>
      [status, summary, recentLedger, selectedProject, errorMessage];
}
