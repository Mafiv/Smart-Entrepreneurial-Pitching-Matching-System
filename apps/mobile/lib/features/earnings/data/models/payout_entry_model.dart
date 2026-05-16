import '../../domain/entities/payout_entry_entity.dart';

class PayoutEntryModel extends PayoutEntryEntity {
  const PayoutEntryModel({
    required super.id,
    required super.transactionId,
    required super.amount,
    required super.currency,
    required super.status,
    required super.description,
    super.milestoneId,
    super.milestoneTitle,
    super.submissionId,
    super.submissionTitle,
    required super.occurredAt,
  });

  factory PayoutEntryModel.fromJson(Map<String, dynamic> json) {
    return PayoutEntryModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'ETB',
      status: json['status'] as String? ?? 'unknown',
      description: json['description'] as String? ?? '',
      milestoneId: json['milestoneId'] is Map
          ? (json['milestoneId'] as Map<String, dynamic>)['_id'] as String?
          : json['milestoneId'] as String?,
      milestoneTitle: json['milestoneId'] is Map
          ? (json['milestoneId'] as Map<String, dynamic>)['title'] as String?
          : null,
      submissionId: json['submissionId'] is Map
          ? (json['submissionId'] as Map<String, dynamic>)['_id'] as String?
          : json['submissionId'] as String?,
      submissionTitle: json['submissionId'] is Map
          ? (json['submissionId'] as Map<String, dynamic>)['title'] as String?
          : null,
      occurredAt: DateTime.parse(
        json['occurredAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  factory PayoutEntryModel.fromEntity(PayoutEntryEntity entity) {
    return PayoutEntryModel(
      id: entity.id,
      transactionId: entity.transactionId,
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status,
      description: entity.description,
      milestoneId: entity.milestoneId,
      milestoneTitle: entity.milestoneTitle,
      submissionId: entity.submissionId,
      submissionTitle: entity.submissionTitle,
      occurredAt: entity.occurredAt,
    );
  }
}
