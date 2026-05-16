import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../datasources/earnings_remote_datasource.dart';
import '../models/entrepreneur_summary_model.dart';
import '../../domain/entities/entrepreneur_summary_entity.dart';
import '../../domain/repositories/earnings_repository.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsRemoteDataSource remoteDataSource;

  EarningsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EntrepreneurSummaryEntity>> getEntrepreneurSummary() async {
    try {
      final data = await remoteDataSource.getEntrepreneurSummary();
      final summary = EntrepreneurSummaryModel.fromJson(data);
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
