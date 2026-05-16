part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class MilestoneDetailsRequested extends PaymentEvent {
  final String milestoneId;

  const MilestoneDetailsRequested({required this.milestoneId});

  @override
  List<Object?> get props => [milestoneId];
}

class PendingMilestonesRequested extends PaymentEvent {
  const PendingMilestonesRequested();
}

class PaymentInitiated extends PaymentEvent {
  final String milestoneId;

  const PaymentInitiated({required this.milestoneId});

  @override
  List<Object?> get props => [milestoneId];
}

class PaymentVerificationRequested extends PaymentEvent {
  final String txRef;

  const PaymentVerificationRequested({required this.txRef});

  @override
  List<Object?> get props => [txRef];
}

class MilestoneProofSubmitted extends PaymentEvent {
  final String milestoneId;
  final Map<String, dynamic> proofData;

  const MilestoneProofSubmitted({
    required this.milestoneId,
    required this.proofData,
  });

  @override
  List<Object?> get props => [milestoneId, proofData];
}
