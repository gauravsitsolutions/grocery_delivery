import 'dart:async';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';

class VerificationView extends StatefulWidget {
  final int? orderId;
  final Order? order;
  const VerificationView({super.key, this.orderId, this.order});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {
      _isOtpComplete = _controllers.every((c) => c.text.isNotEmpty);
    });
  }

  void _onVerify() {
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.deliverySummary,
      arguments: widget.order,
    );
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

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: const CustomBackButton(color: AppColors.headingText),
        centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
        title: Text(
          'Verification',
          style: TextStyle(
            fontSize: R.sp(18),
            fontWeight: FontWeight.w700,
            color: AppColors.headingText,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
              SizedBox(height: R.h(24)),
              _resend(),
              SizedBox(height: R.h(32)),
              _verifyButton(),
              SizedBox(height: R.h(40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    return Container(
      width: R.r(120),
      height: R.r(120),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withAlpha(30),
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
    return Text(
      'Enter code',
      style: TextStyle(
        fontSize: R.sp(30),
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _subtitle() {
    return Column(
      children: [
        Text(
          "We've sent a 6-digit code to",
          style: TextStyle(
            fontSize: R.sp(14),
            color: AppColors.bodyText,
          ),
        ),
        SizedBox(height: R.h(4)),
        Text(
          widget.order?.user?.mobile ?? '+1 (555) 000-0000',
          style: TextStyle(
            fontSize: R.sp(15),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _otpFields() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: R.w(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          return Container(
            width: R.r(50),
            height: R.r(60),
            margin: EdgeInsets.symmetric(horizontal: R.w(4)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(R.r(12)),
              border: Border.all(
                color: _focusNodes[index].hasFocus
                    ? AppColors.primaryGreen
                    : AppColors.borderLight,
                width: R.r(2),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withAlpha(10),
                  blurRadius: R.r(8),
                ),
              ],
            ),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: R.sp(20),
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => _onChanged(v, index),
            ),
          );
        }),
      ),
    );
  }

  Widget _timerWidget() {
    final minutes = (_seconds / 60).floor();
    final remainingSeconds = _seconds % 60;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.w(20),
        vertical: R.h(10),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(12),
            blurRadius: R.r(10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            RemixIcons.hourglass_fill,
            color: AppColors.primaryGreen,
            size: R.sp(18),
          ),
          SizedBox(width: R.w(8)),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: R.sp(16),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resend() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: R.sp(14),
          color: AppColors.bodyText,
        ),
        children: const [
          TextSpan(text: "Didn't receive code? "),
          TextSpan(
            text: 'Resend',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verifyButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(16)),
      child: SizedBox(
        width: double.infinity,
        height: R.h(56),
        child: ElevatedButton(
          onPressed: _isOtpComplete ? _onVerify : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            disabledBackgroundColor: AppColors.primaryGreen.withAlpha(100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(R.r(16)),
            ),
          ),
          child: Text(
            'Verify',
            style: TextStyle(
              fontSize: R.sp(18),
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
