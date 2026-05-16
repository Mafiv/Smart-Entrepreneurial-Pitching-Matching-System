part of 'portfolio_bloc.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();
}

class PortfolioSummaryRequested extends PortfolioEvent {
  const PortfolioSummaryRequested();

  @override
  List<Object?> get props => [];
}

class PortfolioRefresh extends PortfolioEvent {
  const PortfolioRefresh();

  @override
  List<Object?> get props => [];
}

class RecentLedgerRequested extends PortfolioEvent {
  final int limit;

  const RecentLedgerRequested({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

class ProjectDetailsRequested extends PortfolioEvent {
  final String projectId;

  const ProjectDetailsRequested(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
