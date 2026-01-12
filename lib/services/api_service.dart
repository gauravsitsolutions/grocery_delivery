import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_status_model.dart';
import 'package:samrudhi_delivery_agent_app/model/user_model.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/model/notification_model.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';

class ApiService {
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

  dynamic _handleResponse(http.Response response) {
    log('API Response Status: ${response.statusCode}');
    log('API Response Body: ${response.body}');

    try {
      final jsonResponse = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
        case 201:
          return jsonResponse;
        case 400:
          throw ValidationException(
              jsonResponse['message'] ?? 'Invalid request');
        case 401:
        case 403:
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

  Future<void> logout(String token) async {
    final uri = Uri.parse(AppUrls.logout);
    log('API Request: POST $uri');
    final sanitizedToken =
        token.startsWith('Bearer ') ? token.substring(7) : token;

    await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $sanitizedToken',
          },
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
      String token, bool isOnline) async {
    final uri =
        Uri.parse(isOnline ? AppUrls.partnerOnline : AppUrls.partnerOffline);
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
    return response;
  }

  Future<OrderResponse> getNewOrders(String token, {int page = 1}) async {
    final uri = Uri.parse('${AppUrls.newOrders}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> confirmPickup(String token, int orderId) async {
    final uri = Uri.parse(AppUrls.pickupOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    if (response['status'] == true || response['status'] == 'success') {
      return response;
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to complete pickup');
    }
  }

  Future<OrderResponse> getMyOrders(String token, {int page = 1}) async {
    final uri = Uri.parse('${AppUrls.myOrders}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<OrderResponse> getDeliveries(String token, {int page = 1}) async {
    final uri = Uri.parse('${AppUrls.deliveries}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<OrderResponse> searchDeliveries(String token, String query,
      {int page = 1}) async {
    final uri =
        Uri.parse('${AppUrls.searchDeliveries}?query=$query&page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    if (response is List) {
      return OrderResponse.fromJson({'data': response, 'status': true});
    }
    return OrderResponse.fromJson(response);
  }

  Future<DeliveryStatusResponse> getDeliveryStatus(String token) async {
    final uri = Uri.parse(AppUrls.deliveryStatus);
    log('API Request: GET $uri');

    final response = await _processRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    return DeliveryStatusResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> acceptOrder(String token, int orderId) async {
    final uri = Uri.parse(AppUrls.acceptOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
    return response;
  }

  Future<Map<String, dynamic>> rejectOrder(String token, int orderId) async {
    final uri = Uri.parse(AppUrls.rejectOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
    return response;
  }

  Future<Order> getOrderDetails(String token, int orderId) async {
    final uri = Uri.parse(AppUrls.orderDetails(orderId));
    log('API Request: GET $uri');

    final response = await _processRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    if (response['status'] == true && response['data'] != null) {
      return Order.fromJson(response['data']);
    } else {
      throw ValidationException(response['message'] ?? 'Failed to parse order');
    }
  }

  Future<List<OrderItem>> getOrderItems(String token, int orderId) async {
    final uri = Uri.parse(AppUrls.orderItems(orderId));
    log('API Request: GET $uri');

    final response = await _processRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
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
      String token, int orderId, int itemId) async {
    final uri = Uri.parse(AppUrls.verifyOrderItem(orderId, itemId));
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    if (response['status'] == true) {
      return response;
    } else {
      throw ValidationException(response['message'] ?? 'Failed to verify item');
    }
  }

  Future<Map<String, dynamic>> reportItemIssue(String token, int orderId,
      int itemId, String issueType, String? description) async {
    final uri = Uri.parse(AppUrls.reportItemIssue(orderId, itemId));
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'issueType': issueType,
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
      String token, int orderId, String reason) async {
    final uri = Uri.parse(AppUrls.cancelOrder(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'cancel_reason': reason,
          }),
        ));

    return response;
  }

  Future<Map<String, dynamic>?> getCurrentOrder(String token) async {
    final uri = Uri.parse(AppUrls.currentOrder);
    log('API Request: GET $uri');

    try {
      final response = await _processRequest(() => http.get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ));

      if (response['status'] == true && response['data'] != null) {
        return response['data'];
      }
      return null;
    } catch (e) {
      // If 404/validation error (order not found), return null gracefully
      if (e is ValidationException ||
          e.toString().contains('Order not found')) {
        log('No active current order found (Normal state if idle)');
        return null;
      }
      log('Current Order Check Failed: $e');
      rethrow; // Rethrow other errors (auth, server)
    }
  }

  Future<Map<String, dynamic>> completeDelivery(
      String token, int orderId, String otp) async {
    final uri = Uri.parse(AppUrls.completeDelivery(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
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

  Future<void> sendDeliveryOtp(String token, int orderId) async {
    final uri = Uri.parse(AppUrls.sendDeliveryOtp(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    if (response['status'] != true) {
      throw ValidationException(
          response['message'] ?? 'Failed to send delivery OTP');
    }
  }

  Future<Map<String, dynamic>> getOrderSummary(
      String token, int orderId) async {
    final uri = Uri.parse(AppUrls.getSummary(orderId));
    log('API Request: GET $uri');

    final response = await _processRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    if (response['status'] == true && response['data'] != null) {
      return response['data'];
    } else {
      throw ValidationException(
          response['message'] ?? 'Failed to fetch order summary');
    }
  }

  Future<Map<String, dynamic>> rateCustomer(
      String token, int orderId, double rating, String? comment) async {
    final uri = Uri.parse(AppUrls.rateCustomer(orderId));
    log('API Request: POST $uri');

    final response = await _processRequest(() => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
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

  Future<NotificationResponse> getNotifications(String token,
      {int page = 1}) async {
    final uri = Uri.parse('${AppUrls.notifications}?page=$page');
    log('API Request: GET $uri');

    final response = await _processRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    return NotificationResponse.fromJson(response);
  }

  Future<void> markNotificationAsRead(
      String token, String notificationId) async {
    final uri = Uri.parse(AppUrls.markNotificationAsRead(notificationId));
    log('API Request: GET $uri');

    final response = await _processRequest(() => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));

    if (response['status'] != true) {
      throw ValidationException(
          response['message'] ?? 'Failed to mark notification as read');
    }
  }
}
