import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/payment_usecases.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetMilestoneDetailsUseCase _getMilestoneDetails;
  final GetPendingMilestonesUseCase _getPendingMilestones;
  final InitiatePaymentUseCase _initiatePayment;
  final VerifyPaymentUseCase _verifyPayment;
  final SubmitMilestoneProofUseCase _submitProof;

  PaymentBloc({
    required GetMilestoneDetailsUseCase getMilestoneDetails,
    required GetPendingMilestonesUseCase getPendingMilestones,
    required InitiatePaymentUseCase initiatePayment,
    required VerifyPaymentUseCase verifyPayment,
    required SubmitMilestoneProofUseCase submitProof,
  })  : _getMilestoneDetails = getMilestoneDetails,
        _getPendingMilestones = getPendingMilestones,
        _initiatePayment = initiatePayment,
        _verifyPayment = verifyPayment,
        _submitProof = submitProof,
        super(PaymentState.initial()) {
    on<MilestoneDetailsRequested>(_onMilestoneDetailsRequested);
    on<PendingMilestonesRequested>(_onPendingMilestonesRequested);
    on<PaymentInitiated>(_onPaymentInitiated);
    on<PaymentVerificationRequested>(_onPaymentVerificationRequested);
    on<MilestoneProofSubmitted>(_onMilestoneProofSubmitted);
  }

  Future<void> _onMilestoneDetailsRequested(
    MilestoneDetailsRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.loading));

    final result = await _getMilestoneDetails(event.milestoneId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (milestone) => emit(
        state.copyWith(
          status: PaymentStatus.loaded,
          selectedMilestone: milestone,
        ),
      ),
    );
  }

  Future<void> _onPendingMilestonesRequested(
    PendingMilestonesRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.loading));

    final result = await _getPendingMilestones();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (milestones) => emit(
        state.copyWith(
          status: PaymentStatus.loaded,
          pendingMilestones: milestones,
        ),
      ),
    );
  }

  Future<void> _onPaymentInitiated(
    PaymentInitiated event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.loading));

    final result = await _initiatePayment(event.milestoneId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          status: PaymentStatus.paymentInitiated,
          paymentResponse: response,
        ),
      ),
    );
  }

  Future<void> _onPaymentVerificationRequested(
    PaymentVerificationRequested event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.loading));

    final result = await _verifyPayment(event.txRef);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (response) {
        if (response.isSuccessful) {
          emit(
            state.copyWith(
              status: PaymentStatus.paymentSuccess,
              verificationResponse: response,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: PaymentStatus.paymentFailed,
              verificationResponse: response,
            ),
          );
        }
      },
    );
  }

  Future<void> _onMilestoneProofSubmitted(
    MilestoneProofSubmitted event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.loading));

    final result = await _submitProof(event.milestoneId, event.proofData);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PaymentStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (milestone) => emit(
        state.copyWith(
          status: PaymentStatus.proofSubmitted,
          selectedMilestone: milestone,
        ),
      ),
    );
  }
}
