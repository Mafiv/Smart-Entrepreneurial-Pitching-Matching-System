import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/portfolio_entity.dart';
import '../repositories/portfolio_repository.dart';

class GetPortfolioSummaryUseCase {
  final PortfolioRepository _repository;

  GetPortfolioSummaryUseCase(this._repository);

  Future<Either<Failure, PortfolioSummaryEntity>> call() {
    return _repository.getPortfolioSummary();
  }
}

class GetRecentLedgerUseCase {
  final PortfolioRepository _repository;

  GetRecentLedgerUseCase(this._repository);

  Future<Either<Failure, List<LedgerEntryEntity>>> call({int limit = 20}) {
    return _repository.getRecentLedger(limit: limit);
  }
}

class GetProjectDetailsUseCase {
  final PortfolioRepository _repository;

  GetProjectDetailsUseCase(this._repository);

  Future<Either<Failure, PortfolioProjectEntity>> call(String projectId) {
    return _repository.getProjectDetails(projectId);
  }
}
