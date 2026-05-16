import '../../domain/entities/pending_milestone_entity.dart';

class PendingMilestoneModel extends PendingMilestoneEntity {
  const PendingMilestoneModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.projectTitle,
  });

  factory PendingMilestoneModel.fromJson(Map<String, dynamic> json) {
    return PendingMilestoneModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      projectTitle: json['projectTitle'] as String? ?? '',
    );
  }

  factory PendingMilestoneModel.fromEntity(PendingMilestoneEntity entity) {
    return PendingMilestoneModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      projectTitle: entity.projectTitle,
    );
  }
}
