import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_status_model.dart';
import 'package:samrudhi_delivery_agent_app/model/user_model.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/model/notification_model.dart';
import 'package:samrudhi_delivery_agent_app/model/profile_model.dart';
import 'package:samrudhi_delivery_agent_app/model/cancellation_reason_model.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_summary_model.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_summary_model.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_performance_model.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';

import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';

class ApiService {
  Future<Map<String, String>> _getHeaders([String? token]) async {
    String? authToken = token;
    if (authToken == null || authToken.isEmpty) {
      authToken = await SharedPrefsUtil.getToken();
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization':
            authToken.startsWith('Bearer ') ? authToken : 'Bearer $authToken',
    };
  }

  Future<dynamic> _processRequest(
      Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } on FormatException {
      throw ValidationException('Bad response format');
    } catch (e) {
      if (e is AppException) rethrow;
      if (e.toString().contains('Timeout')) {
        throw TimeoutException(
            'Connection timed out. Please check your internet connection.');
      }
      throw AppException(e.toString());
    }
  }

  static final StreamController<void> authErrorController =
      StreamController<void>.broadcast();

  dynamic _handleResponse(http.Response response) {
    log('API Response URL: ${response.request?.url}');
    log('API Response Status: ${response.statusCode}');
    log('API Response Body: ${response.body}');

    try {
      final jsonResponse = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
        case 201:
          return jsonResponse;
        case 400:
        case 422: // Handle Validation/Business Logic Errors
          throw ValidationException(
              jsonResponse['message'] ?? 'Invalid request');
        case 401:
        case 403:
          authErrorController.add(null); // Trigger global logout
          throw UnauthorisedException(
              jsonResponse['message'] ?? 'Unauthorised');
        case 404:
          throw ValidationException(jsonResponse['message'] ?? 'Not found');
        case 500:
        default:
          throw ServerException(
              jsonResponse['message'] ?? 'Server error occurred');
      }
    } on FormatException {
      throw ServerException('Error parsing server response');
    }
  }

  Future<LoginResponse> loginWithPassword(
      String username, String password) async {
    final uri = Uri.parse(AppUrls.loginPassword);
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'username': username, 'password': password}),
        ));

    return LoginResponse.fromJson(response);
  }

  Future<void> logout(String? token) async {
    final uri = Uri.parse(AppUrls.logout);
    log('API Request: POST $uri');

    // Helper handles sanitized token check if we pass it, but _getHeaders logic is safer
    // We can rely on _getHeaders now. But wait, existing logic removed "Bearer " prefix if present.
    // _getHeaders handles "Bearer " adding.
    // If usage sends "Bearer ", _getHeaders might double it?
    // Current logic: sanitizedToken = token.startsWith... ? substring : token.
    // New logic: _getHeaders assumes raw token in prefs.
    // If `token` arg has Bearer, we should sanitize it before passing?
    // Or just let _getHeaders handle it?
    // Let's pass token null-coalesced or just token.

    final headers = await _getHeaders(token);

    await _processRequest(() => http.post(
          uri,
          headers: headers,
        ));
  }

  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    final uri = Uri.parse(AppUrls.loginOtp);
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'mobile': mobile}),
        ));
    return response;
  }

  Future<double> getLoginHours(String? token) async {
    final uri = Uri.parse(AppUrls.loginHours);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true && response['totalHours'] != null) {
      return (response['totalHours'] as num).toDouble();
    }
    return 0.0;
  }

  Future<int> getTotalOrders(String? token) async {
    final uri = Uri.parse(AppUrls.totalOrders);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true && response['totalOrders'] != null) {
      return (response['totalOrders'] as num).toInt();
    }
    return 0;
  }

  Future<LoginResponse> verifyOtp(String mobile, String otp) async {
    final uri = Uri.parse(AppUrls.verifyOtp);
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'mobile': mobile, 'otp': otp}),
        ));

    if (response['status'] == true) {
      return LoginResponse.fromJson(response);
    } else {
      throw ValidationException(
          response['message'] ?? 'OTP Verification failed');
    }
  }

  Future<Map<String, dynamic>> resendOtp(String mobile) async {
    final uri = Uri.parse(AppUrls.resendOtp);
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'mobile': mobile}),
        ));
    return response;
  }

  Future<Map<String, dynamic>> sendForgotPasswordOtp(String mobile) async {
    final uri = Uri.parse(AppUrls.forgotPasswordSendOtp);
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'mobile': mobile}),
        ));
    return response;
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp(
      String mobile, String otp) async {
    final uri = Uri.parse(AppUrls.verifyForgotPasswordOtp);
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'mobile': mobile, 'otp': otp}),
        ));
    return response;
  }

  Future<Map<String, dynamic>> resetPassword(
      String mobile, String password) async {
    final uri = Uri.parse(AppUrls.resetPassword);
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({
            'mobile': mobile,
            'password': password,
            'password_confirmation': password,
          }),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Password reset failed');
    }
  }

  Future<Map<String, dynamic>> updateAgentStatus(
      String? token, bool isOnline) async {
    // isOnline = true -> Start Duty
    // isOnline = false -> Stop Duty (Offline)
    final uri = Uri.parse(isOnline ? AppUrls.startDuty : AppUrls.stopDuty);
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to update status');
    }
  }

  Future<Map<String, dynamic>> pauseAgentDuty(String? token) async {
    final uri = Uri.parse(AppUrls.pauseDuty);
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to pause duty');
    }
  }

  Future<Map<String, dynamic>> resumeAgentDuty(String? token) async {
    final uri = Uri.parse(AppUrls.resumeDuty);
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to resume duty');
    }
  }

  Future<Map<String, dynamic>> stopAgentDuty(String? token) async {
    final uri = Uri.parse(AppUrls.stopDuty);
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to stop duty');
    }
  }

  Future<ProfileResponse> getProfile(String? token) async {
    final uri = Uri.parse(AppUrls.profile);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));
    return ProfileResponse.fromJson(response);
  }

  Future<PartnerSummary> getPartnerProfileSummary(String? token) async {
    final uri = Uri.parse(AppUrls.partnerProfileSummary);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));
    return PartnerSummary.fromJson(response);
  }

  Future<List<DailyPerformance>> getPartnerPerformanceGraph(
      String token) async {
    final uri = Uri.parse(AppUrls.partnerPerformanceGraph);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    return PartnerPerformanceModel.fromJson(response).data;
  }

  Future<Map<String, dynamic>> updateProfilePhone(
      String? token, String phone) async {
    final uri = Uri.parse(AppUrls.updateProfilePhone);
    log('API Request: PUT $uri');

    final response = await _processRequest(() async => http.put(
          uri,
          headers: await _getHeaders(token),
          body: jsonEncode({'phone': phone}),
        ));
    return response;
  }

  Future<Map<String, dynamic>> updateProfileEmail(
      String? token, String email) async {
    final uri = Uri.parse(AppUrls.updateProfileEmail);
    log('API Request: PUT $uri');

    final response = await _processRequest(() async => http.put(
          uri,
          headers: await _getHeaders(token),
          body: jsonEncode({'email': email}),
        ));
    return response;
  }

  Future<Map<String, dynamic>> updateProfileVehicle(
      String? token, String vehicleType, String vehicleNumber) async {
    final uri = Uri.parse(AppUrls.updateProfileVehicle);
    log('API Request: PUT $uri');

    final response = await _processRequest(() async => http.put(
          uri,
          headers: await _getHeaders(token),
          body: jsonEncode({
            'vehicle_type': vehicleType,
            'vehicle_number': vehicleNumber,
          }),
        ));
    return response;
  }

  Future<String?> uploadProfileImage(String token, File imageFile) async {
    final uri = Uri.parse(AppUrls.uploadProfileImage);
    log('API Request: POST Multipart $uri');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    try {
      final multipartFile = await http.MultipartFile.fromPath(
        'profile_photo',
        imageFile.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body['status'] == true) {
          return body['imageUrl'];
        }
        return null;
      } else {
        final body = jsonDecode(response.body);
        throw ValidationException(body['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      log('Error uploading profile image: $e');
      rethrow;
    }
  }

  Future<OrderResponse> getNewOrders(String? token, {int page = 1}) async {
    final uri = Uri.parse('${AppUrls.newOrders}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> confirmPickup(String? token, int orderId) async {
    final uri = Uri.parse(AppUrls.pickupOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to complete pickup');
    }
  }

  Future<OrderResponse> getMyOrders(String? token, {int page = 1}) async {
    final uri = Uri.parse('${AppUrls.myOrders}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<OrderResponse> getDeliveries(String? token, {int page = 1}) async {
    final uri = Uri.parse('${AppUrls.deliveries}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<OrderResponse> searchDeliveries(String? token, String query,
      {int page = 1}) async {
    final uri =
        Uri.parse('${AppUrls.searchDeliveries}?query=$query&page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<DeliveryStatusResponse> getDeliveryStatus(String? token) async {
    final uri = Uri.parse(AppUrls.deliveryStatus);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    return DeliveryStatusResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> acceptOrder(String? token, int orderId) async {
    final uri = Uri.parse(AppUrls.acceptOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to accept order');
    }
  }

  Future<Map<String, dynamic>> rejectOrder(String? token, int orderId) async {
    final uri = Uri.parse(AppUrls.rejectOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to reject order');
    }
  }

  Future<Order> getOrderDetails(String? token, int orderId) async {
    final uri = Uri.parse(AppUrls.orderDetails(orderId));
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true && response['data'] != null) {
      return Order.fromJson(response['data']);
    } else {
      throw ValidationException(response['message'] ?? 'Failed to parse order');
    }
  }

  Future<List<OrderItem>> getOrderItems(String? token, int orderId) async {
    final uri = Uri.parse(AppUrls.orderItems(orderId));
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => OrderItem.fromJson(e))
          .toList();
    } else {
      throw ValidationException(response['message'] ?? 'Failed to parse items');
    }
  }

  Future<bool> uploadPickupProof(
      String token, int orderId, File imageFile) async {
    final uri = Uri.parse(AppUrls.pickupProof(orderId));
    log('API Request: POST Multipart $uri');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    try {
      final multipartFile = await http.MultipartFile.fromPath(
        'pickup_proof',
        imageFile.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        final body = jsonDecode(response.body);
        throw ValidationException(body['message'] ?? 'Failed to upload proof');
      }
    } catch (e) {
      log('Error uploading proof: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOrderItem(
      String? token, int orderId, int itemId) async {
    final uri = Uri.parse(AppUrls.verifyOrderItem(orderId, itemId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to verify item');
    }
  }

  Future<Map<String, dynamic>> reportItemIssue(String? token, int orderId,
      int itemId, String issueType, String? description) async {
    final uri = Uri.parse(AppUrls.reportItemIssue(orderId, itemId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
          body: jsonEncode({
            'issue_type': issueType,
            'description': description,
          }),
        ));

    if (response['status'] == true || response['message'] != null) {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to report issue');
    }
  }

  Future<Map<String, dynamic>> cancelOrder(
      String? token, int orderId, int reasonId) async {
    final uri = Uri.parse(AppUrls.cancelOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
          body: jsonEncode({
            'reasonId': reasonId,
            'reason_id': reasonId,
          }),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to cancel order');
    }
  }

  Future<Map<String, dynamic>?> getCurrentOrder(String token) async {
    final uri = Uri.parse(AppUrls.currentOrder);
    // log('API Request: GET $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      log('Check Current Order Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data'];
        }
      } else if (response.statusCode == 404) {
        // Expected case: No active order. Return null to indicate no order.
        return null;
      }
      return null;
    } catch (e) {
      log('Check Current Order Error (SILENT): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> completeDelivery(
      String? token, int orderId, String otp) async {
    final uri = Uri.parse(AppUrls.completeDelivery(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
          body: jsonEncode({
            'otp': otp,
          }),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to complete delivery');
    }
  }

  Future<void> sendDeliveryOtp(String? token, int orderId) async {
    final uri = Uri.parse(AppUrls.sendDeliveryOtp(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] != true) {
      throw ValidationException(
          response['message'] ?? 'Failed to send delivery OTP');
    }
  }

  Future<void> resendDeliveryOtp(String? token, int orderId) async {
    final uri = Uri.parse(AppUrls.resendDeliveryOtp(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] != true) {
      throw ValidationException(
          response['message'] ?? 'Failed to resend delivery OTP');
    }
  }

  Future<Map<String, dynamic>> getOrderSummary(
      String? token, int orderId) async {
    final uri = Uri.parse(AppUrls.getSummary(orderId));
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true && response['data'] != null) {
      return response['data'];
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to fetch order summary');
    }
  }

  Future<Map<String, dynamic>> rateCustomer(
      String? token, int orderId, double rating, String? comment) async {
    final uri = Uri.parse(AppUrls.rateCustomer(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
          body: jsonEncode({
            'rating': rating,
            'comment': comment,
          }),
        ));

    if (response['status'] == true || response['message'] != null) {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to rate customer');
    }
  }

  // ================= NOTIFICATIONS =================

  Future<NotificationResponse> getNotifications(String? token,
      {int page = 1}) async {
    final uri = Uri.parse('${AppUrls.notifications}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    return NotificationResponse.fromJson(response);
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(
      String? token, String notificationId) async {
    final uri = Uri.parse('${AppUrls.notifications}/$notificationId/read');
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(token),
        ));

    return response['status'] == true || response['status'] == 'success';
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings(String? token) async {
    final uri = Uri.parse('${AppUrls.notifications}/settings');
    log('API Request: GET $uri');

    return await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));
  }

  /// Update notification settings
  Future<Map<String, dynamic>> updateNotificationSettings(
      String? token, Map<String, bool> settings) async {
    final uri = Uri.parse('${AppUrls.notifications}/settings');
    log('API Request: PUT $uri');

    return await _processRequest(() async => http.put(
          uri,
          headers: await _getHeaders(token),
          body: jsonEncode(settings),
        ));
  }

  Future<List<CancellationReason>> getCancellationReasons(String? token) async {
    final uri = Uri.parse(AppUrls.cancellationReasons);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response is List) {
      return response.map((e) => CancellationReason.fromJson(e)).toList();
    } else if (response['data'] is List) {
      return (response['data'] as List)
          .map((e) => CancellationReason.fromJson(e))
          .toList();
    }

    return [];
  }

  Future<DeliverySummary> getDeliverySummary(String? token,
      {required String dateRange, String? fromDate, String? toDate}) async {
    String url = '${AppUrls.deliverySummary}?dateRange=$dateRange';
    if (dateRange == 'custom' && fromDate != null && toDate != null) {
      url += '&fromDate=$fromDate&toDate=$toDate';
    }
    final uri = Uri.parse(url);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(token),
        ));

    if (response['status'] == true && response['data'] != null) {
      return DeliverySummary.fromJson(response['data']);
    }

    // Fallback or empty if structure differs
    return DeliverySummary.fromJson(response);
  }
}
