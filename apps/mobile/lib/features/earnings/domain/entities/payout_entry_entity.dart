import 'package:equatable/equatable.dart';

class PayoutEntryEntity extends Equatable {
  final String id;
  final String transactionId;
  final double amount;
  final String currency;
  final String status;
  final String description;
  final String? milestoneId;
  final String? milestoneTitle;
  final String? submissionId;
  final String? submissionTitle;
  final DateTime occurredAt;

  const PayoutEntryEntity({
    required this.id,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    this.milestoneId,
    this.milestoneTitle,
    this.submissionId,
    this.submissionTitle,
    required this.occurredAt,
  });

  @override
  List<Object?> get props => [
        id,
        transactionId,
        amount,
        currency,
        status,
        description,
        milestoneId,
        milestoneTitle,
        submissionId,
        submissionTitle,
        occurredAt,
      ];
}
