import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_status_model.dart';
import 'package:samrudhi_delivery_agent_app/model/user_model.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/model/notification_model.dart';
import 'package:samrudhi_delivery_agent_app/model/profile_model.dart';
import 'package:samrudhi_delivery_agent_app/model/cancellation_reason_model.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_summary_model.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_history_model.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_summary_model.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_performance_model.dart';
import 'package:samrudhi_delivery_agent_app/model/duty_slot_model.dart';
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
    bool hasInternet = await InternetConnectionChecker.instance.hasConnection;
    if (!hasInternet) {
      throw NetworkException('No internet connection');
    }

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

  Future<void> logout() async {
    final uri = Uri.parse(AppUrls.logout);
    log('API Request: POST $uri');

    final headers = await _getHeaders();

    await _processRequest(() => http.post(
          uri,
          headers: headers,
        ));
  }

  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    final uri = Uri.parse(AppUrls.loginOtp);
    log('API Request: POST $uri');
    debugPrint('📤 [Login OTP] Sending OTP to mobile: $mobile');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'mobile': mobile}),
        ));

    final dynamic otp = response['otp'] ?? response['data']?['otp'];
    if (otp != null) {
      log('Login OTP Received: $otp');
      debugPrint('🔑 [Login OTP] Received OTP from server: $otp');
    }
    return response;
  }

  Future<double> getLoginHours() async {
    final uri = Uri.parse(AppUrls.loginHours);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true && response['totalHours'] != null) {
      return (response['totalHours'] as num).toDouble();
    }
    return 0.0;
  }

  Future<int> getTotalOrders() async {
    final uri = Uri.parse(AppUrls.totalOrders);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true && response['totalOrders'] != null) {
      return (response['totalOrders'] as num).toInt();
    }
    return 0;
  }

  Future<LoginResponse> verifyOtp(String mobile, String otp) async {
    final uri = Uri.parse(AppUrls.verifyOtp);
    log('API Request: POST $uri | Body: {mobile: $mobile, otp: $otp}');
    debugPrint('🚀 [Login OTP Verification] Verifying OTP: "$otp" for Mobile: $mobile');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'mobile': mobile, 'otp': otp}),
        ));

    if (response['status'] == true) {
      debugPrint('✅ [Login OTP Verification] Successfully verified OTP for Mobile: $mobile');
      return LoginResponse.fromJson(response);
    } else {
      debugPrint('❌ [Login OTP Verification] Failed: ${response['message']}');
      throw ValidationException(
          response['message'] ?? 'OTP Verification failed');
    }
  }

  Future<Map<String, dynamic>> resendOtp(String mobile) async {
    final uri = Uri.parse(AppUrls.resendOtp);
    log('API Request: POST $uri');
    debugPrint('🔄 [Login OTP] Resending OTP to mobile: $mobile');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'mobile': mobile}),
        ));

    final dynamic otp = response['otp'] ?? response['data']?['otp'];
    if (otp != null) {
      log('Resent Login OTP Received: $otp');
      debugPrint('🔑 [Login OTP] Received resent OTP from server: $otp');
    }
    return response;
  }

  Future<Map<String, dynamic>> sendForgotPasswordOtp(String mobile) async {
    final uri = Uri.parse(AppUrls.forgotPasswordSendOtp);
    log('API Request: POST $uri');
    debugPrint('📤 [Forgot Password OTP] Sending OTP to mobile: $mobile');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'mobile': mobile}),
        ));

    final dynamic otp = response['otp'] ?? response['data']?['otp'];
    if (otp != null) {
      log('Forgot Password OTP Received: $otp');
      debugPrint('🔑 [Forgot Password OTP] Received OTP from server: $otp');
    }
    return response;
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp(
      String mobile, String otp) async {
    final uri = Uri.parse(AppUrls.verifyForgotPasswordOtp);
    log('API Request: POST $uri | Body: {mobile: $mobile, otp: $otp}');
    debugPrint('🚀 [Forgot Password OTP Verification] Verifying OTP: "$otp" for Mobile: $mobile');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'mobile': mobile, 'otp': otp}),
        ));

    if (response['status'] == true) {
      debugPrint('✅ [Forgot Password OTP Verification] Successfully verified OTP for Mobile: $mobile');
    } else {
      debugPrint('❌ [Forgot Password OTP Verification] Failed: ${response['message']}');
    }
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

  Future<Map<String, dynamic>> updateAgentStatus(bool isOnline) async {
    // isOnline = true -> Start Duty
    // isOnline = false -> Stop Duty (Offline)
    final uri = Uri.parse(isOnline ? AppUrls.startDuty : AppUrls.stopDuty);
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to update status');
    }
  }

  Future<Map<String, dynamic>> pauseAgentDuty() async {
    final uri = Uri.parse(AppUrls.pauseDuty);
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to pause duty');
    }
  }

  Future<Map<String, dynamic>> resumeAgentDuty() async {
    final uri = Uri.parse(AppUrls.resumeDuty);
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to resume duty');
    }
  }

  Future<Map<String, dynamic>> stopAgentDuty() async {
    final uri = Uri.parse(AppUrls.stopDuty);
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to stop duty');
    }
  }

  Future<ProfileResponse> getProfile() async {
    final uri = Uri.parse(AppUrls.profile);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));
    return ProfileResponse.fromJson(response);
  }

  Future<PartnerSummary> getPartnerProfileSummary() async {
    final uri = Uri.parse(AppUrls.partnerProfileSummary);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));
    return PartnerSummary.fromJson(response);
  }

  Future<List<DailyPerformance>> getPartnerPerformanceGraph(
      {String? filter, String? startDate, String? endDate}) async {
    var url = AppUrls.partnerPerformanceGraph;

    // Add query parameters if present
    final queryParams = <String, String>{};
    if (filter != null) queryParams['filter'] = filter;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    if (queryParams.isNotEmpty) {
      final queryString = Uri(queryParameters: queryParams).query;
      url = '$url?$queryString';
    }

    final uri = Uri.parse(url);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    return PartnerPerformanceModel.fromJson(response).data;
  }

  Future<Map<String, dynamic>> updateProfilePhone(String phone) async {
    final uri = Uri.parse(AppUrls.updateProfilePhone);
    log('API Request: PUT $uri');

    final response = await _processRequest(() async => http.put(
          uri,
          headers: await _getHeaders(),
          body: jsonEncode({'phone': phone}),
        ));
    return response;
  }

  Future<Map<String, dynamic>> updateProfileEmail(String email) async {
    final uri = Uri.parse(AppUrls.updateProfileEmail);
    log('API Request: PUT $uri');

    final response = await _processRequest(() async => http.put(
          uri,
          headers: await _getHeaders(),
          body: jsonEncode({'email': email}),
        ));
    return response;
  }

  Future<Map<String, dynamic>> updateProfileVehicle(
      String vehicleType, String vehicleNumber) async {
    final uri = Uri.parse(AppUrls.updateProfileVehicle);
    log('API Request: PUT $uri');

    final response = await _processRequest(() async => http.put(
          uri,
          headers: await _getHeaders(),
          body: jsonEncode({
            'vehicle_type': vehicleType,
            'vehicle_number': vehicleNumber,
          }),
        ));
    return response;
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    final uri = Uri.parse(AppUrls.uploadProfileImage);
    log('API Request: POST Multipart $uri');

    final request = http.MultipartRequest('POST', uri);
    final headers = await _getHeaders();
    request.headers.addAll(headers);

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

  Future<OrderResponse> getNewOrders({int page = 1}) async {
    final uri = Uri.parse('${AppUrls.newOrders}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<OrderResponse> getAvailableOrders({int page = 1}) async {
    final uri = Uri.parse('${AppUrls.availableOrders}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> confirmPickup(int orderId) async {
    final uri = Uri.parse(AppUrls.pickupOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to complete pickup');
    }
  }

  Future<Map<String, dynamic>> startOrder(int orderId) async {
    final uri = Uri.parse(AppUrls.startOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to start order');
    }
  }

  Future<Map<String, dynamic>> completeOrder(int orderId) async {
    final uri = Uri.parse(AppUrls.completeOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to complete order');
    }
  }

  Future<OrderResponse> getMyOrders({int page = 1}) async {
    final uri = Uri.parse('${AppUrls.myOrders}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<DeliveryHistoryResponse> getDeliveries(
      {int page = 1, String? status}) async {
    String url = '${AppUrls.deliveries}?page=$page';
    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }
    final uri = Uri.parse(url);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response is List) {
      // Handle list response if it happens (legacy)
      return DeliveryHistoryResponse(
        status: true,
        summary: DeliveryHistorySummary.empty(),
        inProgress: [],
        deliveries: OrderResponse.fromJson({'data': response, 'status': true}),
      );
    }
    return DeliveryHistoryResponse.fromJson(response);
  }

  Future<OrderResponse> getPendingOrders({int page = 1}) async {
    final uri = Uri.parse('${AppUrls.pendingList}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<OrderResponse> searchDeliveries(String query, {int page = 1}) async {
    final uri =
        Uri.parse('${AppUrls.searchDeliveries}?query=$query&page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<DeliveryStatusResponse> getDeliveryStatus() async {
    final uri = Uri.parse(AppUrls.deliveryStatus);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    return DeliveryStatusResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> acceptOrder(int orderId) async {
    final uri = Uri.parse(AppUrls.acceptOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to accept order');
    }
  }

  Future<Map<String, dynamic>> rejectOrder(int orderId, [int? reasonId]) async {
    final uri = Uri.parse(AppUrls.rejectOrder(orderId));
    log('API Request: POST $uri');

    final body = reasonId != null
        ? jsonEncode({
            'reason_id': reasonId,
            'reasonId': reasonId,
          })
        : null;

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
          body: body,
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to reject order');
    }
  }

  Future<Map<String, dynamic>> markAsPending(int orderId) async {
    final uri = Uri.parse(AppUrls.markPending(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to mark order as pending');
    }
  }

  Future<Order> getOrderDetails(int orderId) async {
    final uri = Uri.parse(AppUrls.orderDetails(orderId));
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true && response['data'] != null) {
      return Order.fromJson(response['data']);
    } else {
      throw ValidationException(response['message'] ?? 'Failed to parse order');
    }
  }

  Future<Map<String, dynamic>> getOrderItems(int orderId) async {
    final uri = Uri.parse(AppUrls.orderItems(orderId));
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    return response;
  }

  Future<bool> uploadPickupProof(int orderId, File imageFile) async {
    final uri = Uri.parse(AppUrls.pickupProof(orderId));
    log('API Request: POST Multipart $uri');

    final request = http.MultipartRequest('POST', uri);
    final headers = await _getHeaders();
    request.headers.addAll(headers);

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

  Future<Map<String, dynamic>> verifyOrderItem(int orderId, int itemId) async {
    final uri = Uri.parse(AppUrls.verifyOrderItem(orderId, itemId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to verify item');
    }
  }

  Future<Map<String, dynamic>> reportItemIssue(
      int orderId, int itemId, String issueType, String? description) async {
    final uri = Uri.parse(AppUrls.reportItemIssue(orderId, itemId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
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

  Future<Map<String, dynamic>> cancelOrder(int orderId, int reasonId) async {
    final uri = Uri.parse(AppUrls.cancelOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
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

  Future<Map<String, dynamic>?> getCurrentOrder() async {
    final uri = Uri.parse(AppUrls.currentOrder);
    // log('API Request: GET $uri');

    try {
      final response = await _processRequest(() async => http.get(
            uri,
            headers: await _getHeaders(),
          ));

      if (response != null && response is Map && response['status'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      if (e is ValidationException &&
          (e.message.contains('404') ||
              e.message.toLowerCase().contains('not found'))) {
        return null;
      }
      log('Check Current Order Error (SILENT): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> completeDelivery(int orderId, String otp) async {
    final uri = Uri.parse(AppUrls.completeDelivery(orderId));
    log('API Request: POST $uri | Body: {otp: $otp, type: delivery}');
    debugPrint('🚀 [Delivery Verification OTP] Verifying OTP: "$otp" for Order ID: $orderId');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
          body: jsonEncode({
            'otp': otp,
            'type': 'delivery',
          }),
        ));

    if (response['status'] == true) {
      log('Delivery Verification OTP verified successfully for Order ID: $orderId');
      debugPrint('✅ [Delivery Verification OTP] Successfully verified OTP for Order ID: $orderId');
      return response;
    } else {
      log('Delivery Verification OTP failed: ${response['message']}');
      debugPrint('❌ [Delivery Verification OTP] Failed for Order ID $orderId: ${response['message']}');
      throw ValidationException(
          response['message'] ?? 'Failed to complete delivery');
    }
  }

  Future<Map<String, dynamic>> sendDeliveryOtp(int orderId) async {
    final uri = Uri.parse(AppUrls.sendDeliveryOtp(orderId));
    log('API Request: POST $uri');
    debugPrint('📤 [Delivery Verification OTP] Requesting OTP send for Order ID: $orderId');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] != true) {
      debugPrint('❌ [Delivery Verification OTP] Failed to send OTP: ${response['message']}');
      throw ValidationException(
          response['message'] ?? 'Failed to send delivery OTP');
    }

    final dynamic otp = response['otp'] ?? response['data']?['otp'];
    if (otp != null) {
      log('Delivery Verification OTP Received: $otp');
      debugPrint('🔑 [Delivery Verification OTP] OTP received from server for Order #$orderId: $otp');
    } else {
      debugPrint('📩 [Delivery Verification OTP] OTP sent successfully for Order #$orderId');
    }

    return response;
  }

  Future<Map<String, dynamic>> resendDeliveryOtp(int orderId) async {
    final uri = Uri.parse(AppUrls.resendDeliveryOtp(orderId));
    log('API Request: POST $uri');
    debugPrint('🔄 [Delivery Verification OTP] Requesting OTP resend for Order ID: $orderId');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] != true) {
      debugPrint('❌ [Delivery Verification OTP] Failed to resend OTP: ${response['message']}');
      throw ValidationException(
          response['message'] ?? 'Failed to resend delivery OTP');
    }

    final dynamic otp = response['otp'] ?? response['data']?['otp'];
    if (otp != null) {
      log('Resent Delivery Verification OTP Received: $otp');
      debugPrint('🔑 [Delivery Verification OTP] Resent OTP received from server for Order #$orderId: $otp');
    } else {
      debugPrint('📩 [Delivery Verification OTP] OTP resent successfully for Order #$orderId');
    }

    return response;
  }

  Future<Map<String, dynamic>> getOrderSummary(int orderId) async {
    final uri = Uri.parse(AppUrls.getSummary(orderId));
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true && response['data'] != null) {
      return response['data'];
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to fetch order summary');
    }
  }

  Future<Map<String, dynamic>> rateCustomer(
      int orderId, double rating, String? comment) async {
    final uri = Uri.parse(AppUrls.rateCustomer(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
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

  Future<NotificationResponse> getNotifications({int page = 1}) async {
    final uri = Uri.parse('${AppUrls.notifications}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    return NotificationResponse.fromJson(response);
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    final uri = Uri.parse('${AppUrls.notifications}/$notificationId/read');
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    return response['status'] == true || response['status'] == 'success';
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final uri = Uri.parse('${AppUrls.notifications}/settings');
    log('API Request: GET $uri');

    return await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));
  }

  /// Update notification settings
  Future<Map<String, dynamic>> updateNotificationSettings(
      Map<String, bool> settings) async {
    final uri = Uri.parse('${AppUrls.notifications}/settings');
    log('API Request: PUT $uri');

    return await _processRequest(() async => http.put(
          uri,
          headers: await _getHeaders(),
          body: jsonEncode(settings),
        ));
  }

  Future<List<CancellationReason>> getCancellationReasons() async {
    final uri = Uri.parse(AppUrls.cancellationReasons);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
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

  Future<DeliverySummary> getDeliverySummary(
      {required String dateRange, String? fromDate, String? toDate}) async {
    String url = '${AppUrls.deliverySummary}?dateRange=$dateRange';
    if (dateRange == 'custom' && fromDate != null && toDate != null) {
      url += '&fromDate=$fromDate&toDate=$toDate';
    }
    final uri = Uri.parse(url);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true) {
      // The response structure is flat: { "status": true, ...fields }
      // So we pass the whole response (excluding status check which we just did)
      // or just pass the whole map to fromJson if it handles it.
      // But our model expects the fields directly.
      return DeliverySummary.fromJson(response);
    }

    return DeliverySummary(
        completedCount: 0, totalDistanceKm: 0, avgDeliveryTimeMin: 0);
  }

  Future<Map<String, dynamic>> resetDuty() async {
    final uri = Uri.parse(AppUrls.resetDuty);
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true ||
        response['status'] == 'success' ||
        response['message'] == 'Duty reset successfully') {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to reset duty');
    }
  }

  Future<List<DailyDutyLog>> getMonthlyPerformance(String month) async {
    final uri = Uri.parse('${AppUrls.partnerPerformanceMonth}?month=$month');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response is List) {
      return response.map((e) => DailyDutyLog.fromJson(e)).toList();
    } else {
      throw ValidationException('Unexpected response format');
    }
  }

  Future<List<DailyDutyLog>> getWeeklyPerformance(String weekStart) async {
    final uri =
        Uri.parse('${AppUrls.partnerPerformanceWeek}?weekStart=$weekStart');
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    if (response is List) {
      return response.map((e) => DailyDutyLog.fromJson(e)).toList();
    } else {
      throw ValidationException('Invalid response format');
    }
  }

  Future<Map<String, dynamic>> startReturnOrder(int orderId) async {
    final uri = Uri.parse(AppUrls.startReturn(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to start return process');
    }
  }

  Future<Map<String, dynamic>> arriveReturnOrder(int orderId) async {
    final uri = Uri.parse(AppUrls.arriveReturn(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to mark arrival at return location');
    }
  }

  Future<bool> uploadReturnReceipt(int orderId, File imageFile) async {
    final uri = Uri.parse(AppUrls.returnReceipt(orderId));
    log('API Request: POST Multipart $uri');

    final request = http.MultipartRequest('POST', uri);
    final headers = await _getHeaders();
    request.headers.addAll(headers);

    try {
      final multipartFile = await http.MultipartFile.fromPath(
        'receipt_image', // Assuming 'receipt_image' key, adjust if needed
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
        throw ValidationException(
            body['message'] ?? 'Failed to upload receipt');
      }
    } catch (e) {
      log('Error uploading receipt: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> completeReturnHandover(int orderId) async {
    final uri = Uri.parse(AppUrls.returnHandover(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() async => http.post(
          uri,
          headers: await _getHeaders(),
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to complete return handover');
    }
  }

  Future<List<DutySlot>> getDutySlots() async {
    final uri = Uri.parse(AppUrls.dutySlots);
    log('API Request: GET $uri');

    final response = await _processRequest(() async => http.get(
          uri,
          headers: await _getHeaders(),
        ));

    return DutySlotModel.fromJson(response).data;
  }
}
