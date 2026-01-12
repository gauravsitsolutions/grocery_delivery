import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/model/profile_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _error = 'Session expired. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.getProfile(token);
      if (response.status && response.data != null) {
        _profile = response.data;
      } else {
        _error = 'Failed to load profile data';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePhone(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _error = 'Session expired. Please login again.';
        return false;
      }

      final response = await _apiService.updateProfilePhone(token, phone);
      if (response['status'] == true) {
        await fetchProfile(); // Refresh profile after update
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update phone number';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _error = 'Session expired. Please login again.';
        return false;
      }

      final response = await _apiService.updateProfileEmail(token, email);
      if (response['status'] == true) {
        await fetchProfile(); // Refresh profile after update
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update email address';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateVehicle(String vehicleType, String vehicleNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _error = 'Session expired. Please login again.';
        return false;
      }

      final response = await _apiService.updateProfileVehicle(
          token, vehicleType, vehicleNumber);
      if (response['status'] == true) {
        await fetchProfile(); // Refresh profile after update
        return true;
      } else {
        _error = response['message'] ?? 'Failed to update vehicle details';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
