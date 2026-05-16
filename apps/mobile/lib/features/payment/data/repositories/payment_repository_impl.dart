import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDatasource remoteDatasource;

  PaymentRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, MilestonePaymentEntity>> getMilestoneDetails(
    String milestoneId,
  ) async {
    try {
      final result = await remoteDatasource.getMilestoneDetails(milestoneId);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MilestonePaymentEntity>>>
      getPendingMilestones() async {
    try {
      final result = await remoteDatasource.getPendingMilestones();
      return Right(result.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentInitiationResponseEntity>> initiatePayment(
    String milestoneId,
  ) async {
    try {
      final result = await remoteDatasource.initiatePayment(milestoneId);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentVerificationResponseEntity>> verifyPayment(
    String txRef,
  ) async {
    try {
      final result = await remoteDatasource.verifyPayment(txRef);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MilestonePaymentEntity>> submitMilestoneProof(
    String milestoneId,
    Map<String, dynamic> proofData,
  ) async {
    try {
      final result = await remoteDatasource.submitMilestoneProof(
        milestoneId,
        proofData,
      );
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
