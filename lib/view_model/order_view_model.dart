import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';

import 'package:shared_preferences/shared_preferences.dart';

class OrderViewModel extends ChangeNotifier {
  final int orderId;
  final ApiService _apiService = ApiService();

  Order? _order;
  List<OrderItem> _orderItems = [];
  bool _isLoading = true;
  bool _isItemsLoading = true;
  String? _error;
  bool _hasReadInstructions = false;
  final Set<int> _checkedItems = {};
  double _swipePosition = 0;
  bool _isPickupMode = false;
  bool _isUnauthenticated = false;

  OrderViewModel({required this.orderId, Order? initialOrder}) {
    if (initialOrder != null) {
      _order = initialOrder;
      _isLoading = false;
      final status = _order?.status.toLowerCase();
      _isPickupMode = status == 'accepted' || status == 'pending';
    }
  }

  // Getters
  Order? get order => _order;
  List<OrderItem> get orderItems => _orderItems;
  bool get isLoading => _isLoading;
  bool get isItemsLoading => _isItemsLoading;
  String? get error => _error;
  bool get hasReadInstructions => _hasReadInstructions;

  Set<int> get checkedItems => _checkedItems;
  double get swipePosition => _swipePosition;
  bool get isPickupMode => _isPickupMode;
  bool get isUnauthenticated => _isUnauthenticated;

  set hasReadInstructions(bool value) {
    _hasReadInstructions = value;
    notifyListeners();
  }

  set swipePosition(double value) {
    _swipePosition = value;
    notifyListeners();
  }

  final Set<int> _verifyingItems = {};

  bool isItemVerifying(int itemId) => _verifyingItems.contains(itemId);

  Future<String?> get _getToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> toggleItem(int itemId) async {
    if (_checkedItems.contains(itemId)) {
      _checkedItems.remove(itemId);
      notifyListeners();
      return;
    }

    if (_verifyingItems.contains(itemId)) return;

    _verifyingItems.add(itemId);
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) throw Exception('Not authenticated');

      await _apiService.verifyOrderItem(token, orderId, itemId);

      _checkedItems.add(itemId);
    } catch (e) {
      _error = e is AppException ? e.message : e.toString();
    } finally {
      _verifyingItems.remove(itemId);
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetails() async {
    if (_order == null) {
      _isLoading = true;
    }
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final results = await Future.wait([
        _apiService.getOrderDetails(token, orderId),
        _apiService.getOrderItems(token, orderId),
      ]);

      _order = results[0] as Order;
      _orderItems = results[1] as List<OrderItem>;

      final status = _order?.status.toLowerCase();
      _isPickupMode = status == 'accepted' || status == 'pending';

      if (!_isPickupMode) {
        _checkedItems.clear();
        for (var item in _orderItems) {
          _checkedItems.add(item.id);
        }
        _hasReadInstructions = true;
      }

      _isLoading = false;
      _isItemsLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e is AppException ? e.message : e.toString();
      _isLoading = false;
      _isItemsLoading = false;
      notifyListeners();
    }
  }

  bool _isPickupLoading = false;
  bool get isPickupLoading => _isPickupLoading;

  File? _pickupProofImage;
  File? get pickupProofImage => _pickupProofImage;

  Future<bool> verifyDeliveryOtp(String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) throw Exception('Not authenticated');

      await _apiService.completeDelivery(token, orderId, otp);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is AppException ? e.message : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> pickProofImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        _pickupProofImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to pick image: $e";
      notifyListeners();
    }
  }

  void clearProofImage() {
    _pickupProofImage = null;
    notifyListeners();
  }

  Future<bool> pickupOrder() async {
    if (_checkedItems.length < _orderItems.length) {
      return false; // Validation handled in UI snackbar
    }

    if (_pickupProofImage == null) {
      _error = "Please upload pickup proof image";
      notifyListeners();
      return false;
    }

    _isPickupLoading = true;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) return false;

      // 1. Upload Proof
      log('Uploading pickup proof...');
      try {
        await _apiService.uploadPickupProof(token, orderId, _pickupProofImage!);
        log('Pickup proof uploaded successfully');
      } catch (e) {
        log('Error uploading proof: $e');
        _error =
            "Failed to upload proof: ${e.toString().replaceAll('Exception:', '')}";
        _isPickupLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Confirm Pickup
      final response = await _apiService.confirmPickup(token, orderId);

      // If the API returns the updated order object in 'data', we can update it directly
      if (response['data'] != null) {
        log('Pickup response data: ${response['data']}');
        try {
          _order = Order.fromJson(response['data']);

          // CRITICAL: Even if the backend returns 'accepted', the successful API call
          // means the pickup is confirmed. We optimistically update the state.
          final apiStatus = _order?.status.toLowerCase();
          log('New Order Status from API: $apiStatus');

          if (apiStatus == 'accepted' || apiStatus == 'pending') {
            log('API returned stale status. forcing picked_up state.');
            // Force status to picked_up to ensure navigation
            // We'd ideally clone the order with new status but for now handling the boolean is mostly enough
            // _order = _order?.copyWith(status: 'picked_up'); // If copyWith exists
            _isPickupMode = false;
          } else {
            _isPickupMode = apiStatus == 'accepted' || apiStatus == 'pending';
          }

          log('Is Pickup Mode: $_isPickupMode');
          notifyListeners();
          return true;
        } catch (e) {
          log('Error parsing pickup response: $e');
          _isPickupMode = false;
          notifyListeners();
          fetchOrderDetails();
          return true;
        }
      } else if (response['status'] == true) {
        log('Pickup confirmed via status check.');
        _isPickupMode = false;
        notifyListeners();
        fetchOrderDetails();
        return true;
      } else {
        // Don't await fetch here, assume success to unblock user
        _isPickupMode = false;
        notifyListeners();
        fetchOrderDetails(); // Background refresh
        return true;
      }
    } catch (e) {
      if (e is UnauthorisedException) {
        _isUnauthenticated = true;
      }
      _error = e is AppException ? e.message : e.toString();
      notifyListeners();
      return false;
    } finally {
      _isPickupLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reportItemIssue(
      int itemId, String issueType, String description) async {
    try {
      final token = await _getToken;
      if (token == null) throw Exception('Not authenticated');

      await _apiService.reportItemIssue(
          token, orderId, itemId, issueType, description);

      // Optionally mark item as "issue reported" locally if needed?
      // For now just return true so UI can show success message
      return true;
    } catch (e) {
      _error = e is AppException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelOrder(String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) throw Exception('Not authenticated');

      final response = await _apiService.cancelOrder(token, orderId, reason);

      if (response['status'] == true || response['message'] != null) {
        // Assume cancellation successful
        // Update order status locally if possible or fetch fresh data
        fetchOrderDetails();
        return true;
      }
      return false;
    } catch (e) {
      if (e is UnauthorisedException) {
        _isUnauthenticated = true;
      }
      _error = e is AppException ? e.message : e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
