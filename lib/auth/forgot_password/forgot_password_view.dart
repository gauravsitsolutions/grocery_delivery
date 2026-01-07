import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/res/styles/app_text_styles.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
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
        leading: const BackButton(color: AppColors.black),
        title: Text(
          'Forgot Password',
          style: AppTextStyles.heading.copyWith(fontSize: R.sp(18)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forgot Password',
                style: AppTextStyles.heading.copyWith(fontSize: R.sp(24)),
              ),
              SizedBox(height: R.h(10)),
              Text(
                'Please enter the Agent ID or phone number associated with your account. We will send you a code to reset your password.',
                style: AppTextStyles.subHeading.copyWith(
                  fontSize: R.sp(14),
                  color: AppColors.bodyText,
                  height: 1.5,
                ),
              ),
              SizedBox(height: R.h(30)),
              Text(
                'Agent ID or Phone Number',
                style: AppTextStyles.label.copyWith(fontSize: R.sp(14)),
              ),
              SizedBox(height: R.h(8)),
              TextField(
                controller: _controller,
                cursorColor: AppColors.primaryGreen,
                decoration: InputDecoration(
                  hintText: 'Enter your Agent ID or phone number',
                  hintStyle: TextStyle(color: AppColors.hintText, fontSize: R.sp(14)),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(8)),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(8)),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(8)),
                    borderSide: const BorderSide(color: AppColors.primaryGreen),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: R.w(16),
                    vertical: R.h(14),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: R.h(50),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to OTP
                    if (_controller.text.isNotEmpty) {
                      Navigator.pushNamed(context, AppRoutes.forgotPasswordOtp);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter your Agent ID or phone number"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(8)),
                    ),
                  ),
                  child: Text(
                    'Send Reset Code',
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
                    'Back to Login',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(10)),
            ],
          ),
        ),
      ),
    );
  }
}
