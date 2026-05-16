import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  /// Get milestone details for payment
  Future<Either<Failure, MilestonePaymentEntity>> getMilestoneDetails(
    String milestoneId,
  );

  /// Get all pending milestones for investor
  Future<Either<Failure, List<MilestonePaymentEntity>>> getPendingMilestones();

  /// Initiate Chapa payment for a milestone
  Future<Either<Failure, PaymentInitiationResponseEntity>> initiatePayment(
    String milestoneId,
  );

  /// Verify payment status
  Future<Either<Failure, PaymentVerificationResponseEntity>> verifyPayment(
    String txRef,
  );

  /// Submit proof documents for a milestone
  Future<Either<Failure, MilestonePaymentEntity>> submitMilestoneProof(
    String milestoneId,
    Map<String, dynamic> proofData,
  );
}
