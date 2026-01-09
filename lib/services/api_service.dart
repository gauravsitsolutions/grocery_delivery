import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/model/user_model.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';

class ApiService {
  Future<LoginResponse> loginWithPassword(
      String username, String password) async {
    try {
      final uri = Uri.parse(AppUrls.loginPassword);
      log('API Request: POST $uri');
      log('Request Body: ${jsonEncode({
            'username': username,
            'password': '***'
          })}');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(jsonResponse);
      } else {
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'Login failed');
      }
    } on SocketException {
      log('API Error: SocketException (No Internet)');
      throw Exception('No internet connection');
    } on FormatException {
      log('API Error: FormatException (Bad Response)');
      throw Exception('Bad response format');
    } catch (e) {
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<void> logout(String token) async {
    try {
      final uri = Uri.parse(AppUrls.logout);
      log('API Request: POST $uri');

      final sanitizedToken =
          token.startsWith('Bearer ') ? token.substring(7) : token;

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $sanitizedToken',
        },
      ).timeout(const Duration(seconds: 15));

      log('Request Headers: {Authorization: Bearer ***}'); // Secure log

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode != 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(jsonResponse['message'] ?? 'Logout failed');
      }
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendOtp(String mobile) async {
    try {
      final uri = Uri.parse(AppUrls.loginOtp);
      log('API Request: POST $uri');
      log('Request Body: ${jsonEncode({'mobile': mobile})}');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'mobile': mobile,
            }),
          )
          .timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return jsonResponse;
      } else {
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'Failed to send OTP');
      }
    } on SocketException {
      log('API Error: SocketException (No Internet)');
      throw Exception('No internet connection');
    } on FormatException {
      log('API Error: FormatException (Bad Response)');
      throw Exception('Bad response format');
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<LoginResponse> verifyOtp(String mobile, String otp) async {
    try {
      final uri = Uri.parse(AppUrls.verifyOtp);
      log('API Request: POST $uri');
      log('Request Body: ${jsonEncode({'mobile': mobile, 'otp': otp})}');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'mobile': mobile,
              'otp': otp,
            }),
          )
          .timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        return LoginResponse.fromJson(jsonResponse);
      } else {
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'OTP Verification failed');
      }
    } on SocketException {
      log('API Error: SocketException (No Internet)');
      throw Exception('No internet connection');
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resendOtp(String mobile) async {
    try {
      final uri = Uri.parse(AppUrls.resendOtp);
      log('API Request: POST $uri');
      log('Request Body: ${jsonEncode({'mobile': mobile})}');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'mobile': mobile,
            }),
          )
          .timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return jsonResponse;
      } else {
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendForgotPasswordOtp(String mobile) async {
    try {
      final uri = Uri.parse(AppUrls.forgotPasswordSendOtp);
      log('API Request: POST $uri');
      log('Request Body: ${jsonEncode({'mobile': mobile})}');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'mobile': mobile,
            }),
          )
          .timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return jsonResponse;
      } else {
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp(
      String mobile, String otp) async {
    try {
      final uri = Uri.parse(AppUrls.verifyForgotPasswordOtp);
      log('API Request: POST $uri');
      log('Request Body: ${jsonEncode({'mobile': mobile, 'otp': otp})}');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'mobile': mobile,
              'otp': otp,
            }),
          )
          .timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return jsonResponse;
      } else {
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'OTP Verification failed');
      }
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      String mobile, String password) async {
    try {
      final uri = Uri.parse(AppUrls.resetPassword);
      log('API Request: POST $uri');
      // Securely log body excluding password
      log('Request Body: ${jsonEncode({'mobile': mobile, 'password': '***'})}');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'mobile': mobile,
              'password': password,
              'password_confirmation': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        return jsonResponse;
      } else {
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateAgentStatus(
      String token, bool isOnline) async {
    try {
      final uri =
          Uri.parse(isOnline ? AppUrls.partnerOnline : AppUrls.partnerOffline);
      log('API Request: POST $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<OrderResponse> getNewOrders(String token) async {
    try {
      final uri = Uri.parse(AppUrls.newOrders);
      log('API Request: GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        return OrderResponse.fromJson(jsonResponse);
      } else {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> acceptOrder(String token, int orderId) async {
    try {
      final uri = Uri.parse(AppUrls.acceptOrder(orderId));
      log('API Request: POST $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'Failed to accept order');
      }
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rejectOrder(String token, int orderId) async {
    try {
      final uri = Uri.parse(AppUrls.rejectOrder(orderId));
      log('API Request: POST $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonResponse;
      } else {
        log('API Error: ${jsonResponse['message']}');
        throw Exception(jsonResponse['message'] ?? 'Failed to reject order');
      }
    } catch (e) {
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      }
      rethrow;
    }
  }
}
