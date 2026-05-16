part of 'payment_bloc.dart';

enum PaymentStatus {
  initial,
  loading,
  loaded,
  error,
  paymentInitiated,
  paymentSuccess,
  paymentFailed,
  proofSubmitted,
}

class PaymentState extends Equatable {
  final PaymentStatus status;
  final List<MilestonePaymentEntity> pendingMilestones;
  final MilestonePaymentEntity? selectedMilestone;
  final PaymentInitiationResponseEntity? paymentResponse;
  final PaymentVerificationResponseEntity? verificationResponse;
  final String? errorMessage;

  const PaymentState({
    required this.status,
    required this.pendingMilestones,
    this.selectedMilestone,
    this.paymentResponse,
    this.verificationResponse,
    this.errorMessage,
  });

  factory PaymentState.initial() {
    return const PaymentState(
      status: PaymentStatus.initial,
      pendingMilestones: [],
      selectedMilestone: null,
      paymentResponse: null,
      verificationResponse: null,
      errorMessage: null,
    );
  }

  PaymentState copyWith({
    PaymentStatus? status,
    List<MilestonePaymentEntity>? pendingMilestones,
    MilestonePaymentEntity? selectedMilestone,
    PaymentInitiationResponseEntity? paymentResponse,
    PaymentVerificationResponseEntity? verificationResponse,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      pendingMilestones: pendingMilestones ?? this.pendingMilestones,
      selectedMilestone: selectedMilestone ?? this.selectedMilestone,
      paymentResponse: paymentResponse ?? this.paymentResponse,
      verificationResponse: verificationResponse ?? this.verificationResponse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == PaymentStatus.loading;
  bool get hasError => status == PaymentStatus.error;

  @override
  List<Object?> get props => [
        status,
        pendingMilestones,
        selectedMilestone,
        paymentResponse,
        verificationResponse,
        errorMessage,
      ];
}
