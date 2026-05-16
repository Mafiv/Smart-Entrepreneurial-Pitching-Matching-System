import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment_entity.dart';
import '../bloc/payment_bloc.dart';

class PaymentCheckoutPage extends StatefulWidget {
  final MilestonePaymentEntity milestone;
  final PaymentInitiationResponseEntity paymentResponse;

  const PaymentCheckoutPage({
    Key? key,
    required this.milestone,
    required this.paymentResponse,
  }) : super(key: key);

  @override
  State<PaymentCheckoutPage> createState() => _PaymentCheckoutPageState();
}

class _PaymentCheckoutPageState extends State<PaymentCheckoutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchPaymentCheckout();
    });
  }

  Future<void> _launchPaymentCheckout() async {
    // In a production app, you would use url_launcher or webview_flutter
    // to launch the payment URL and capture the callback

    // For now, show a dialog with payment details
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Checkout'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transaction Reference: ${widget.paymentResponse.txRef}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Amount: ETB ${widget.milestone.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                'Checkout URL:',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  widget.paymentResponse.checkoutUrl,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'In production, you would be redirected to this URL to complete payment via Chapa.',
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulatePaymentVerification();
            },
            child: const Text('Verify Payment'),
          ),
        ],
      ),
    );
  }

  void _simulatePaymentVerification() {
    // In a real app, after user completes checkout on Chapa,
    // the callback would trigger verification
    // For now, show a dialog to simulate entering the transaction reference

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Payment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'After completing payment on Chapa, the system will verify the transaction.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Transaction Reference (for testing):',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  widget.paymentResponse.txRef,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyPayment();
            },
            child: const Text('Verify Now'),
          ),
        ],
      ),
    );
  }

  void _verifyPayment() {
    context.read<PaymentBloc>().add(
          PaymentVerificationRequested(txRef: widget.paymentResponse.txRef),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state.status == PaymentStatus.paymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment verified successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            });
          } else if (state.status == PaymentStatus.paymentFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Payment verification failed. Status: ${state.verificationResponse?.status ?? "unknown"}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == PaymentStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status Icon
                      if (state.isLoading)
                        const SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                      else if (state.status == PaymentStatus.paymentSuccess)
                        const Icon(
                          Icons.check_circle,
                          size: 64,
                          color: Colors.green,
                        )
                      else if (state.status == PaymentStatus.paymentFailed)
                        const Icon(
                          Icons.cancel,
                          size: 64,
                          color: Colors.red,
                        )
                      else
                        const Icon(
                          Icons.payment,
                          size: 64,
                          color: Colors.blue,
                        ),
                      const SizedBox(height: 24),

                      // Status Text
                      Text(
                        _getStatusText(state),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Details
                      Text(
                        _getStatusDetails(state),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // Amount Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Amount',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ETB ${widget.milestone.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Milestone Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Milestone',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.milestone.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transaction Reference
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Transaction Reference',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                widget.paymentResponse.txRef,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getStatusText(PaymentState state) {
    switch (state.status) {
      case PaymentStatus.loading:
        return 'Processing...';
      case PaymentStatus.paymentSuccess:
        return 'Payment Verified!';
      case PaymentStatus.paymentFailed:
        return 'Payment Failed';
      case PaymentStatus.error:
        return 'Error';
      default:
        return 'Complete Payment';
    }
  }

  String _getStatusDetails(PaymentState state) {
    switch (state.status) {
      case PaymentStatus.loading:
        return 'Verifying your payment...';
      case PaymentStatus.paymentSuccess:
        return 'Your payment has been verified successfully. The milestone will be released.';
      case PaymentStatus.paymentFailed:
        return 'Payment verification failed. Please check the details and try again.';
      case PaymentStatus.error:
        return state.errorMessage ?? 'An error occurred. Please try again.';
      default:
        return 'Click "Verify Payment" after completing payment on Chapa';
    }
  }
}
