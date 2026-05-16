import 'package:equatable/equatable.dart';

class ProofDocument extends Equatable {
  final String id;
  final String name;
  final String url;
  final String type; // invoice, report, delivery_note, photo, video, other
  final DateTime uploadedAt;

  const ProofDocument({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [id, name, url, type, uploadedAt];
}

class MilestonePaymentEntity extends Equatable {
  final String id;
  final String submissionId;
  final String matchResultId;
  final String entrepreneurId;
  final String investorId;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final String
      status; // pending, in_progress, submitted_for_review, verified_paid, rejected, cancelled
  final String escrowStatus; // not_held, held, released, refunded
  final List<ProofDocument> evidenceDocuments;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final String? verificationNotes;
  final DateTime? paymentReleasedAt;

  const MilestonePaymentEntity({
    required this.id,
    required this.submissionId,
    required this.matchResultId,
    required this.entrepreneurId,
    required this.investorId,
    required this.title,
    this.description,
    required this.amount,
    required this.currency,
    required this.dueDate,
    required this.status,
    required this.escrowStatus,
    required this.evidenceDocuments,
    this.submittedAt,
    this.verifiedAt,
    this.verificationNotes,
    this.paymentReleasedAt,
  });

  /// Calculated: Is milestone awaiting proof review from entrepreneur?
  bool get isAwaitingProofSubmission =>
      status == 'pending' || status == 'in_progress';

  /// Calculated: Has proof been submitted?
  bool get hasProofSubmitted =>
      status == 'submitted_for_review' || verifiedAt != null;

  /// Calculated: Is payment verified and ready?
  bool get isPaymentVerified =>
      status == 'verified_paid' && escrowStatus == 'released';

  /// Calculated: Days until due
  int get daysUntilDue {
    final diff = dueDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Calculated: Is milestone overdue?
  bool get isOverdue => DateTime.now().isAfter(dueDate) && !isPaymentVerified;

  @override
  List<Object?> get props => [
        id,
        submissionId,
        matchResultId,
        entrepreneurId,
        investorId,
        title,
        description,
        amount,
        currency,
        dueDate,
        status,
        escrowStatus,
        evidenceDocuments,
        submittedAt,
        verifiedAt,
        verificationNotes,
        paymentReleasedAt,
      ];
}

class PaymentInitiationResponseEntity extends Equatable {
  final String txRef;
  final String checkoutUrl;
  final String status;
  final String message;

  const PaymentInitiationResponseEntity({
    required this.txRef,
    required this.checkoutUrl,
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => [txRef, checkoutUrl, status, message];
}

class PaymentVerificationResponseEntity extends Equatable {
  final String txRef;
  final String status; // success, pending, failed
  final double amount;
  final String currency;
  final DateTime processedAt;
  final String? reference;

  const PaymentVerificationResponseEntity({
    required this.txRef,
    required this.status,
    required this.amount,
    required this.currency,
    required this.processedAt,
    this.reference,
  });

  bool get isSuccessful => status == 'success';

  @override
  List<Object?> get props =>
      [txRef, status, amount, currency, processedAt, reference];
}
