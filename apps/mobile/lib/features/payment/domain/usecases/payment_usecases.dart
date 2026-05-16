import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetMilestoneDetailsUseCase {
  final PaymentRepository repository;

  GetMilestoneDetailsUseCase({required this.repository});

  Future<Either<Failure, MilestonePaymentEntity>> call(String milestoneId) {
    return repository.getMilestoneDetails(milestoneId);
  }
}

class GetPendingMilestonesUseCase {
  final PaymentRepository repository;

  GetPendingMilestonesUseCase({required this.repository});

  Future<Either<Failure, List<MilestonePaymentEntity>>> call() {
    return repository.getPendingMilestones();
  }
}

class InitiatePaymentUseCase {
  final PaymentRepository repository;

  InitiatePaymentUseCase({required this.repository});

  Future<Either<Failure, PaymentInitiationResponseEntity>> call(
    String milestoneId,
  ) {
    return repository.initiatePayment(milestoneId);
  }
}

class VerifyPaymentUseCase {
  final PaymentRepository repository;

  VerifyPaymentUseCase({required this.repository});

  Future<Either<Failure, PaymentVerificationResponseEntity>> call(
    String txRef,
  ) {
    return repository.verifyPayment(txRef);
  }
}

class SubmitMilestoneProofUseCase {
  final PaymentRepository repository;

  SubmitMilestoneProofUseCase({required this.repository});

  Future<Either<Failure, MilestonePaymentEntity>> call(
    String milestoneId,
    Map<String, dynamic> proofData,
  ) {
    return repository.submitMilestoneProof(milestoneId, proofData);
  }
}
