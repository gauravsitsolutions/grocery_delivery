import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/model/user_model.dart';

class ApiService {
  Future<LoginResponse> loginWithPassword(String username, String password) async {
    try {
      final uri = Uri.parse(AppUrls.loginPassword);
      log('API Request: POST $uri');
      log('Request Body: ${jsonEncode({'username': username, 'password': '***'})}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

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
      log('API Exception: $e');
      if (e.toString().contains('Timeout')) {
        throw Exception('Connection timed out. Please check your internet connection.');
      }
      rethrow; 
    }
  }
}
