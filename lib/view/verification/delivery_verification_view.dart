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
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';

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
        title: Text(
          "Verify Delivery",
          style: TextStyle(
            fontSize: R.sp(18),
            fontWeight: FontWeight.w800,
            color: AppColors.headingText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(24), vertical: R.h(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: R.h(20)),
              // Header Icon
              AvatarGlow(
                glowColor: AppColors.primaryGreen,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                startDelay: const Duration(milliseconds: 100),
                child: Container(
                  width: R.w(100),
                  height: R.w(100),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Remix.shield_check_line,
                      size: R.sp(50),
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(32)),

              // Title and Description
              const Text(
                "Verification Required",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingText,
                ),
              ),
              SizedBox(height: R.h(12)),
              Text(
                "Enter the 4-digit code sent to\n${user?.fullName ?? 'the customer'}'s mobile number",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.sp(15),
                  color: AppColors.bodyText.withValues(alpha: 0.7),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (maskedMobile.isNotEmpty) ...[
                SizedBox(height: R.h(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(12), vertical: R.h(6)),
                  decoration: BoxDecoration(
                    color: AppColors.softGreyBg,
                    borderRadius: BorderRadius.circular(R.r(20)),
                  ),
                  child: Text(
                    maskedMobile,
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingText,
                    ),
                  ),
                ),
              ],
              SizedBox(height: R.h(40)),

              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFocused = _focusNodes[index].hasFocus;
                  final hasValue = _controllers[index].text.isNotEmpty;

                  return Container(
                    width: R.w(64),
                    height: R.h(72),
                    margin: EdgeInsets.symmetric(horizontal: R.w(8)),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: R.sp(28),
                        fontWeight: FontWeight.w900,
                        color: AppColors.headingText,
                      ),
                      cursorColor: AppColors.primaryGreen,
                      decoration: InputDecoration(
                        counterText: "",
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: isFocused || hasValue
                            ? AppColors.primaryGreen.withValues(alpha: 0.05)
                            : AppColors.softGreyBg,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(R.r(16)),
                          borderSide: BorderSide(
                            color: hasValue
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(R.r(16)),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGreen,
                            width: 2.5,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onOtpChanged(value, index),
                    ),
                  );
                }),
              ),
              SizedBox(height: R.h(40)),

              // Resend Timer
              if (_canResend)
                TextButton.icon(
                  onPressed: () async {
                    setState(() {
                      _canResend = false;
                      _secondsRemaining = 300;
                    });

                    final success = await context
                        .read<OrderViewModel>()
                        .resendDeliveryOtp();

                    if (!context.mounted) return;

                    if (success) {
                      _startTimer();
                      CustomSnackBar.showSuccess(
                          context, "OTP Sent Successfully");
                    } else {
                      setState(() => _canResend = true);
                    }
                  },
                  icon: Icon(Remix.refresh_line, size: R.sp(18)),
                  label: Text(
                    "Resend Code",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: R.sp(16),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(16), vertical: R.h(8)),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(R.r(30)),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: "Resend code in ",
                      style: TextStyle(
                        color: AppColors.bodyText.withValues(alpha: 0.6),
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text:
                              "${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: R.h(60)),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: R.h(60),
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
                      borderRadius: BorderRadius.circular(R.r(18)),
                    ),
                    elevation: 0,
                  ),
                  child: viewModel.isLoading
                      ? SizedBox(
                          width: R.w(24),
                          height: R.w(24),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          "Verify & Complete Delivery",
                          style: TextStyle(
                              fontSize: R.sp(16),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5),
                        ),
                ),
              ),
              SizedBox(height: R.h(24)),
            ],
          ),
        ),
      ),
    );
  }
}
