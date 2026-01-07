class AppUrl {
  AppUrl._();

  static const String baseUrl = "http://192.168.1.36:8000";
  static const String loginWithEmail = "$baseUrl/api/auth/email/login";
  static const String sendOtp = "$baseUrl/api/auth/mobile/send-otp";
}
