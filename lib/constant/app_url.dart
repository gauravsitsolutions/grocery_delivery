class AppUrls {
  static const String baseUrl = 'http://192.168.1.36:8000';
  static const String loginPassword = '$baseUrl/api/auth/login/password';
  static const String loginOtp = '$baseUrl/api/auth/login/otp/';
  static const String verifyOtp = '$baseUrl/api/auth/mobile/verify-otp/login';
  static const String resendOtp = '$baseUrl/api/auth/mobile/resend-otp';
  static const String forgotPasswordSendOtp = '$baseUrl/api/auth/forgot-password/send-otp';
  static const String verifyForgotPasswordOtp = '$baseUrl/api/auth/forgot-password/verify-otp';
  static const String resetPassword = '$baseUrl/api/auth/reset-password';
  static const String logout = '$baseUrl/api/auth/logout';
  static const String partnerOffline = '$baseUrl/api/partner/status/offline';
  static const String partnerOnline = '$baseUrl/api/partner/status/online';
}
