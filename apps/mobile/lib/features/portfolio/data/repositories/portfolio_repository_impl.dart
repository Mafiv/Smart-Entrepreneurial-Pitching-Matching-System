import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/portfolio_entity.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_remote_datasource.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioRemoteDatasource remoteDatasource;

  PortfolioRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, PortfolioSummaryEntity>> getPortfolioSummary() async {
    try {
      final result = await remoteDatasource.getPortfolioSummary();
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LedgerEntryEntity>>> getRecentLedger(
      {int limit = 20}) async {
    try {
      final result = await remoteDatasource.getRecentLedger(limit: limit);
      return Right(result.map((l) => l.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PortfolioProjectEntity>> getProjectDetails(
      String projectId) async {
    try {
      final result = await remoteDatasource.getProjectDetails(projectId);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
