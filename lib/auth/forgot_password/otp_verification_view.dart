import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/res/styles/app_text_styles.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'dart:async';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';

class ForgotPasswordOTPView extends StatefulWidget {
  const ForgotPasswordOTPView({super.key});

  @override
  State<ForgotPasswordOTPView> createState() => _ForgotPasswordOTPViewState();
}

class _ForgotPasswordOTPViewState extends State<ForgotPasswordOTPView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController()); // Changed to 6
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode()); // Changed to 6

  final ApiService _apiService = ApiService();
  Timer? _timer;
  int _start = 30;
  bool _isTimerRunning = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _start = 30;
      _isTimerRunning = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isTimerRunning = false;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
// ... (skipping unchanged code)

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      // Changed to index < 5
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final mobileArgs = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: const BackButton(color: AppColors.black),
        title: Text(
          'OTP Verification',
          style: AppTextStyles.heading.copyWith(fontSize: R.sp(18)),
        ),
        centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(20), vertical: R.h(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: R.h(20)),
                          Text(
                            'Enter 6-digit code', // Changed text
                            style: AppTextStyles.heading
                                .copyWith(fontSize: R.sp(24)),
                          ),
                          SizedBox(height: R.h(10)),
                          Text(
                            'We\'ve sent a 6-digit code to your Agent ID or phone.', // Changed text
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subHeading.copyWith(
                              fontSize: R.sp(14),
                              color: AppColors.bodyText,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: R.h(40)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              6, // Changed to 6
                              (index) => SizedBox(
                                width: R.w(45), // Reduced width to fit 6 items
                                height: R.h(55), // Adjusted height
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: TextStyle(
                                      fontSize: R.sp(20),
                                      fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: AppColors.white,
                                    contentPadding:
                                        EdgeInsets.zero, // Centered text better
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          R.r(8)), // Slightly smaller radius
                                      borderSide: BorderSide(
                                          color: AppColors.borderLight),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(R.r(8)),
                                      borderSide: BorderSide(
                                          color: AppColors.borderLight),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(R.r(8)),
                                      borderSide: const BorderSide(
                                          color: AppColors.primaryGreen),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      _onChanged(value, index),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: R.h(30)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Didn\'t receive the code? ',
                                style: TextStyle(
                                    color: AppColors.bodyText,
                                    fontSize: R.sp(14)),
                              ),
                              TextButton(
                                onPressed: (_isTimerRunning || _isLoading)
                                    ? null
                                    : () async {
                                        final mobileArgs =
                                            ModalRoute.of(context)
                                                ?.settings
                                                .arguments;
                                        if (mobileArgs == null ||
                                            mobileArgs is! String) {
                                          CustomSnackBar.showError(context,
                                              'Error: Mobile number missing');
                                          return;
                                        }

                                        setState(() => _isLoading = true);
                                        try {
                                          await _apiService
                                              .sendForgotPasswordOtp(
                                                  mobileArgs);
                                          if (!mounted) return;

                                          CustomSnackBar.showSuccess(context,
                                              'OTP Resent Successfully');
                                          _startTimer();
                                        } catch (e) {
                                          if (!mounted) return;
                                          CustomSnackBar.showError(
                                              context,
                                              e.toString().replaceAll(
                                                  'Exception: ', ''));
                                        } finally {
                                          if (mounted)
                                            setState(() => _isLoading = false);
                                        }
                                      },
                                child: _isLoading
                                    ? SizedBox(
                                        height: R.sp(14),
                                        width: R.sp(14),
                                        child: const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primaryGreen))
                                    : Text(
                                        _isTimerRunning
                                            ? 'Resend Code (0:${_start.toString().padLeft(2, '0')})'
                                            : 'Resend Code',
                                        style: TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: R.sp(14),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: R.h(50),
                            child: ElevatedButton(
                              onPressed: () async {
                                // Validate and go next
                                bool isFilled = _controllers
                                    .every((c) => c.text.isNotEmpty);

                                if (!isFilled) {
                                  CustomSnackBar.showError(
                                      context, 'Please enter full 6-digit OTP');
                                  return;
                                }

                                if (mobileArgs == null) {
                                  CustomSnackBar.showError(
                                      context, 'Error: Mobile number missing');
                                  return;
                                }

                                setState(() => _isLoading = true);

                                try {
                                  final otp =
                                      _controllers.map((c) => c.text).join();
                                  final mobile = mobileArgs.toString();

                                  // Call API
                                  await _apiService.verifyForgotPasswordOtp(
                                      mobile, otp);

                                  if (!context.mounted) return;

                                  // Pass the mobile number to the next screen
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.setNewPassword,
                                    arguments: mobile,
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;

                                  CustomSnackBar.showError(
                                      context,
                                      e
                                          .toString()
                                          .replaceAll('Exception: ', ''));
                                } finally {
                                  if (mounted)
                                    setState(() => _isLoading = false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(R.r(8)),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: R.sp(20),
                                      width: R.sp(20),
                                      child: const CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      'Verify Code',
                                      style: TextStyle(
                                        fontSize: R.sp(16),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.black,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: R.h(16)),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Back to Forgot Password',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: R.sp(14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: R.h(10)),
                        ],
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
}
