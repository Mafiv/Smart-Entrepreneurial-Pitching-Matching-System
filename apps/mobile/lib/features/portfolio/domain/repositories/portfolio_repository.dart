import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/portfolio_entity.dart';

abstract class PortfolioRepository {
  /// Get investor's portfolio summary including stats and projects
  Future<Either<Failure, PortfolioSummaryEntity>> getPortfolioSummary();

  /// Get recent ledger entries for detailed transaction history
  Future<Either<Failure, List<LedgerEntryEntity>>> getRecentLedger(
      {int limit = 20});

  /// Get project-specific investment details
  Future<Either<Failure, PortfolioProjectEntity>> getProjectDetails(
      String projectId);
}
