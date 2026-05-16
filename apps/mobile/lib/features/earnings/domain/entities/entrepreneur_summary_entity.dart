import 'package:equatable/equatable.dart';

import 'payout_entry_entity.dart';
import 'pending_milestone_entity.dart';

class EntrepreneurSummaryEntity extends Equatable {
  final double totalReceived;
  final double pendingRelease;
  final List<PayoutEntryEntity> recentPayouts;
  final List<PendingMilestoneEntity> pendingMilestones;

  const EntrepreneurSummaryEntity({
    required this.totalReceived,
    required this.pendingRelease,
    required this.recentPayouts,
    required this.pendingMilestones,
  });

  @override
  List<Object?> get props => [
        totalReceived,
        pendingRelease,
        recentPayouts,
        pendingMilestones,
      ];
}
