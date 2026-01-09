class AppUrls {
  static const String baseUrl = 'http://192.168.1.36:8000';
  static const String loginPassword = '$baseUrl/api/auth/login/password';
  static const String loginOtp = '$baseUrl/api/auth/login/otp/';
  static const String verifyOtp = '$baseUrl/api/auth/mobile/verify-otp/login';
  static const String resendOtp = '$baseUrl/api/auth/mobile/resend-otp';
  static const String forgotPasswordSendOtp =
      '$baseUrl/api/auth/forgot-password/send-otp';
  static const String verifyForgotPasswordOtp =
      '$baseUrl/api/auth/mobile/verify-otp/forgot';
  static const String resetPassword = '$baseUrl/api/auth/reset-password';
  static const String logout = '$baseUrl/api/auth/logout';
  static const String partnerOffline = '$baseUrl/api/partner/status/offline';
  static const String partnerOnline = '$baseUrl/api/partner/status/online';
  static const String newOrders = '$baseUrl/api/delivery/orders/new';

  static const String myOrders = '$baseUrl/api/delivery/orders/queue';
  static const String productImages = '$baseUrl/storage/product_images/';
  static String acceptOrder(int id) =>
      '$baseUrl/api/delivery/orders/$id/accept';
  static String rejectOrder(int id) =>
      '$baseUrl/api/delivery/orders/$id/reject';
  static String orderDetails(int id) => '$baseUrl/api/orders/$id';
  static String orderItems(int id) => '$baseUrl/api/orders/$id/items';
  static String pickupOrder(int id) => '$baseUrl/api/orders/$id/pickup';
}
