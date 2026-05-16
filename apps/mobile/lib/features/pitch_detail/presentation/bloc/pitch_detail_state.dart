part of 'pitch_detail_bloc.dart';

enum PitchDetailStatus { initial, loading, loaded, error }

class PitchDetailState extends Equatable {
  final PitchDetailStatus status;
  final PitchDetailEntity? pitch;
  final bool isSaved;
  final bool isSavingToggle;
  final String? errorMessage;

  const PitchDetailState({
    required this.status,
    this.pitch,
    required this.isSaved,
    required this.isSavingToggle,
    this.errorMessage,
  });

  const PitchDetailState.initial()
      : status = PitchDetailStatus.initial,
        pitch = null,
        isSaved = false,
        isSavingToggle = false,
        errorMessage = null;

  PitchDetailState copyWith({
    PitchDetailStatus? status,
    PitchDetailEntity? pitch,
    bool? isSaved,
    bool? isSavingToggle,
    String? errorMessage,
  }) {
    return PitchDetailState(
      status: status ?? this.status,
      pitch: pitch ?? this.pitch,
      isSaved: isSaved ?? this.isSaved,
      isSavingToggle: isSavingToggle ?? this.isSavingToggle,
      errorMessage: errorMessage,
    );
  }

  bool get isLoading => status == PitchDetailStatus.loading;

  @override
  List<Object?> get props =>
      [status, pitch, isSaved, isSavingToggle, errorMessage];
}
