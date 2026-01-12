import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_delivered_details_view.dart';

class DeliveryVerificationView extends StatefulWidget {
  final int orderId;
  const DeliveryVerificationView({super.key, required this.orderId});

  @override
  State<DeliveryVerificationView> createState() =>
      _DeliveryVerificationViewState();
}

class _DeliveryVerificationViewState extends State<DeliveryVerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 300;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().sendDeliveryOtp();
    });
  }

  void _startTimer() {
    _secondsRemaining = 300;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _timer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verify Delivery"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Verification Code",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ask the customer for the 6-digit code sent to ${viewModel.order?.user?.mobile != null ? viewModel.order!.user!.mobile.replaceRange(viewModel.order!.user!.mobile.length - 10 < 0 ? 0 : viewModel.order!.user!.mobile.length - 10, viewModel.order!.user!.mobile.length - 4, '******') : 'their mobile number'}.",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 48,
                  height: 48,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primaryGreen, width: 2),
                      ),
                    ),
                    onChanged: (value) => _onOtpChanged(value, index),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Center(
              child: _canResend
                  ? TextButton(
                      onPressed: () async {
                        final success = await context
                            .read<OrderViewModel>()
                            .sendDeliveryOtp();
                        if (success && mounted) {
                          _startTimer();
                          CustomSnackBar.showSuccess(
                              context, "OTP Sent Successfully");
                        }
                      },
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    )
                  : Text(
                      "Resend OTP in ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 16,
                      ),
                    ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final otp = _otpCode;
                        if (otp.length != 6) {
                          CustomSnackBar.showError(
                              context, "Please enter a valid 6-digit code");
                          return;
                        }

                        // Call verify delivery API
                        // Note: verifyDeliveryOtp needs to be implemented in ViewModel
                        final success = await viewModel.verifyDeliveryOtp(otp);

                        if (!context.mounted) return;

                        if (success) {
                          CustomSnackBar.showSuccess(
                              context, "Delivery Verified Successfully!");

                          // Navigate to Delivered Details View
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDeliveredDetailsView(
                                order: viewModel.order!,
                              ),
                            ),
                          );
                        } else {
                          CustomSnackBar.showError(context,
                              viewModel.error ?? "Verification Failed");
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Verify & Complete",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
