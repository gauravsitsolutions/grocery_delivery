import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/model/user_model.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
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

  Future<Map<String, dynamic>> pickupOrder(String token, int orderId) async {
    final uri = Uri.parse(AppUrls.pickupOrder(orderId));
    log('API Request: GET $uri'); // Note: Original was GET, keeping it as is, usually pickup actions might be POST

    final response = await _processRequest(() => http.get(
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
      throw ValidationException(
          response['message'] ?? 'Failed to pickup order');
    }
  }
}
