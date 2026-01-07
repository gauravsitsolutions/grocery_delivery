import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/res/styles/app_text_styles.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

enum LoginMethod { password, otp }

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;
  LoginMethod _loginMethod = LoginMethod.password;
  bool _isOtpSent = false;
  // ignore: unused_field
  int _start = 30; 
  Timer? _timer;


  final _emailOrIdController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _emailOrIdController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  
  void _startTimer() {
    setState(() {
      _start = 30;
      _timer?.cancel();
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void _switchMethod(LoginMethod method) {
    if (_loginMethod == method) return;
    setState(() {
      _loginMethod = method;
      _emailOrIdController.clear();
      _mobileController.clear();
      _passwordController.clear();
      _passwordController.clear();
      _otpController.clear();
    });
  }

  void _handleLogin() {
    if (_loginMethod == LoginMethod.password) {
      if (_emailOrIdController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        _showError('Please enter ID and password');
        return;
      }
      Navigator.pushNamed(context, AppRoutes.bottomNav);
    } else {
      if (_mobileController.text.length != 10) {
        _showError('Enter valid mobile number');
        return;
      }
      
      if (!_isOtpSent) {
        // Send OTP logic here
        setState(() {
          _isOtpSent = true;
          _startTimer();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
        return;
      }

      if (_otpController.text.length < 4) {
        _showError('Please enter valid OTP');
        return;
      }
      Navigator.pushNamed(context, AppRoutes.bottomNav);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text(message,
            style: TextStyle(color: AppColors.white, fontSize: R.sp(14))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.scaffoldBg,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: isMobile ? double.infinity : 520),
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
                    _buildMethodSelector(),
                    SizedBox(height: R.h(20)),
                    _buildPrimaryField(),
                    SizedBox(height: R.h(20)),
                    _buildSecondaryField(),
                    SizedBox(height: R.h(16)),
                    _buildActionButton(),
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

  Widget _buildMethodSelector() {
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
                  onTap: () => _switchMethod(LoginMethod.password),
                  child: _methodButton(
                    text: 'Agent ID & Password',
                    active: _loginMethod == LoginMethod.password,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchMethod(LoginMethod.otp),
                  child: _methodButton(
                    text: 'OTP',
                    active: _loginMethod == LoginMethod.otp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryField() {
    final isOtp = _loginMethod == LoginMethod.otp;

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
            hintText: isOtp ? 'Enter mobile number' : 'Enter your ID',
            prefixIcon: Icon(
              isOtp ? RemixIcons.phone_line : RemixIcons.id_card_line,
              color: AppColors.inputIcon,
              size: R.sp(18),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryField() {
    if (_loginMethod == LoginMethod.password) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Password',
              style: AppTextStyles.label.copyWith(fontSize: R.sp(14))),
          SizedBox(height: R.h(8)),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
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
                  _obscurePassword
                      ? RemixIcons.eye_off_line
                      : RemixIcons.eye_line,
                  color: AppColors.inputIcon,
                  size: R.sp(18),
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
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
          visible: _isOtpSent,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OTP', style: AppTextStyles.label.copyWith(fontSize: R.sp(14))),
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
          visible: _isOtpSent && _start == 0, // Show Only when OTP IS sent AND timer is 0
          maintainSize: true, // Maintain size to avoid jumps
          maintainAnimation: true,
          maintainState: true,
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _startTimer(); // Restart timer on resend
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP Resent successfully')),
                );
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
        if(_isOtpSent && _start > 0)
           Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(top: R.h(12), bottom: R.h(12), right: R.w(12)),
              child: Text(
                'Resend Code in $_start s',
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

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: R.h(54),
      child: ElevatedButton(
        onPressed: _handleLogin,
        child: Text(
          _loginMethod == LoginMethod.password
              ? 'Log In →'
              : (_isOtpSent ? 'Verify Mobile Number →' : 'Send OTP →'),
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
