import 'dart:async';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/delivery_success_view.dart';
import 'package:animations/animations.dart';

class VerificationView extends StatefulWidget {
  final int? orderId;
  final Order? order;
  const VerificationView({super.key, this.orderId, this.order});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isOtpComplete = false;

  Timer? _timer;
  int _seconds = 300;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {
      _isOtpComplete = _controllers.every((c) => c.text.isNotEmpty);
    });
  }

  void _onVerify(OrderViewModel viewModel) async {
    final otp = _controllers.map((c) => c.text).join();

    final success = await viewModel.verifyDeliveryOtp(otp);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              DeliverySuccessView(
            order: viewModel.order!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
        (route) => false, // Or clear until dashboard if preferred
      );
    } else if (mounted && viewModel.error != null) {
      CustomSnackBar.showError(context, viewModel.error!);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return ChangeNotifierProvider(
      create: (_) {
        final vm = OrderViewModel(
          orderId: widget.orderId ?? widget.order?.id ?? 0,
          initialOrder: widget.order,
        );
        vm.sendDeliveryOtp().then((success) {
          if (!success && vm.error != null && context.mounted) {
            CustomSnackBar.showError(context, vm.error!);
          }
        });
        return vm;
      },
      child: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  leading: const CustomBackButton(color: AppColors.headingText),
                  title: Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: R.sp(18),
                      fontWeight: FontWeight.w800,
                      color: AppColors.headingText,
                    ),
                  ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: R.w(24)),
                    child: Column(
                      children: [
                        SizedBox(height: R.h(40)),
                        _icon(),
                        SizedBox(height: R.h(32)),
                        _title(),
                        SizedBox(height: R.h(8)),
                        _subtitle(),
                        SizedBox(height: R.h(40)),
                        _otpFields(),
                        SizedBox(height: R.h(32)),
                        _timerWidget(),
                        SizedBox(height: R.h(40)),
                        _resend(viewModel),
                        SizedBox(height: R.h(50)),
                        _verifyButton(viewModel),
                        SizedBox(height: R.h(40)),
                      ],
                    ),
                  ),
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _icon() {
    return Container(
      width: R.w(100),
      height: R.w(100),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          RemixIcons.shield_check_line,
          color: AppColors.primaryGreen,
          size: R.sp(42),
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      'Enter Code',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: AppColors.headingText,
      ),
    );
  }

  Widget _subtitle() {
    return Column(
      children: [
        Text(
          "We've sent a 4-digit code to",
          style: TextStyle(
            fontSize: R.sp(15),
            color: AppColors.bodyText.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: R.h(8)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
          decoration: BoxDecoration(
            color: AppColors.softGreyBg,
            borderRadius: BorderRadius.circular(R.r(20)),
          ),
          child: Text(
            widget.order?.user?.mobile ?? '+1 (555) 000-0000',
            style: TextStyle(
              fontSize: R.sp(14),
              fontWeight: FontWeight.w700,
              color: AppColors.headingText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _otpFields() {
    return Row(
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
            textAlign: TextAlign.center,
            maxLength: 1,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: R.sp(28),
              fontWeight: FontWeight.w900,
              color: AppColors.headingText,
            ),
            cursorColor: AppColors.primaryGreen,
            decoration: InputDecoration(
              counterText: '',
              fillColor: isFocused || hasValue
                  ? AppColors.primaryGreen.withValues(alpha: 0.05)
                  : AppColors.softGreyBg,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.r(16)),
                borderSide: BorderSide(
                  color: hasValue ? AppColors.primaryGreen : Colors.transparent,
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
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => _onChanged(v, index),
          ),
        );
      }),
    );
  }

  Widget _timerWidget() {
    final minutes = (_seconds / 60).floor();
    final remainingSeconds = _seconds % 60;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.w(16),
        vertical: R.h(8),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(R.r(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            RemixIcons.time_line,
            color: AppColors.primaryGreen,
            size: R.sp(18),
          ),
          SizedBox(width: R.w(8)),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: R.sp(16),
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resend(OrderViewModel viewModel) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: R.sp(14),
              color: AppColors.bodyText.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
            children: [
              const TextSpan(text: "Didn't receive code? "),
              TextSpan(
                text: 'Resend',
                style: TextStyle(
                  color: _seconds == 0
                      ? AppColors.primaryGreen
                      : AppColors.bodyText.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        if (_seconds == 0)
          TextButton(
            onPressed: viewModel.isLoading
                ? null
                : () async {
                    final success = await viewModel.resendDeliveryOtp();
                    if (success && mounted) {
                      CustomSnackBar.showSuccess(
                          context, "OTP Resent successfully");
                      _startTimer();
                    } else if (mounted) {
                      CustomSnackBar.showError(
                          context, viewModel.error ?? "Failed to resend OTP");
                    }
                  },
            child: Text(
              "Resend Code",
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w800,
                fontSize: R.sp(14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _verifyButton(OrderViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: R.h(60),
      child: ElevatedButton(
        onPressed: (_isOtpComplete && !viewModel.isLoading)
            ? () => _onVerify(viewModel)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          disabledBackgroundColor:
              AppColors.primaryGreen.withValues(alpha: 0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(R.r(18)),
          ),
        ),
        child: viewModel.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                'Verify Now',
                style: TextStyle(
                  fontSize: R.sp(18),
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
      ),
    );
  }
}
