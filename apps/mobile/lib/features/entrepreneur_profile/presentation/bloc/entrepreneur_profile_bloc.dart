import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entrepreneur_profile_entity.dart';
import '../../domain/usecases/entrepreneur_profile_usecases.dart';

part 'entrepreneur_profile_event.dart';
part 'entrepreneur_profile_state.dart';

class EntrepreneurProfileBloc
    extends Bloc<EntrepreneurProfileEvent, EntrepreneurProfileState> {
  final HasEntrepreneurProfileUseCase _hasProfile;
  final GetEntrepreneurProfileUseCase _getProfile;
  final CreateEntrepreneurProfileUseCase _create;
  final UpdateEntrepreneurProfileUseCase _update;
  final UploadKycDocumentUseCase _uploadKyc;

  EntrepreneurProfileBloc({
    required HasEntrepreneurProfileUseCase hasProfile,
    required GetEntrepreneurProfileUseCase getProfile,
    required CreateEntrepreneurProfileUseCase create,
    required UpdateEntrepreneurProfileUseCase update,
    required UploadKycDocumentUseCase uploadKyc,
  })  : _hasProfile = hasProfile,
        _getProfile = getProfile,
        _create = create,
        _update = update,
        _uploadKyc = uploadKyc,
        super(const EntrepreneurProfileState.initial()) {
    on<EntrepreneurProfileChecked>(_onCheck);
    on<EntrepreneurProfileLoaded>(_onLoad);
    on<EntrepreneurProfileCreateRequested>(_onCreate);
    on<EntrepreneurProfileUpdateRequested>(_onUpdate);
    on<EntrepreneurProfileVerificationDocumentsUpdateRequested>(_onUpdateVerificationDocuments);
    on<EntrepreneurProfileKycUploadRequested>(_onKycUpload);
  }

  Future<void> _onCheck(
    EntrepreneurProfileChecked event,
    Emitter<EntrepreneurProfileState> emit,
  ) async {
    emit(state.copyWith(status: EntrepreneurProfileStatus.loading, error: null));
    final result = await _hasProfile();
    result.fold(
      (f) => emit(state.copyWith(
        status: EntrepreneurProfileStatus.error,
        error: f.message,
      )),
      (has) => emit(state.copyWith(
        status: has ? EntrepreneurProfileStatus.exists : EntrepreneurProfileStatus.missing,
        error: null,
      )),
    );
  }

  Future<void> _onLoad(
    EntrepreneurProfileLoaded event,
    Emitter<EntrepreneurProfileState> emit,
  ) async {
    emit(state.copyWith(status: EntrepreneurProfileStatus.loading, error: null));
    final result = await _getProfile();
    result.fold(
      (f) => emit(state.copyWith(
        status: EntrepreneurProfileStatus.error,
        error: f.message,
      )),
      (profile) => emit(state.copyWith(
        status: EntrepreneurProfileStatus.loaded,
        profile: profile,
        error: null,
      )),
    );
  }

  Future<void> _onCreate(
    EntrepreneurProfileCreateRequested event,
    Emitter<EntrepreneurProfileState> emit,
  ) async {
    emit(state.copyWith(status: EntrepreneurProfileStatus.loading, error: null));
    final result = await _create(
      fullName: event.fullName,
      companyName: event.companyName,
      companyRegistrationNumber: event.companyRegistrationNumber,
      businessSector: event.businessSector,
      businessStage: event.businessStage,
    );
    result.fold(
      (f) => emit(state.copyWith(
        status: EntrepreneurProfileStatus.error,
        error: f.message,
      )),
      (profile) => emit(state.copyWith(
        status: EntrepreneurProfileStatus.loaded,
        profile: profile,
        error: null,
      )),
    );
  }

  Future<void> _onUpdate(
    EntrepreneurProfileUpdateRequested event,
    Emitter<EntrepreneurProfileState> emit,
  ) async {
    emit(state.copyWith(status: EntrepreneurProfileStatus.loading, error: null));
    final result = await _update(event.patch);
    result.fold(
      (f) => emit(state.copyWith(
        status: EntrepreneurProfileStatus.error,
        error: f.message,
      )),
      (profile) => emit(state.copyWith(
        status: EntrepreneurProfileStatus.loaded,
        profile: profile,
        error: null,
      )),
    );
  }

  Future<void> _onUpdateVerificationDocuments(
    EntrepreneurProfileVerificationDocumentsUpdateRequested event,
    Emitter<EntrepreneurProfileState> emit,
  ) async {
    emit(state.copyWith(status: EntrepreneurProfileStatus.loading, error: null));
    final result = await _update({
      'nationalIdUrl': event.nationalIdUrl,
      'businessLicenseUrl': event.businessLicenseUrl,
      'tinNumber': event.tinNumber,
    });
    result.fold(
      (f) => emit(state.copyWith(
        status: EntrepreneurProfileStatus.error,
        error: f.message,
      )),
      (profile) => emit(state.copyWith(
        status: EntrepreneurProfileStatus.loaded,
        profile: profile,
        error: null,
      )),
    );
  }

  Future<void> _onKycUpload(
    EntrepreneurProfileKycUploadRequested event,
    Emitter<EntrepreneurProfileState> emit,
  ) async {
    emit(state.copyWith(status: EntrepreneurProfileStatus.loading, error: null));
    final result = await _uploadKyc(file: event.file, type: event.type);
    result.fold(
      (f) => emit(state.copyWith(
        status: EntrepreneurProfileStatus.error,
        error: f.message,
      )),
      (url) {
        final patch = <String, dynamic>{};
        if (event.type == 'nationalId') {
          patch['nationalIdUrl'] = url;
        } else if (event.type == 'businessLicense') {
          patch['businessLicenseUrl'] = url;
        }
        if (patch.isNotEmpty) {
          add(EntrepreneurProfileUpdateRequested(patch));
        } else {
          emit(state.copyWith(
            status: EntrepreneurProfileStatus.loaded,
            error: null,
          ));
        }
      },
    );
  }
}

