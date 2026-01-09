import 'package:flutter/foundation.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderViewModel extends ChangeNotifier {
  final int orderId;
  final ApiService _apiService = ApiService();

  Order? _order;
  List<OrderItem> _orderItems = [];
  bool _isLoading = true;
  bool _isItemsLoading = true;
  String? _error;
  String? _authToken;
  bool _hasReadInstructions = false;
  final Set<int> _checkedItems = {};
  double _swipePosition = 0;
  bool _isPickupMode = false;

  OrderViewModel({required this.orderId});

  // Getters
  Order? get order => _order;
  List<OrderItem> get orderItems => _orderItems;
  bool get isLoading => _isLoading;
  bool get isItemsLoading => _isItemsLoading;
  String? get error => _error;
  String? get authToken => _authToken;
  bool get hasReadInstructions => _hasReadInstructions;
  Set<int> get checkedItems => _checkedItems;
  double get swipePosition => _swipePosition;
  bool get isPickupMode => _isPickupMode;

  set hasReadInstructions(bool value) {
    _hasReadInstructions = value;
    notifyListeners();
  }

  set swipePosition(double value) {
    _swipePosition = value;
    notifyListeners();
  }

  void toggleItem(int itemId) {
    if (_checkedItems.contains(itemId)) {
      _checkedItems.remove(itemId);
    } else {
      _checkedItems.add(itemId);
    }
    notifyListeners();
  }

  Future<void> fetchOrderDetails() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }
      _authToken = token;

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
      _error = e.toString();
      _isLoading = false;
      _isItemsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> pickupOrder() async {
    if (_checkedItems.length < _orderItems.length) {
      return false; // Validation handled in UI snackbar
    }

    try {
      if (_authToken == null) return false;
      await _apiService.pickupOrder(_authToken!, orderId);
      await fetchOrderDetails(); // Refresh to update status
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
