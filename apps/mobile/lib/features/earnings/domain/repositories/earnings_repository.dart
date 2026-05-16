import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/entrepreneur_summary_entity.dart';

abstract class EarningsRepository {
  Future<Either<Failure, EntrepreneurSummaryEntity>> getEntrepreneurSummary();
}
