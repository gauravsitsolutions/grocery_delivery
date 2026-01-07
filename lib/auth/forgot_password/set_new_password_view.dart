import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/res/styles/app_text_styles.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class SetNewPasswordView extends StatefulWidget {
  const SetNewPasswordView({super.key});

  @override
  State<SetNewPasswordView> createState() => _SetNewPasswordViewState();
}

class _SetNewPasswordViewState extends State<SetNewPasswordView> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasUpperCase =>
      _newPasswordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _newPasswordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar =>
      _newPasswordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  Widget _buildCheckItem(String text, bool isValid) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(8)),
      child: Row(
        children: [
           Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isValid ? AppColors.primaryGreen : AppColors.hintText,
            size: R.sp(20),
          ),
          SizedBox(width: R.w(8)),
          Text(
            text,
            style: TextStyle(
              color: isValid ? AppColors.bodyText : AppColors.hintText,
              fontSize: R.sp(14),
            ),
          ),
        ],
      ),
    );
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
          'Set New Password',
          style: AppTextStyles.heading.copyWith(fontSize: R.sp(18)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a New Password',
                style: AppTextStyles.heading.copyWith(fontSize: R.sp(24)),
              ),
              SizedBox(height: R.h(10)),
              Text(
                'Your new password must be different from previous used passwords.',
                style: AppTextStyles.subHeading.copyWith(
                  fontSize: R.sp(14),
                  color: AppColors.bodyText,
                  height: 1.5,
                ),
              ),
              SizedBox(height: R.h(30)),

              Text('New Password', style: AppTextStyles.label.copyWith(fontSize: R.sp(14))),
              SizedBox(height: R.h(8)),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? RemixIcons.eye_off_line : RemixIcons.eye_line,
                      size: R.sp(20),
                      color: AppColors.hintText,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              SizedBox(height: R.h(20)),

              _buildCheckItem('At least 8 characters', _hasMinLength),
              _buildCheckItem('One uppercase letter', _hasUpperCase),
              _buildCheckItem('One number', _hasNumber),
              _buildCheckItem('One special character', _hasSpecialChar),

              SizedBox(height: R.h(20)),
              Text('Confirm New Password', style: AppTextStyles.label.copyWith(fontSize: R.sp(14))),
              SizedBox(height: R.h(8)),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm new password',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? RemixIcons.eye_off_line : RemixIcons.eye_line,
                      size: R.sp(20),
                      color: AppColors.hintText,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),

              SizedBox(height: R.h(40)),
              SizedBox(
                width: double.infinity,
                height: R.h(50),
                child: ElevatedButton(
                  onPressed: () {
                     if (_hasMinLength && _hasUpperCase && _hasNumber && _hasSpecialChar && 
                         _newPasswordController.text == _confirmPasswordController.text) {
                        Navigator.pushNamed(context, AppRoutes.passwordResetSuccess);
                     }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(8)),
                    ),
                  ),
                  child: Text(
                    'Set Password',
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
