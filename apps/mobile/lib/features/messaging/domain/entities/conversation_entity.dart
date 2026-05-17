import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final Map<String, dynamic> data;
  const ConversationEntity({required this.data});

  String get id => (data['_id'] as String?) ?? (data['id'] as String?) ?? '';

  List<String> get participants {
    final raw = data['participants'];
    if (raw is! List) return const [];
    return raw
        .map((entry) {
          if (entry is String) return entry;
          if (entry is Map) {
            return (entry['_id'] as String?) ?? (entry['id'] as String?) ?? '';
          }
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toList();
  }

  String get otherUserName {
    final name = data['otherUserName'];
    if (name is String) return name;

    final otherUser = data['otherUser'];
    if (otherUser is Map<String, dynamic>) {
      final fullName = otherUser['fullName'];
      if (fullName is String) return fullName;
    }

    final title = data['title'];
    if (title is String) return title;

    return '';
  }

  int get unreadCount {
    final value = data['unreadCount'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  @override
  List<Object?> get props => [data];
}
