import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/res/styles/app_text_styles.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class ForgotPasswordOTPView extends StatefulWidget {
  const ForgotPasswordOTPView({super.key});

  @override
  State<ForgotPasswordOTPView> createState() => _ForgotPasswordOTPViewState();
}

class _ForgotPasswordOTPViewState extends State<ForgotPasswordOTPView> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.black, size: R.sp(20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'OTP Verification',
          style: AppTextStyles.heading.copyWith(fontSize: R.sp(18)),
        ),
        centerTitle: true,
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
                            'Enter 4-digit code',
                            style: AppTextStyles.heading
                                .copyWith(fontSize: R.sp(24)),
                          ),
                          SizedBox(height: R.h(10)),
                          Text(
                            'We\'ve sent a 4-digit code to your Agent ID or phone.',
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
                              4,
                              (index) => SizedBox(
                                width: R.w(50),
                                height: R.h(60),
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
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(R.r(12)),
                                      borderSide: BorderSide(
                                          color: AppColors.borderLight),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(R.r(12)),
                                      borderSide: BorderSide(
                                          color: AppColors.borderLight),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(R.r(12)),
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
                                onPressed: () {},
                                child: Text(
                                  'Resend Code (0:59)',
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
                              onPressed: () {
                                // Validate and go next
                                bool isFilled = _controllers
                                    .every((c) => c.text.isNotEmpty);
                                if (isFilled) {
                                  Navigator.pushNamed(
                                      context, AppRoutes.setNewPassword);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(R.r(8)),
                                ),
                              ),
                              child: Text(
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
