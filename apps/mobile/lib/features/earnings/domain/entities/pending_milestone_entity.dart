import 'package:equatable/equatable.dart';

class PendingMilestoneEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String projectTitle;

  const PendingMilestoneEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.projectTitle,
  });

  @override
  List<Object?> get props => [id, title, amount, projectTitle];
}
