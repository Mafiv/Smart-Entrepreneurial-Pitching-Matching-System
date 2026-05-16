import 'package:equatable/equatable.dart';

import '../../domain/entities/portfolio_entity.dart';

class LedgerEntryModel extends Equatable {
  final String id;
  final String type;
  final String status;
  final double amount;
  final String currency;
  final String? submissionId;
  final String? submissionTitle;
  final String? milestoneId;
  final String? milestoneTitle;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? description;

  const LedgerEntryModel({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    this.submissionId,
    this.submissionTitle,
    this.milestoneId,
    this.milestoneTitle,
    required this.createdAt,
    this.completedAt,
    this.description,
  });

  factory LedgerEntryModel.fromJson(Map<String, dynamic> json) {
    return LedgerEntryModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      status: (json['status'] ?? 'pending') as String,
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      currency: (json['currency'] ?? 'ETB') as String,
      submissionId: (json['submissionId'] ?? json['submission_id']) as String?,
      submissionTitle:
          (json['submissionTitle'] ?? json['submission_title']) as String?,
      milestoneId: (json['milestoneId'] ?? json['milestone_id']) as String?,
      milestoneTitle:
          (json['milestoneTitle'] ?? json['milestone_title']) as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      description: (json['description']) as String?,
    );
  }

  LedgerEntryEntity toEntity() {
    return LedgerEntryEntity(
      id: id,
      type: type,
      status: status,
      amount: amount,
      currency: currency,
      submissionId: submissionId,
      submissionTitle: submissionTitle,
      milestoneId: milestoneId,
      milestoneTitle: milestoneTitle,
      createdAt: createdAt,
      completedAt: completedAt,
      description: description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        amount,
        currency,
        submissionId,
        submissionTitle,
        milestoneId,
        milestoneTitle,
        createdAt,
        completedAt,
        description,
      ];
}

class PortfolioProjectModel extends Equatable {
  final String submissionId;
  final String title;
  final int milestoneCount;
  final int paidMilestones;
  final double totalInvested;
  final String escrowStatus;
  final double estimatedReturn;

  const PortfolioProjectModel({
    required this.submissionId,
    required this.title,
    required this.milestoneCount,
    required this.paidMilestones,
    required this.totalInvested,
    required this.escrowStatus,
    this.estimatedReturn = 0.0,
  });

  factory PortfolioProjectModel.fromJson(Map<String, dynamic> json) {
    return PortfolioProjectModel(
      submissionId:
          (json['submissionId'] ?? json['submission_id'] ?? '') as String,
      title: (json['title'] ?? 'Unknown Project') as String,
      milestoneCount:
          (json['milestoneCount'] ?? json['milestone_count'] ?? 0) as int,
      paidMilestones:
          (json['paidMilestones'] ?? json['paid_milestones'] ?? 0) as int,
      totalInvested:
          ((json['totalInvested'] ?? json['total_invested'] ?? 0) as num)
              .toDouble(),
      escrowStatus:
          (json['escrowStatus'] ?? json['escrow_status'] ?? 'none') as String,
      estimatedReturn:
          ((json['estimatedReturn'] ?? json['estimated_return'] ?? 0) as num)
              .toDouble(),
    );
  }

  PortfolioProjectEntity toEntity() {
    return PortfolioProjectEntity(
      submissionId: submissionId,
      title: title,
      milestoneCount: milestoneCount,
      paidMilestones: paidMilestones,
      totalInvested: totalInvested,
      escrowStatus: escrowStatus,
      estimatedReturn: estimatedReturn,
    );
  }

  @override
  List<Object?> get props => [
        submissionId,
        title,
        milestoneCount,
        paidMilestones,
        totalInvested,
        escrowStatus,
        estimatedReturn,
      ];
}

class PortfolioSummaryModel extends Equatable {
  final double totalCommitted;
  final double totalReleased;
  final double platformFeesPaid;
  final List<PortfolioProjectModel> projects;
  final List<LedgerEntryModel> recentLedger;

  const PortfolioSummaryModel({
    required this.totalCommitted,
    required this.totalReleased,
    required this.platformFeesPaid,
    required this.projects,
    required this.recentLedger,
  });

  factory PortfolioSummaryModel.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> projectsList =
        ((json['perProject'] ?? []) as List).cast();
    final List<Map<String, dynamic>> ledgerList =
        ((json['recentLedger'] ?? []) as List).cast();

    return PortfolioSummaryModel(
      totalCommitted:
          ((json['totalCommitted'] ?? json['total_committed'] ?? 0) as num)
              .toDouble(),
      totalReleased:
          ((json['totalReleased'] ?? json['total_released'] ?? 0) as num)
              .toDouble(),
      platformFeesPaid:
          ((json['platformFeesPaid'] ?? json['platform_fees_paid'] ?? 0) as num)
              .toDouble(),
      projects:
          projectsList.map((p) => PortfolioProjectModel.fromJson(p)).toList(),
      recentLedger:
          ledgerList.map((l) => LedgerEntryModel.fromJson(l)).toList(),
    );
  }

  PortfolioSummaryEntity toEntity() {
    return PortfolioSummaryEntity(
      totalCommitted: totalCommitted,
      totalReleased: totalReleased,
      platformFeesPaid: platformFeesPaid,
      projects: projects.map((p) => p.toEntity()).toList(),
      recentLedger: recentLedger.map((l) => l.toEntity()).toList(),
    );
  }

  @override
  List<Object?> get props => [
        totalCommitted,
        totalReleased,
        platformFeesPaid,
        projects,
        recentLedger,
      ];
}
