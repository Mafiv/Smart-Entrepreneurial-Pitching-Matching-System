import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/entrepreneur_summary_entity.dart';
import '../repositories/earnings_repository.dart';

class GetEntrepreneurSummaryUseCase {
  final EarningsRepository repository;

  GetEntrepreneurSummaryUseCase(this.repository);

  Future<Either<Failure, EntrepreneurSummaryEntity>> call() {
    return repository.getEntrepreneurSummary();
  }
}
