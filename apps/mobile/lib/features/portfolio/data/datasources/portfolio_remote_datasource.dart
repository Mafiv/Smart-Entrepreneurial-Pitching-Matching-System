import '../../../../core/network/dio_client.dart';
import '../models/portfolio_model.dart';

abstract class PortfolioRemoteDatasource {
  Future<PortfolioSummaryModel> getPortfolioSummary();
  Future<List<LedgerEntryModel>> getRecentLedger({int limit = 20});
  Future<PortfolioProjectModel> getProjectDetails(String projectId);
}

class PortfolioRemoteDatasourceImpl implements PortfolioRemoteDatasource {
  final DioClient dioClient;

  PortfolioRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<PortfolioSummaryModel> getPortfolioSummary() async {
    final response = await dioClient.get('/finance/investor-summary');
    return PortfolioSummaryModel.fromJson(response.data);
  }

  @override
  Future<List<LedgerEntryModel>> getRecentLedger({int limit = 20}) async {
    final response = await dioClient.get(
      '/finance/investor-summary',
      queryParameters: {'limit': limit},
    );
    final data = response.data as Map<String, dynamic>;
    final ledgerList = (data['recentLedger'] as List? ?? [])
        .map((l) => LedgerEntryModel.fromJson(l as Map<String, dynamic>))
        .toList();
    return ledgerList;
  }

  @override
  Future<PortfolioProjectModel> getProjectDetails(String projectId) async {
    final response =
        await dioClient.get('/finance/investor-summary/$projectId');
    return PortfolioProjectModel.fromJson(response.data);
  }
}
