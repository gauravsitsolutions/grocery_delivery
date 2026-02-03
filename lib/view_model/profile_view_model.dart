import 'package:flutter/material.dart';
import 'dart:io';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/model/profile_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ProfileModel? _profile;
  bool _isLoading = false;
  String? _error;

  int _totalOrders = 0;
  double _loginHours = 0.0;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalOrders => _totalOrders;
  double get loginHours => _loginHours;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getProfile();
      if (response.status && response.data != null) {
        _profile = response.data;

        // Update stored info from profile
        if (_profile!.id != null) {
          await SharedPrefsUtil.setAgentId(_profile!.id.toString());
        }
        if (_profile!.userId != null) {
          await SharedPrefsUtil.setUserId(_profile!.userId.toString());
        }
        if (_profile!.name != null) {
          await SharedPrefsUtil.setUserName(_profile!.name!);
        }

        await _fetchStats(); // Fetch stats after profile
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

  Future<void> _fetchStats() async {
    try {
      final orders = await _apiService.getTotalOrders();
      final hours = await _apiService.getLoginHours();
      final localSeconds = await SharedPrefsUtil
          .getSessionSeconds(); // Get local session seconds
      _totalOrders = orders;
      _loginHours = hours + (localSeconds / 3600.0);
    } catch (e) {
      debugPrint('Error fetching profile stats: $e');
      // Don't error out the whole profile load just for stats
    }
  }

  Future<bool> updatePhone(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateProfilePhone(phone);
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
      final response = await _apiService.updateProfileEmail(email);
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
      final response =
          await _apiService.updateProfileVehicle(vehicleType, vehicleNumber);
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

  Future<bool> pickAndUploadImage() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Optimize image size
      );

      if (image == null) {
        _isLoading = false;
        notifyListeners();
        return false; // User canceled
      }

      final imageUrl = await _apiService.uploadProfileImage(File(image.path));

      if (imageUrl != null) {
        await fetchProfile();
        return true;
      } else {
        _error = 'Failed to upload profile image';
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
