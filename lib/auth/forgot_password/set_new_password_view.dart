import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/res/styles/app_text_styles.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';

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

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    CustomSnackBar.showError(context, message);
  }

  Future<void> _handleSetPassword() async {
    // 1. Validate Form
    if (!_hasMinLength || !_hasUpperCase || !_hasNumber || !_hasSpecialChar) {
      _showError("Password does not meet requirements");
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match");
      return;
    }

    // 2. Get Mobile from Arguments
    final mobileArgs = ModalRoute.of(context)?.settings.arguments;
    if (mobileArgs == null || mobileArgs is! String) {
      _showError("Error: User details missing. Please restart.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Call API
      final response = await _apiService.resetPassword(
          mobileArgs, _newPasswordController.text);

      if (!mounted) return;

      if (response['status'] == true) {
        // Success -> Navigate to Success Screen
        // Wait for 2 seconds as requested, to show any success state if needed
        // (However, since we are navigating to a 'Success Screen', the user likely means
        // show the success screen/message itself. But given we are navigating TO the success screen,
        // the delay might be better placed ON the success screen or BEFORE navigating if we want to show a toast here first.
        // Assuming user wants to see the result of "Set Password" action momentarily.)

        // Actually, typically "show that" refers to a success feedback.
        // But the destination IS PasswordResetSuccessView.
        // If the user means "show the success screen for 2 seconds then navigate to LOGIN",
        // that logic belongs in PasswordResetSuccessView.

        // Let's check if PasswordResetSuccessView auto-navigates.
        // Retreading the request: "also after password restet show that for 2 second and navigate"
        // This most likely implies: The "Success View" should be shown for 2 seconds, then go to Login.

        // SO I should check PasswordResetSuccessView.dart.

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.passwordResetSuccess,
          (route) => false,
        );
      } else {
        _showError(response['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        leading: const CustomBackButton(color: AppColors.black),
        title: Text(
          'Set New Password',
          style: AppTextStyles.heading.copyWith(fontSize: R.sp(18)),
        ),
        centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
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
              Text('New Password',
                  style: AppTextStyles.label.copyWith(fontSize: R.sp(14))),
              SizedBox(height: R.h(8)),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(R.r(12))),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? RemixIcons.eye_off_line
                          : RemixIcons.eye_line,
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
              Text('Confirm New Password',
                  style: AppTextStyles.label.copyWith(fontSize: R.sp(14))),
              SizedBox(height: R.h(8)),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm new password',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(R.r(12))),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? RemixIcons.eye_off_line
                          : RemixIcons.eye_line,
                      size: R.sp(20),
                      color: AppColors.hintText,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              SizedBox(height: R.h(40)),
              SizedBox(
                width: double.infinity,
                height: R.h(50),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSetPassword,
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
                              color: Colors.white, strokeWidth: 2))
                      : Text(
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
