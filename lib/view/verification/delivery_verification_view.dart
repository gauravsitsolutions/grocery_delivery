import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/delivery_success_view.dart';
import 'package:animations/animations.dart';

class DeliveryVerificationView extends StatefulWidget {
  final int orderId;
  const DeliveryVerificationView({super.key, required this.orderId});

  @override
  State<DeliveryVerificationView> createState() =>
      _DeliveryVerificationViewState();
}

class _DeliveryVerificationViewState extends State<DeliveryVerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 300;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Send OTP automatically when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().sendDeliveryOtp();
    });
  }

  void _startTimer() {
    _secondsRemaining = 300;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
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
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {}); // Rebuild to update border colors
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrderViewModel>();
    final user = viewModel.order?.user;
    final mobile = user?.mobile ?? "";
    final maskedMobile = mobile.length >= 10
        ? mobile.replaceRange(
            0, mobile.length > 4 ? mobile.length - 4 : 0, '******')
        : mobile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Verify Delivery"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Theme.of(context).platform == TargetPlatform.iOS
                ? Remix.arrow_left_s_line
                : Remix.arrow_left_line,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Header Icon
              AvatarGlow(
                glowColor: AppColors.primaryGreen,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                startDelay: const Duration(milliseconds: 100),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Remix.shield_check_line,
                      size: 50,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title and Description
              const Text(
                "Verification Required",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Please ask the customer for the 4-digit verification code sent to their mobile number.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              if (maskedMobile.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "Sent to: $maskedMobile",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black87,
                  ),
                ),
              ],
              const SizedBox(height: 40),

              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final isFocused = _focusNodes[index].hasFocus;
                  final hasValue = _controllers[index].text.isNotEmpty;

                  return SizedBox(
                    width: 45,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black87,
                      ),
                      cursorColor: AppColors.primaryGreen,
                      decoration: InputDecoration(
                        counterText: "",
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: isFocused || hasValue
                            ? AppColors.primaryGreen.withValues(alpha: 0.05)
                            : Colors.grey[50],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: hasValue
                                ? AppColors.primaryGreen
                                : Colors.grey[300]!,
                            width: hasValue ? 1.5 : 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onOtpChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Resend Timer
              if (_canResend)
                TextButton.icon(
                  onPressed: () async {
                    setState(() {
                      _canResend = false;
                      _secondsRemaining = 300;
                    }); // Reset UI immediately

                    final success = await context
                        .read<OrderViewModel>()
                        .resendDeliveryOtp();

                    if (!context.mounted) return;

                    if (success) {
                      _startTimer();
                      CustomSnackBar.showSuccess(
                          context, "OTP Sent Successfully");
                    } else {
                      setState(() => _canResend = true); // Re-enable if failed
                    }
                  },
                  icon: const Icon(Remix.refresh_line, size: 18),
                  label: const Text(
                    "Resend Code",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                  ),
                )
              else
                RichText(
                  text: TextSpan(
                    text: "Resend code in ",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    children: [
                      TextSpan(
                        text:
                            "${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 48),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final otp = _otpCode;
                          if (otp.length != 4) {
                            CustomSnackBar.showError(context,
                                "Please enter the complete 4-digit code");
                            return;
                          }

                          final success =
                              await viewModel.verifyDeliveryOtp(otp);

                          if (!context.mounted) return;

                          if (success) {
                            CustomSnackBar.showSuccess(
                                context, "Delivery Verified Successfully!");

                            // Navigate to Delivered Details View
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        DeliverySuccessView(
                                  order: viewModel.order!,
                                ),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return SharedAxisTransition(
                                    animation: animation,
                                    secondaryAnimation: secondaryAnimation,
                                    transitionType:
                                        SharedAxisTransitionType.horizontal,
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                              ),
                            );
                          } else {
                            CustomSnackBar.showError(
                                context,
                                viewModel.error ??
                                    "Invalid OTP, please try again");
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Verify & Complete Delivery",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
