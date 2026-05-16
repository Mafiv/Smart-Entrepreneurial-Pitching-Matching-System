import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDatasource {
  Future<MilestonePaymentModel> getMilestoneDetails(String milestoneId);
  Future<List<MilestonePaymentModel>> getPendingMilestones();
  Future<PaymentInitiationResponseModel> initiatePayment(String milestoneId);
  Future<PaymentVerificationResponseModel> verifyPayment(String txRef);
  Future<MilestonePaymentModel> submitMilestoneProof(
    String milestoneId,
    Map<String, dynamic> proofData,
  );
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  final DioClient dioClient;

  PaymentRemoteDatasourceImpl({required this.dioClient});

  @override
  Future<MilestonePaymentModel> getMilestoneDetails(String milestoneId) async {
    try {
      final response = await dioClient.get(
        '/milestones/$milestoneId',
      );
      return MilestonePaymentModel.fromJson(
          response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch milestone details: ${e.message}');
    }
  }

  @override
  Future<List<MilestonePaymentModel>> getPendingMilestones() async {
    try {
      final response = await dioClient.get('/milestones/investor/pending');
      final data = response.data['data'] as List? ?? [];
      return data
          .map((m) => MilestonePaymentModel.fromJson(m as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch pending milestones: ${e.message}');
    }
  }

  @override
  Future<PaymentInitiationResponseModel> initiatePayment(
    String milestoneId,
  ) async {
    try {
      final response = await dioClient.post(
        '/payments/initiate',
        data: {'milestoneId': milestoneId},
      );
      return PaymentInitiationResponseModel.fromJson(
        response.data['data'] ?? response.data,
      );
    } on DioException catch (e) {
      throw Exception('Failed to initiate payment: ${e.message}');
    }
  }

  @override
  Future<PaymentVerificationResponseModel> verifyPayment(String txRef) async {
    try {
      final response = await dioClient.get('/payments/verify/$txRef');
      return PaymentVerificationResponseModel.fromJson(
        response.data['data'] ?? response.data,
      );
    } on DioException catch (e) {
      throw Exception('Failed to verify payment: ${e.message}');
    }
  }

  @override
  Future<MilestonePaymentModel> submitMilestoneProof(
    String milestoneId,
    Map<String, dynamic> proofData,
  ) async {
    try {
      final response = await dioClient.post(
        '/milestones/$milestoneId/proof',
        data: proofData,
      );
      return MilestonePaymentModel.fromJson(
          response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw Exception('Failed to submit proof: ${e.message}');
    }
  }
}
