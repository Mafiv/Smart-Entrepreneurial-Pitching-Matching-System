import '../../domain/entities/payment_entity.dart';

class ProofDocumentModel {
  final String id;
  final String name;
  final String url;
  final String type;
  final DateTime uploadedAt;

  ProofDocumentModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadedAt,
  });

  factory ProofDocumentModel.fromJson(Map<String, dynamic> json) {
    return ProofDocumentModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? 'other',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'url': url,
        'type': type,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  ProofDocument toEntity() => ProofDocument(
        id: id,
        name: name,
        url: url,
        type: type,
        uploadedAt: uploadedAt,
      );
}

class MilestonePaymentModel {
  final String id;
  final String submissionId;
  final String matchResultId;
  final String entrepreneurId;
  final String investorId;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final String status;
  final String escrowStatus;
  final List<ProofDocumentModel> evidenceDocuments;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final String? verificationNotes;
  final DateTime? paymentReleasedAt;

  MilestonePaymentModel({
    required this.id,
    required this.submissionId,
    required this.matchResultId,
    required this.entrepreneurId,
    required this.investorId,
    required this.title,
    this.description,
    required this.amount,
    required this.currency,
    required this.dueDate,
    required this.status,
    required this.escrowStatus,
    required this.evidenceDocuments,
    this.submittedAt,
    this.verifiedAt,
    this.verificationNotes,
    this.paymentReleasedAt,
  });

  factory MilestonePaymentModel.fromJson(Map<String, dynamic> json) {
    return MilestonePaymentModel(
      id: json['_id'] ?? json['id'] ?? '',
      submissionId: json['submissionId'] ?? '',
      matchResultId: json['matchResultId'] ?? '',
      entrepreneurId: json['entrepreneurId'] ?? '',
      investorId: json['investorId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'ETB',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'].toString())
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      escrowStatus: json['escrowStatus'] ?? 'not_held',
      evidenceDocuments: (json['evidenceDocuments'] as List?)
              ?.map(
                  (e) => ProofDocumentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'].toString())
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'].toString())
          : null,
      verificationNotes: json['verificationNotes'],
      paymentReleasedAt: json['paymentReleasedAt'] != null
          ? DateTime.parse(json['paymentReleasedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'submissionId': submissionId,
        'matchResultId': matchResultId,
        'entrepreneurId': entrepreneurId,
        'investorId': investorId,
        'title': title,
        'description': description,
        'amount': amount,
        'currency': currency,
        'dueDate': dueDate.toIso8601String(),
        'status': status,
        'escrowStatus': escrowStatus,
        'evidenceDocuments': evidenceDocuments.map((e) => e.toJson()).toList(),
        'submittedAt': submittedAt?.toIso8601String(),
        'verifiedAt': verifiedAt?.toIso8601String(),
        'verificationNotes': verificationNotes,
        'paymentReleasedAt': paymentReleasedAt?.toIso8601String(),
      };

  MilestonePaymentEntity toEntity() => MilestonePaymentEntity(
        id: id,
        submissionId: submissionId,
        matchResultId: matchResultId,
        entrepreneurId: entrepreneurId,
        investorId: investorId,
        title: title,
        description: description,
        amount: amount,
        currency: currency,
        dueDate: dueDate,
        status: status,
        escrowStatus: escrowStatus,
        evidenceDocuments: evidenceDocuments.map((e) => e.toEntity()).toList(),
        submittedAt: submittedAt,
        verifiedAt: verifiedAt,
        verificationNotes: verificationNotes,
        paymentReleasedAt: paymentReleasedAt,
      );
}

class PaymentInitiationResponseModel {
  final String txRef;
  final String checkoutUrl;
  final String status;
  final String message;

  PaymentInitiationResponseModel({
    required this.txRef,
    required this.checkoutUrl,
    required this.status,
    required this.message,
  });

  factory PaymentInitiationResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentInitiationResponseModel(
      txRef: json['tx_ref'] ?? json['txRef'] ?? '',
      checkoutUrl: json['checkout_url'] ?? json['checkoutUrl'] ?? '',
      status: json['status'] ?? 'pending',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'tx_ref': txRef,
        'checkout_url': checkoutUrl,
        'status': status,
        'message': message,
      };

  PaymentInitiationResponseEntity toEntity() => PaymentInitiationResponseEntity(
        txRef: txRef,
        checkoutUrl: checkoutUrl,
        status: status,
        message: message,
      );
}

class PaymentVerificationResponseModel {
  final String txRef;
  final String status;
  final double amount;
  final String currency;
  final DateTime processedAt;
  final String? reference;

  PaymentVerificationResponseModel({
    required this.txRef,
    required this.status,
    required this.amount,
    required this.currency,
    required this.processedAt,
    this.reference,
  });

  factory PaymentVerificationResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationResponseModel(
      txRef: json['tx_ref'] ?? json['txRef'] ?? '',
      status: json['status'] ?? 'pending',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'ETB',
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'].toString())
          : DateTime.now(),
      reference: json['reference'],
    );
  }

  Map<String, dynamic> toJson() => {
        'tx_ref': txRef,
        'status': status,
        'amount': amount,
        'currency': currency,
        'processedAt': processedAt.toIso8601String(),
        'reference': reference,
      };

  PaymentVerificationResponseEntity toEntity() =>
      PaymentVerificationResponseEntity(
        txRef: txRef,
        status: status,
        amount: amount,
        currency: currency,
        processedAt: processedAt,
        reference: reference,
      );
}
