class AppUrls {
  static const String baseUrl = 'http://192.168.1.46:8000';
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
  static const String startDuty = '$baseUrl/api/partner/duty/start';
  static const String pauseDuty = '$baseUrl/api/partner/duty/pause';
  static const String resumeDuty = '$baseUrl/api/partner/duty/resume';
  static const String stopDuty = '$baseUrl/api/partner/duty/stop';
  static const String resetDuty = '$baseUrl/api/partner/duty/reset';
  static const String profile = '$baseUrl/api/delivery_boy/profile';
  static const String updateProfilePhone =
      '$baseUrl/api/delivery_boy/profile/phone';
  static const String updateProfileVehicle =
      '$baseUrl/api/delivery_boy/profile/vehicle';
  static const String updateProfileEmail =
      '$baseUrl/api/delivery_boy/profile/email';
  static const String uploadProfileImage = '$baseUrl/api/partner/profile/image';
  static const String pendingList = '$baseUrl/api/orders/pending';
  static const String newOrders = '$baseUrl/api/delivery/orders/new';
  static const String availableOrders =
      '$baseUrl/api/delivery/orders/available';
  static const String myOrders = '$baseUrl/api/delivery/orders/queue';
  static const String deliveries = '$baseUrl/api/deliveries';
  static const String searchDeliveries = '$baseUrl/api/deliveries/search';
  static const String deliveryStatus = '$baseUrl/api/deliveries/status';
  static const String productImages = '$baseUrl/storage/product_images/';
  static String acceptOrder(int id) =>
      '$baseUrl/api/delivery/orders/$id/accept';
  static String rejectOrder(int id) =>
      '$baseUrl/api/delivery/orders/$id/reject';
  static String cancelOrder(int id) => '$baseUrl/api/orders/$id/cancel';
  static String orderDetails(int id) => '$baseUrl/api/orders/$id';
  static String startOrder(int id) => '$baseUrl/api/orders/$id/start';
  static String completeOrder(int id) => '$baseUrl/api/orders/$id/complete';
  static String markPending(int id) => '$baseUrl/api/orders/$id/pending';
  static const String cancellationReasons =
      '$baseUrl/api/orders/cancellation-reasons';
  static const String currentOrder = '$baseUrl/api/partner/orders/current';
  static String orderItems(int id) => '$baseUrl/api/orders/$id/items';
  static String pickupOrder(int id) =>
      '$baseUrl/api/orders/$id/pickup/complete';
  static String getSummary(int id) => '$baseUrl/api/orders/$id/summary';
  static String pickupProof(int id) => '$baseUrl/api/orders/$id/pickup-proof';
  static String verifyOrderItem(int orderId, int itemId) =>
      '$baseUrl/api/orders/$orderId/items/$itemId/verify';
  static String reportItemIssue(int orderId, int itemId) =>
      '$baseUrl/api/orders/$orderId/items/$itemId/issue';
  static String sendDeliveryOtp(int id) =>
      '$baseUrl/api/partner/orders/$id/delivery/send-otp';
  static String resendDeliveryOtp(int id) =>
      '$baseUrl/api/partner/orders/$id/delivery/resend-otp';
  static String completeDelivery(int id) =>
      '$baseUrl/api/partner/orders/$id/delivery/verify-otp';
  static String rateCustomer(int id) => '$baseUrl/api/orders/$id/rate-customer';

  static const String notifications = '$baseUrl/api/notifications';
  static const String loginHours = '$baseUrl/api/partner/stats/login-hours';
  static const String totalOrders = '$baseUrl/api/partner/status/orders';
  static const String deliverySummary =
      '$baseUrl/api/partner/deliveries/summary';
  static const String partnerProfileSummary =
      '$baseUrl/api/partner/profile/summary';
  static const String partnerPerformanceGraph =
      '$baseUrl/api/partner/performance/graph';
  static const String partnerPerformanceMonth =
      '$baseUrl/api/partner/performance/month';
  static const String partnerPerformanceWeek =
      '$baseUrl/api/partner/performance/week';
}
