import '../../domain/entities/entrepreneur_summary_entity.dart';
import 'payout_entry_model.dart';
import 'pending_milestone_model.dart';

class EntrepreneurSummaryModel extends EntrepreneurSummaryEntity {
  const EntrepreneurSummaryModel({
    required super.totalReceived,
    required super.pendingRelease,
    required super.recentPayouts,
    required super.pendingMilestones,
  });

  factory EntrepreneurSummaryModel.fromJson(Map<String, dynamic> json) {
    final recentPayoutsList = (json['recentPayouts'] as List?) ?? [];
    final pendingMilestonesList = (json['pendingMilestones'] as List?) ?? [];

    return EntrepreneurSummaryModel(
      totalReceived: (json['totalReceived'] as num?)?.toDouble() ?? 0.0,
      pendingRelease: (json['pendingRelease'] as num?)?.toDouble() ?? 0.0,
      recentPayouts: recentPayoutsList
          .map((e) => PayoutEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingMilestones: pendingMilestonesList
          .map((e) => PendingMilestoneModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory EntrepreneurSummaryModel.fromEntity(EntrepreneurSummaryEntity entity) {
    return EntrepreneurSummaryModel(
      totalReceived: entity.totalReceived,
      pendingRelease: entity.pendingRelease,
      recentPayouts: entity.recentPayouts
          .map((e) => PayoutEntryModel.fromEntity(e))
          .toList(),
      pendingMilestones: entity.pendingMilestones
          .map((e) => PendingMilestoneModel.fromEntity(e))
          .toList(),
    );
  }
}
