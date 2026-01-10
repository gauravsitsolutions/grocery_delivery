import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/res/styles/app_text_styles.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/view_model/auth_view_model.dart';

enum LoginMethod { password, otp }

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailOrIdController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _emailOrIdController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context, AuthViewModel viewModel) async {
    FocusScope.of(context).unfocus();

    final currentMethod = viewModel.loginMethod;
    Map<String, dynamic> result;
    if (currentMethod == LoginMethod.password) {
      result = await viewModel.loginWithPassword(
          _emailOrIdController.text.trim(), _passwordController.text.trim());
    } else {
      if (!viewModel.isOtpSent) {
        result = await viewModel.sendOtp(_mobileController.text.trim());
      } else {
        result = await viewModel.verifyOtp(
            _mobileController.text.trim(), _otpController.text.trim());
      }
    }

    if (!context.mounted) return;

    if (result['success']) {
      CustomSnackBar.showSuccess(
        context,
        result['message'] ??
            (currentMethod == LoginMethod.otp && !viewModel.isOtpSent
                ? 'OTP Sent Successfully'
                : 'Login Successful'),
      );

      if (currentMethod == LoginMethod.password ||
          (currentMethod == LoginMethod.otp &&
              viewModel.isOtpSent &&
              result['message'] != 'OTP sent successfully')) {
        await Future.delayed(const Duration(seconds: 1));
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.bottomNav, (route) => false);
      }
    } else {
      CustomSnackBar.showError(
        context,
        result['message'] ?? 'An error occurred',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(builder: (context, viewModel, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: isMobile ? double.infinity : 520),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? R.w(20) : R.w(36),
                      0,
                      isMobile ? R.w(20) : R.w(36),
                      MediaQuery.of(context).viewInsets.bottom + R.h(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(isMobile),
                        SizedBox(height: R.h(32)),
                        _buildMethodSelector(viewModel),
                        SizedBox(height: R.h(20)),
                        _buildPrimaryField(viewModel),
                        SizedBox(height: R.h(20)),
                        _buildSecondaryField(context, viewModel),
                        SizedBox(height: R.h(16)),
                        _buildActionButton(context, viewModel),
                        SizedBox(height: R.h(20)),
                        _buildSupportText(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // UI Parts

  Widget _buildHeader(bool isMobile) {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'assets/images/app_logo.png',
            width: isMobile ? R.w(220) : R.w(300),
          ),
        ),
        SizedBox(height: R.h(20)),
        Text(
          'Welcome Back, Agent',
          style: AppTextStyles.heading.copyWith(fontSize: R.sp(22)),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: R.h(6)),
        Text(
          'Enter your credentials to start your shift.',
          style: AppTextStyles.subHeading.copyWith(fontSize: R.sp(14)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMethodSelector(AuthViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Login', style: AppTextStyles.label.copyWith(fontSize: R.sp(14))),
        SizedBox(height: R.h(8)),
        Container(
          padding: EdgeInsets.all(R.w(6)),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBg,
            borderRadius: BorderRadius.circular(R.r(14)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    viewModel.switchMethod(LoginMethod.password);
                    _emailOrIdController.clear();
                    _passwordController.clear();
                  },
                  child: _methodButton(
                    text: 'Agent ID & Password',
                    active: viewModel.loginMethod == LoginMethod.password,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    viewModel.switchMethod(LoginMethod.otp);
                    _mobileController.clear();
                    _otpController.clear();
                  },
                  child: _methodButton(
                    text: 'OTP',
                    active: viewModel.loginMethod == LoginMethod.otp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryField(AuthViewModel viewModel) {
    final isOtp = viewModel.loginMethod == LoginMethod.otp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOtp ? 'Mobile Number' : 'Agent ID',
          style: AppTextStyles.label.copyWith(fontSize: R.sp(14)),
        ),
        SizedBox(height: R.h(8)),
        TextField(
          controller: isOtp ? _mobileController : _emailOrIdController,
          keyboardType: isOtp ? TextInputType.phone : TextInputType.text,
          maxLength: isOtp ? 10 : null,
          cursorColor: AppColors.primaryGreen,
          decoration: InputDecoration(
            hintText: isOtp ? 'Enter mobile number' : 'Enter your username',
            prefixIcon: Icon(
              isOtp ? RemixIcons.phone_line : RemixIcons.user_3_line,
              color: AppColors.inputIcon,
              size: R.sp(18),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryField(BuildContext context, AuthViewModel viewModel) {
    if (viewModel.loginMethod == LoginMethod.password) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Password',
              style: AppTextStyles.label.copyWith(fontSize: R.sp(14))),
          SizedBox(height: R.h(8)),
          TextField(
            controller: _passwordController,
            obscureText: viewModel.obscurePassword,
            cursorColor: AppColors.primaryGreen,
            decoration: InputDecoration(
              hintText: '********',
              prefixIcon: Icon(
                RemixIcons.lock_password_line,
                color: AppColors.inputIcon,
                size: R.sp(18),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  viewModel.obscurePassword
                      ? RemixIcons.eye_off_line
                      : RemixIcons.eye_line,
                  color: AppColors.inputIcon,
                  size: R.sp(18),
                ),
                onPressed: () => viewModel.togglePasswordVisibility(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.forgotPassword);
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: R.sp(14),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: viewModel.isOtpSent,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OTP',
                  style: AppTextStyles.label.copyWith(fontSize: R.sp(14))),
              SizedBox(height: R.h(8)),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                cursorColor: AppColors.primaryGreen,
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  prefixIcon: Icon(
                    RemixIcons.message_3_line,
                    color: AppColors.inputIcon,
                    size: R.sp(18),
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: viewModel.isOtpSent &&
              viewModel.timerValue ==
                  0, // Show Only when OTP IS sent AND timer is 0
          maintainSize: true, // Maintain size to avoid jumps
          maintainAnimation: true,
          maintainState: true,
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final result =
                    await viewModel.resendOtp(_mobileController.text.trim());
                if (!context.mounted) return;

                if (result['success']) {
                  CustomSnackBar.showSuccess(context, result['message']!);
                } else {
                  CustomSnackBar.showError(context, result['message']!);
                }
              },
              child: Text(
                'Resend Code',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: R.sp(14),
                ),
              ),
            ),
          ),
        ),
        if (viewModel.isOtpSent && viewModel.timerValue > 0)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(
                  top: R.h(12), bottom: R.h(12), right: R.w(12)),
              child: Text(
                'Resend Code in ${viewModel.timerValue} s',
                style: TextStyle(
                  color: AppColors.bodyText,
                  fontWeight: FontWeight.w500,
                  fontSize: R.sp(14),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, AuthViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: R.h(54),
      child: ElevatedButton(
        onPressed:
            viewModel.isLoading ? null : () => _handleLogin(context, viewModel),
        child: viewModel.isLoading
            ? SizedBox(
                height: R.h(24),
                width: R.h(24),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                viewModel.loginMethod == LoginMethod.password
                    ? 'Log In →'
                    : (viewModel.isOtpSent
                        ? 'Verify Mobile Number →'
                        : 'Send OTP →'),
                style: TextStyle(fontSize: R.sp(16)),
              ),
      ),
    );
  }

  Widget _buildSupportText() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Having trouble? ',
          style: AppTextStyles.subHeading.copyWith(fontSize: R.sp(14)),
          children: const [
            TextSpan(
              text: 'Contact Support',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodButton({required String text, required bool active}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: R.h(14)),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryGreen : AppColors.transparent,
        borderRadius: BorderRadius.circular(R.r(12)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: R.sp(14),
            fontWeight: FontWeight.w600,
            color: active ? AppColors.black : AppColors.bodyText,
          ),
        ),
      ),
    );
  }
}
