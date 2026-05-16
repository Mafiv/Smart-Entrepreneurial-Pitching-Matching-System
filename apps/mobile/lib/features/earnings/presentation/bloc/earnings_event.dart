part of 'earnings_bloc.dart';

abstract class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

class EarningsSummaryRequested extends EarningsEvent {
  const EarningsSummaryRequested();
}

class EarningsRefreshRequested extends EarningsEvent {
  const EarningsRefreshRequested();
}
