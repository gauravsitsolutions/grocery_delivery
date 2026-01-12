import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_status_model.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderListViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State for "Available Orders" (New Orders)
  List<Order> _newOrders = [];
  bool _isNewOrdersLoading = false;
  bool _isNewOrdersLoadingMore = false;
  int _newOrdersPage = 1;
  bool _newOrdersHasMore = false;
  String? _newOrdersError;

  // State for "My Deliveries"
  List<Order> _myDeliveries = [];
  bool _isMyDeliveriesLoading = false;
  bool _isMyDeliveriesLoadingMore = false;
  int _myDeliveriesPage = 1;
  bool _myDeliveriesHasMore = false;
  String? _myDeliveriesError;

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
      final token = await _authToken;
      if (token == null) {
        _newOrdersError = 'Not authenticated';
        _isNewOrdersLoading = false;
        notifyListeners();
        return;
      }

      final response =
          await _apiService.getNewOrders(token, page: _newOrdersPage);

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

  // Fetch My Deliveries
  Future<void> fetchMyDeliveries({bool refresh = false}) async {
    if (refresh) {
      _myDeliveriesPage = 1;
      _myDeliveriesHasMore = false;
      _myDeliveriesError = null;
      _isMyDeliveriesLoading = true;
      notifyListeners();
    }

    try {
      final token = await _authToken;
      if (token == null) {
        _myDeliveriesError = 'Not authenticated';
        _isMyDeliveriesLoading = false;
        notifyListeners();
        return;
      }

      final response =
          await _apiService.getDeliveries(token, page: _myDeliveriesPage);

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
      notifyListeners();
    } catch (e) {
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

    await fetchMyDeliveries();
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
      final token = await _authToken;
      if (token == null) {
        _searchError = 'Not authenticated';
        _isSearchLoading = false;
        notifyListeners();
        return;
      }

      final response =
          await _apiService.searchDeliveries(token, query, page: _searchPage);

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
      final token = await _authToken;
      if (token == null) {
        _isStatusLoading = false;
        notifyListeners();
        return;
      }

      final response = await _apiService.getDeliveryStatus(token);
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

  Future<String?> get _authToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
