import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/model/cancellation_reason_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';

class OrderViewModel extends ChangeNotifier {
  final int orderId;
  final ApiService _apiService = ApiService();

  Order? _order;
  List<OrderItem> _orderItems = [];
  List<CancellationReason> _cancellationReasons = [];
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
      _isPickupMode = status == 'checked_in' ||
          status == 'in_progress' ||
          status == 'accepted';
    }
  }

  // Getters
  Order? get order => _order;
  List<OrderItem> get orderItems => _orderItems;
  List<CancellationReason> get cancellationReasons => _cancellationReasons;
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
    return await SharedPrefsUtil.getToken();
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
      _isLoading = false;
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

      final fetchedOrder = results[0] as Order;
      _orderItems = results[1] as List<OrderItem>;

      // Update the order object with the fetched items to ensure consistency across views
      _order = fetchedOrder.copyWith(orderItems: _orderItems);

      // Sync checked items with backend state
      _checkedItems.clear();
      for (var item in _orderItems) {
        if (item.isPicked) {
          _checkedItems.add(item.id);
        }
      }

      final status = _order?.status.toLowerCase();
      _isPickupMode = status == 'checked_in' ||
          status == 'in_progress' ||
          status == 'accepted';

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

      // 1. Complete Delivery (OTP Verification)
      await _apiService.completeDelivery(token, orderId, otp);

      // 2. Fetch Summary to check current status
      final summaryData = await _apiService.getOrderSummary(token, orderId);
      final currentStatus = summaryData['status']?.toString().toLowerCase();

      // Merge summary data into existing order immediately
      if (_order != null) {
        _order = _order!.copyWith(
          status: summaryData['status'],
          subtotal: summaryData['subtotal']?.toString(),
          deliveryCharge: summaryData['delivery_charge']?.toString(),
          discount: summaryData['discount']?.toString(),
          totalAmount: summaryData['total_amount']?.toString(),
          deliveredAt: DateTime.now(),
        );
      } else {
        _order = Order.fromJson(summaryData);
      }

      // 3. Finalize Order Status (New API) only if NOT cancelled
      if (currentStatus != 'cancelled') {
        try {
          final completeResponse =
              await _apiService.completeOrder(token, orderId);
          if (completeResponse['status'] == true &&
              completeResponse['data'] != null) {
            _order = Order.fromJson(completeResponse['data']);
          }
        } catch (e) {
          log('Warning: completeOrder failed but OTP was verified: $e');
        }
      } else {
        log('Order is cancelled, skipping completeOrder call.');
      }

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

  Future<bool> sendDeliveryOtp() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) throw Exception('Not authenticated');

      await _apiService.sendDeliveryOtp(token, orderId);

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

  Future<bool> resendDeliveryOtp() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) throw Exception('Not authenticated');

      await _apiService.resendDeliveryOtp(token, orderId);

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

  bool _isStartLoading = false;
  bool get isStartLoading => _isStartLoading;

  Future<bool> startOrder() async {
    _isStartLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = "Authentication failed";
        return false;
      }

      final response = await _apiService.startOrder(token, orderId);

      if (response['status'] == true || response['status'] == 'success') {
        if (response['data'] != null) {
          _order = Order.fromJson(response['data']);
        } else {
          // Refresh if no data returned
          await fetchOrderDetails();
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e is AppException ? e.message : e.toString();
      return false;
    } finally {
      _isStartLoading = false;
      notifyListeners();
    }
  }

  bool _isAcceptLoading = false;
  bool get isAcceptLoading => _isAcceptLoading;

  Future<bool> acceptOrder() async {
    _isAcceptLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = "Authentication failed";
        return false;
      }

      final response = await _apiService.acceptOrder(token, orderId);

      if (response['status'] == true || response['status'] == 'success') {
        if (response['data'] != null) {
          _order = Order.fromJson(response['data']);
        } else {
          await fetchOrderDetails();
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e is AppException ? e.message : e.toString();
      return false;
    } finally {
      _isAcceptLoading = false;
      notifyListeners();
    }
  }

  bool _isCompleteLoading = false;
  bool get isCompleteLoading => _isCompleteLoading;

  Future<bool> completeOrder() async {
    _isCompleteLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = "Authentication failed";
        return false;
      }

      final response = await _apiService.completeOrder(token, orderId);

      if (response['status'] == true || response['status'] == 'success') {
        if (response['data'] != null) {
          _order = Order.fromJson(response['data']);
        } else {
          await fetchOrderDetails();
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e is AppException ? e.message : e.toString();
      return false;
    } finally {
      _isCompleteLoading = false;
      notifyListeners();
    }
  }

  bool _isPendingLoading = false;
  bool get isPendingLoading => _isPendingLoading;

  Future<bool> markAsPending() async {
    _isPendingLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) {
        _error = "Authentication failed";
        return false;
      }

      final response = await _apiService.markAsPending(token, orderId);

      if (response['status'] == true || response['status'] == 'success') {
        if (response['data'] != null) {
          _order = Order.fromJson(response['data']);
        } else {
          await fetchOrderDetails();
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e is AppException ? e.message : e.toString();
      return false;
    } finally {
      _isPendingLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pickupOrder() async {
    if (_checkedItems.length < _orderItems.length) {
      _error = "Please check all items before confirming pickup";
      notifyListeners();
      return false;
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
      return true;
    } catch (e) {
      _error = e is AppException ? e.message : e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchCancellationReasons() async {
    try {
      final token = await _getToken;
      if (token == null) return;
      _cancellationReasons = await _apiService.getCancellationReasons(token);
      notifyListeners();
    } catch (e) {
      log('Error fetching cancellation reasons: $e');
    }
  }

  Future<bool> cancelOrder(int reasonId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) throw Exception('Not authenticated');

      final response = await _apiService.cancelOrder(token, orderId, reasonId);

      if (response['status'] == true || response['message'] != null) {
        // Assume cancellation successful
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

  Future<bool> rateCustomer(double rating, {String? comment}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken;
      if (token == null) throw Exception('Not authenticated');

      await _apiService.rateCustomer(token, orderId, rating, comment);

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
}
