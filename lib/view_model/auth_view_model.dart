import 'dart:async';
import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';
import 'package:samrudhi_delivery_agent_app/auth/login/login_view.dart'; // For LoginMethod enum

class AuthViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State Variables
  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _obscurePassword = true;
  LoginMethod _loginMethod = LoginMethod.password;
  int _start = 30;
  Timer? _timer;

  // Getters
  bool get isLoading => _isLoading;
  bool get isOtpSent => _isOtpSent;
  bool get obscurePassword => _obscurePassword;
  LoginMethod get loginMethod => _loginMethod;
  int get timerValue => _start;

  // Methods

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void switchMethod(LoginMethod method) {
    if (_loginMethod == method) return;
    _loginMethod = method;
    _cancelTimer();
    _isOtpSent = false;
    _start = 30;
    notifyListeners();
  }

  void _startTimer() {
    _start = 30;
    _cancelTimer();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          timer.cancel();
          notifyListeners();
        } else {
          _start--;
          notifyListeners();
        }
      },
    );
    notifyListeners();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  // API Calls

  Future<Map<String, dynamic>> loginWithPassword(
      String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Please enter ID and password'};
    }

    _setLoading(true);

    try {
      final response = await _apiService.loginWithPassword(username, password);

      if (response.status) {
        if (response.token != null) {
          await SharedPrefsUtil.saveUserSession(
            token: response.token!,
            userName: response.user?.name ?? '',
            agentId: '', // Update if agent_id becomes available
            userId: response.user?.id.toString() ?? '',
          );
        }
        _setLoading(false);
        return {'success': true};
      } else {
        _setLoading(false);
        return {
          'success': false,
          'message':
              response.message.isNotEmpty ? response.message : 'Login failed'
        };
      }
    } catch (e) {
      _setLoading(false);
      return {
        'success': false,
        'message': e is AppException
            ? e.message
            : e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    if (mobile.length != 10) {
      return {'success': false, 'message': 'Enter valid mobile number'};
    }

    _setLoading(true);

    try {
      await _apiService.sendOtp(mobile);
      _isOtpSent = true;
      _startTimer();
      _setLoading(false);
      return {'success': true, 'message': 'OTP sent successfully'};
    } catch (e) {
      _setLoading(false);
      return {
        'success': false,
        'message': e is AppException
            ? e.message
            : e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  Future<Map<String, dynamic>> resendOtp(String mobile) async {
    _setLoading(true);
    try {
      await _apiService.resendOtp(mobile);
      _startTimer();
      _setLoading(false);
      return {'success': true, 'message': 'OTP Resent successfully'};
    } catch (e) {
      _setLoading(false);
      return {
        'success': false,
        'message': e is AppException
            ? e.message
            : e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String mobile, String otp) async {
    if (otp.length < 4) {
      return {'success': false, 'message': 'Please enter valid OTP'};
    }

    _setLoading(true);

    try {
      final response = await _apiService.verifyOtp(mobile, otp);

      if (response.status) {
        if (response.token != null) {
          await SharedPrefsUtil.saveUserSession(
            token: response.token!,
            userName: response.user?.name ?? '',
            agentId: '', // Update if agent_id becomes available
            userId: response.user?.id.toString() ?? '',
          );
        }
        _setLoading(false);
        return {'success': true, 'message': 'Login Successful'};
      } else {
        _setLoading(false);
        return {
          'success': false,
          'message':
              response.message.isNotEmpty ? response.message : 'Invalid OTP'
        };
      }
    } catch (e) {
      _setLoading(false);
      return {
        'success': false,
        'message': e is AppException
            ? e.message
            : e.toString().replaceAll('Exception: ', '')
      };
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
