import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_status_model.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';

class OrderListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State for "Available Orders" (New Orders)
  List<Order> _newOrders = [];
  bool _isNewOrdersLoading = false;
  bool _isNewOrdersLoadingMore = false;
  int _newOrdersPage = 1;
  bool _newOrdersHasMore = false;
  String? _newOrdersError;

  // State for "My Deliveries" (Shared list for both Active and History tabs)
  List<Order> _myDeliveries = [];
  bool _isMyDeliveriesLoading = false;
  bool _isMyDeliveriesLoadingMore = false;
  int _myDeliveriesPage = 1;
  bool _myDeliveriesHasMore = false;
  String? _myDeliveriesError;

  // State for "Available Orders" (Nearby)
  List<Order> _availableOrders = [];
  bool _isAvailableOrdersLoading = false;
  bool _isAvailableOrdersLoadingMore = false;
  int _availableOrdersPage = 1;
  bool _availableOrdersHasMore = false;
  String? _availableOrdersError;

  // Track which type of list is currently loaded
  bool _isHistoryList = false;

  // Getters
  List<Order> get newOrders => _newOrders;
  bool get isNewOrdersLoading => _isNewOrdersLoading;
  bool get isNewOrdersLoadingMore => _isNewOrdersLoadingMore;
  bool get newOrdersHasMore => _newOrdersHasMore;
  String? get newOrdersError => _newOrdersError;

  List<Order> get myDeliveries => _myDeliveries;
  bool get isMyDeliveriesLoading => _isMyDeliveriesLoading;
  bool get isMyDeliveriesLoadingMore => _isMyDeliveriesLoadingMore;
  bool get myDeliveriesHasMore => _myDeliveriesHasMore;
  String? get myDeliveriesError => _myDeliveriesError;

  List<Order> get availableOrders => _availableOrders;
  bool get isAvailableOrdersLoading => _isAvailableOrdersLoading;
  bool get isAvailableOrdersLoadingMore => _isAvailableOrdersLoadingMore;
  bool get availableOrdersHasMore => _availableOrdersHasMore;
  String? get availableOrdersError => _availableOrdersError;

  // Filters from Sheet
  String _activeDateFilter = 'All';
  String _activeTypeFilter = 'All';

  String get activeDateFilter => _activeDateFilter;
  String get activeTypeFilter => _activeTypeFilter;

  void setFilters(String date, String type) {
    _activeDateFilter = date;
    _activeTypeFilter = type;
    notifyListeners();
  }

  void clearFilters() {
    _activeDateFilter = 'All';
    _activeTypeFilter = 'All';
    notifyListeners();
  }

  // Fetch New Orders
  Future<void> fetchNewOrders({bool refresh = false}) async {
    if (refresh) {
      _newOrdersPage = 1;
      _newOrdersHasMore = false;
      _newOrdersError = null;
      _isNewOrdersLoading = true;
      notifyListeners();
    }

    try {
      final response = await _apiService.getNewOrders(page: _newOrdersPage);

      if (refresh) {
        _newOrders = response.data;
      } else {
        _newOrders.addAll(response.data);
      }

      _newOrdersHasMore = (response.currentPage ?? _newOrdersPage) <
          (response.lastPage ?? _newOrdersPage);
      _isNewOrdersLoading = false;
      _isNewOrdersLoadingMore = false; // Reset if called from loadMore
      notifyListeners();
    } catch (e) {
      _newOrdersError = e is AppException ? e.message : e.toString();
      _isNewOrdersLoading = false;
      _isNewOrdersLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNewOrders() async {
    if (_isNewOrdersLoadingMore || _isNewOrdersLoading || !_newOrdersHasMore) {
      return;
    }

    _isNewOrdersLoadingMore = true;
    _newOrdersPage++;
    notifyListeners();

    await fetchNewOrders();
  }

  // Fetch Available Orders
  Future<void> fetchAvailableOrders({bool refresh = false}) async {
    if (refresh) {
      _availableOrdersPage = 1;
      _availableOrdersHasMore = false;
      _availableOrdersError = null;
      _isAvailableOrdersLoading = true;
      notifyListeners();
    }

    try {
      final response =
          await _apiService.getAvailableOrders(page: _availableOrdersPage);

      if (refresh) {
        _availableOrders = response.data;
      } else {
        _availableOrders.addAll(response.data);
      }

      _availableOrdersHasMore = (response.currentPage ?? _availableOrdersPage) <
          (response.lastPage ?? _availableOrdersPage);
      _isAvailableOrdersLoading = false;
      _isAvailableOrdersLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _availableOrdersError = e is AppException ? e.message : e.toString();
      _isAvailableOrdersLoading = false;
      _isAvailableOrdersLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreAvailableOrders() async {
    if (_isAvailableOrdersLoadingMore ||
        _isAvailableOrdersLoading ||
        !_availableOrdersHasMore) {
      return;
    }

    _isAvailableOrdersLoadingMore = true;
    _availableOrdersPage++;
    notifyListeners();

    await fetchAvailableOrders();
  }

  // Fetch ACTIVE Orders (Queue) - typically "Pending", "Assigned", "Picked Up"
  Future<void> fetchActiveOrders({bool refresh = false}) async {
    if (refresh) {
      _isHistoryList = false; // Mark as Active
      _myDeliveriesPage = 1;
      _myDeliveriesHasMore = false;
      _myDeliveriesError = null;
      _isMyDeliveriesLoading = true;
      notifyListeners();
    } else if (_isHistoryList) {
      // Prevent loading more if we are switching contexts incorrectly
      return;
    }

    try {
      // Use getMyOrders for Active queue
      final response = await _apiService.getMyOrders(page: _myDeliveriesPage);

      // Guard: If we switched to history while fetching, discard this result
      if (_isHistoryList) return;

      // Also fetch status if this is the first page or a refresh
      if (refresh || _myDeliveriesPage == 1) {
        fetchDeliveryStatus();
      }

      if (refresh) {
        _myDeliveries = response.data;
      } else {
        _myDeliveries.addAll(response.data);
      }

      _myDeliveriesHasMore = (response.currentPage ?? _myDeliveriesPage) <
          (response.lastPage ?? _myDeliveriesPage);
      _isMyDeliveriesLoading = false;
      _isMyDeliveriesLoadingMore = false;

      // Sync pending count with local list length for consistency
      if (_deliveryStatus != null) {
        _deliveryStatus = DeliveryStatus(
          deliveredOrders: _deliveryStatus!.deliveredOrders,
          pendingOrders: _myDeliveries.length, // Sync here
          cancelledOrders: _deliveryStatus!.cancelledOrders,
          totalOrders: _deliveryStatus!.totalOrders,
        );
      }

      notifyListeners();
    } catch (e) {
      if (_isHistoryList) return; // Check again just in case
      _myDeliveriesError = e is AppException ? e.message : e.toString();
      _isMyDeliveriesLoading = false;
      _isMyDeliveriesLoadingMore = false;
      notifyListeners();
    }
  }

  // Fetch HISTORY Orders - typically "Delivered", "Cancelled"
  Future<void> fetchHistoryOrders({bool refresh = false}) async {
    if (refresh) {
      _isHistoryList = true; // Mark as History
      _myDeliveriesPage = 1;
      _myDeliveriesHasMore = false;
      _myDeliveriesError = null;
      _isMyDeliveriesLoading = true;
      notifyListeners();
    } else if (!_isHistoryList) {
      return;
    }

    try {
      // Use getDeliveries for History
      final response = await _apiService.getDeliveries(page: _myDeliveriesPage);

      // Guard: If we switched to active while fetching, discard this result
      if (!_isHistoryList) return;

      if (refresh) {
        _myDeliveries = response.deliveries.data;
      } else {
        _myDeliveries.addAll(response.deliveries.data);
      }

      _myDeliveriesHasMore =
          (response.deliveries.currentPage ?? _myDeliveriesPage) <
              (response.deliveries.lastPage ?? _myDeliveriesPage);
      _isMyDeliveriesLoading = false;
      _isMyDeliveriesLoadingMore = false;
      notifyListeners();
    } catch (e) {
      if (!_isHistoryList) return;
      _myDeliveriesError = e is AppException ? e.message : e.toString();
      _isMyDeliveriesLoading = false;
      _isMyDeliveriesLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMyDeliveries() async {
    if (_isMyDeliveriesLoadingMore ||
        _isMyDeliveriesLoading ||
        !_myDeliveriesHasMore) {
      return;
    }

    _isMyDeliveriesLoadingMore = true;
    _myDeliveriesPage++;
    notifyListeners();

    if (_isHistoryList) {
      await fetchHistoryOrders();
    } else {
      await fetchActiveOrders();
    }
  }

  // Search State
  List<Order> _searchResults = [];
  bool _isSearching = false;
  bool _isSearchLoading = false;
  String? _searchError;
  String _currentQuery = '';
  int _searchPage = 1;
  bool _searchHasMore = false;
  bool _isSearchLoadingMore = false;

  List<Order> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isSearchLoading => _isSearchLoading;
  String? get searchError => _searchError;
  bool get isSearchLoadingMore => _isSearchLoadingMore;

  void clearSearch() {
    _isSearching = false;
    _searchResults = [];
    _currentQuery = '';
    _searchError = null;
    notifyListeners();
  }

  Future<void> searchDeliveries(String query, {bool refresh = false}) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    if (refresh) {
      _searchPage = 1;
      _searchHasMore = false;
      _searchError = null;
      _isSearchLoading = true;
      _currentQuery = query;
      _isSearching = true;
      notifyListeners();
    }

    try {
      final response =
          await _apiService.searchDeliveries(query, page: _searchPage);

      if (refresh) {
        _searchResults = response.data;
      } else {
        _searchResults.addAll(response.data);
      }

      _searchHasMore = (response.currentPage ?? _searchPage) <
          (response.lastPage ?? _searchPage);
      _isSearchLoading = false;
      _isSearchLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _searchError = e is AppException ? e.message : e.toString();
      _isSearchLoading = false;
      _isSearchLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreSearchResults() async {
    if (_isSearchLoadingMore || _isSearchLoading || !_searchHasMore) {
      return;
    }

    _isSearchLoadingMore = true;
    _searchPage++;
    notifyListeners();

    await searchDeliveries(_currentQuery);
  }

  // Delivery Status
  DeliveryStatus? _deliveryStatus;
  bool _isStatusLoading = false;

  DeliveryStatus? get deliveryStatus => _deliveryStatus;
  bool get isStatusLoading => _isStatusLoading;

  Future<void> fetchDeliveryStatus() async {
    _isStatusLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getDeliveryStatus();
      if (response.status && response.data != null) {
        _deliveryStatus = response.data;
      }
    } catch (e) {
      debugPrint('Error fetching delivery status: $e');
    } finally {
      _isStatusLoading = false;
      notifyListeners();
    }
  }

  // Order Actions
  Future<bool> acceptOrder(int orderId) async {
    try {
      final response = await _apiService.acceptOrder(orderId);

      if (response['status'] == true || response['status'] == 'success') {
        // Remove from new orders locally for immediate UI update
        _newOrders.removeWhere((o) => o.id == orderId);
        _availableOrders
            .removeWhere((o) => o.id == orderId); // Also remove from available
        notifyListeners();
        // Refresh active orders list in background
        fetchActiveOrders(refresh: true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error accepting order: $e');
      return false;
    }
  }

  Future<bool> rejectOrder(int orderId) async {
    try {
      final response = await _apiService.rejectOrder(orderId);

      if (response['status'] == true || response['status'] == 'success') {
        // Remove from new orders locally
        _newOrders.removeWhere((o) => o.id == orderId);
        _availableOrders.removeWhere((o) => o.id == orderId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error rejecting order: $e');
      // If order is already gone (404), treat as success local-wise
      if (e.toString().contains('404') ||
          e.toString().contains('Order not available')) {
        _newOrders.removeWhere((o) => o.id == orderId);
        _availableOrders.removeWhere((o) => o.id == orderId);
        notifyListeners();
        return true;
      }
      return false;
    }
  }
}
