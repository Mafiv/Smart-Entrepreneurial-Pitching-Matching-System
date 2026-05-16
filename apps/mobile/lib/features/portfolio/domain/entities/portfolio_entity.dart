import 'package:equatable/equatable.dart';

/// Ledger entry representing a financial transaction
class LedgerEntryEntity extends Equatable {
  final String id;
  final String type; // 'escrow_hold', 'escrow_release', 'platform_fee'
  final String status; // 'pending', 'completed', 'failed'
  final double amount;
  final String currency;
  final String? submissionId; // Project ID
  final String? submissionTitle; // Project name
  final String? milestoneId;
  final String? milestoneTitle;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? description;

  const LedgerEntryEntity({
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

  factory LedgerEntryEntity.fromJson(Map<String, dynamic> json) {
    return LedgerEntryEntity(
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
        description
      ];
}

/// Project investment breakdown
class PortfolioProjectEntity extends Equatable {
  final String submissionId;
  final String title;
  final int milestoneCount;
  final int paidMilestones;
  final double totalInvested;
  final String escrowStatus; // 'none', 'pending', 'completed'
  final double estimatedReturn; // Optional: calculated return if available

  const PortfolioProjectEntity({
    required this.submissionId,
    required this.title,
    required this.milestoneCount,
    required this.paidMilestones,
    required this.totalInvested,
    required this.escrowStatus,
    this.estimatedReturn = 0.0,
  });

  factory PortfolioProjectEntity.fromJson(Map<String, dynamic> json) {
    return PortfolioProjectEntity(
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

  /// Milestone completion percentage
  int get completionPercentage {
    if (milestoneCount == 0) return 0;
    return ((paidMilestones / milestoneCount) * 100).toInt();
  }

  @override
  List<Object?> get props => [
        submissionId,
        title,
        milestoneCount,
        paidMilestones,
        totalInvested,
        escrowStatus,
        estimatedReturn
      ];
}

/// Complete portfolio summary for investor
class PortfolioSummaryEntity extends Equatable {
  final double totalCommitted; // Total amount locked in escrow
  final double totalReleased; // Total amount released to entrepreneurs
  final double platformFeesPaid; // Platform fees paid
  final List<PortfolioProjectEntity> projects; // Per-project breakdown
  final List<LedgerEntryEntity> recentLedger; // Recent 20 transactions

  const PortfolioSummaryEntity({
    required this.totalCommitted,
    required this.totalReleased,
    required this.platformFeesPaid,
    required this.projects,
    required this.recentLedger,
  });

  factory PortfolioSummaryEntity.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> projectsList =
        ((json['perProject'] ?? []) as List).cast();
    final List<Map<String, dynamic>> ledgerList =
        ((json['recentLedger'] ?? []) as List).cast();

    return PortfolioSummaryEntity(
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
          projectsList.map((p) => PortfolioProjectEntity.fromJson(p)).toList(),
      recentLedger:
          ledgerList.map((e) => LedgerEntryEntity.fromJson(e)).toList(),
    );
  }

  /// Total invested across all projects
  double get totalInvested {
    return projects.fold(0.0, (sum, p) => sum + p.totalInvested);
  }

  /// Number of active projects
  int get activeProjectCount => projects.length;

  /// Total return on investment (released - committed)
  double get netReturn => totalReleased - totalCommitted;

  /// Return percentage
  double get returnPercentage {
    if (totalCommitted == 0) return 0;
    return ((netReturn / totalCommitted) * 100);
  }

  @override
  List<Object?> get props =>
      [totalCommitted, totalReleased, platformFeesPaid, projects, recentLedger];
}
