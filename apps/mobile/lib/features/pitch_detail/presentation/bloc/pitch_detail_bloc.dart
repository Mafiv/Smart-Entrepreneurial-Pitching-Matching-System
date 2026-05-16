import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pitch_detail_entity.dart';
import '../../domain/usecases/pitch_detail_usecases.dart';

part 'pitch_detail_event.dart';
part 'pitch_detail_state.dart';

class PitchDetailBloc extends Bloc<PitchDetailEvent, PitchDetailState> {
  final GetPitchDetailUseCase _getPitchDetail;
  final PitchDetailToggleSavedUseCase _toggleSavedPitch;
  final IsPitchSavedUseCase _isPitchSaved;

  PitchDetailBloc({
    required GetPitchDetailUseCase getPitchDetail,
    required PitchDetailToggleSavedUseCase toggleSavedPitch,
    required IsPitchSavedUseCase isPitchSaved,
  })  : _getPitchDetail = getPitchDetail,
        _toggleSavedPitch = toggleSavedPitch,
        _isPitchSaved = isPitchSaved,
        super(const PitchDetailState.initial()) {
    on<PitchDetailRequested>(_onRequested);
    on<PitchDetailSaveToggled>(_onSaveToggled);
    on<PitchDetailRefresh>(_onRefresh);
  }

  Future<void> _onRequested(
    PitchDetailRequested event,
    Emitter<PitchDetailState> emit,
  ) async {
    emit(state.copyWith(status: PitchDetailStatus.loading, errorMessage: null));

    // Fetch pitch details and check if saved in parallel
    final pitchResult = await _getPitchDetail(event.pitchId);
    final isSavedResult = await _isPitchSaved(event.pitchId);

    pitchResult.fold(
      (failure) => emit(
        state.copyWith(
          status: PitchDetailStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (pitch) {
        final isSaved = isSavedResult.getOrElse(() => false);
        emit(
          state.copyWith(
            status: PitchDetailStatus.loaded,
            pitch: pitch,
            isSaved: isSaved,
          ),
        );
      },
    );
  }

  Future<void> _onSaveToggled(
    PitchDetailSaveToggled event,
    Emitter<PitchDetailState> emit,
  ) async {
    emit(state.copyWith(isSavingToggle: true));

    final result = await _toggleSavedPitch(event.pitchId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSavingToggle: false,
          errorMessage: failure.message,
        ),
      ),
      (isSavedNow) => emit(
        state.copyWith(
          isSavingToggle: false,
          isSaved: isSavedNow,
          pitch: state.pitch != null ? state.pitch! : state.pitch,
        ),
      ),
    );
  }

  Future<void> _onRefresh(
    PitchDetailRefresh event,
    Emitter<PitchDetailState> emit,
  ) async {
    // Refresh by requesting again
    add(PitchDetailRequested(event.pitchId));
  }
}
