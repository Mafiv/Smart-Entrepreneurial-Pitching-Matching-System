part of 'pitch_detail_bloc.dart';

abstract class PitchDetailEvent extends Equatable {
  const PitchDetailEvent();
}

class PitchDetailRequested extends PitchDetailEvent {
  final String pitchId;

  const PitchDetailRequested(this.pitchId);

  @override
  List<Object?> get props => [pitchId];
}

class PitchDetailSaveToggled extends PitchDetailEvent {
  final String pitchId;

  const PitchDetailSaveToggled(this.pitchId);

  @override
  List<Object?> get props => [pitchId];
}

class PitchDetailRefresh extends PitchDetailEvent {
  final String pitchId;

  const PitchDetailRefresh(this.pitchId);

  @override
  List<Object?> get props => [pitchId];
}
