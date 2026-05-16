part of 'meetings_bloc.dart';

enum MeetingsStatus { initial, loading, loaded, error, tokenLoaded }

class MeetingsState extends Equatable {
  final MeetingsStatus status;
  final List<MeetingEntity> items;
  final String? statusFilter;
  final String? error;
  final String? meetingToken;

  const MeetingsState({
    required this.status,
    this.items = const [],
    this.statusFilter,
    this.error,
    this.meetingToken,
  });

  const MeetingsState.initial()
      : status = MeetingsStatus.initial,
        items = const [],
        statusFilter = null,
        error = null,
        meetingToken = null;

  MeetingsState copyWith({
    MeetingsStatus? status,
    List<MeetingEntity>? items,
    String? statusFilter,
    String? error,
    String? meetingToken,
  }) {
    return MeetingsState(
      status: status ?? this.status,
      items: items ?? this.items,
      statusFilter: statusFilter ?? this.statusFilter,
      error: error,
      meetingToken: meetingToken ?? this.meetingToken,
    );
  }

  bool get isLoading => status == MeetingsStatus.loading;

  @override
  List<Object?> get props => [status, items, statusFilter, error, meetingToken];
}

