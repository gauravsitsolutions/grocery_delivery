import 'package:flutter/foundation.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_history_model.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';

class DeliveryHistoryViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  DeliveryHistoryResponse? _historyData;
  List<Order> _orders = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = false;

  DeliveryHistoryResponse? get historyData => _historyData;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchDeliveryHistory({bool refresh = true}) async {
    if (refresh) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final token = await SharedPrefsUtil.getToken();
      if (token == null) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final pageToFetch = refresh ? 1 : _currentPage + 1;
      final response =
          await _apiService.getDeliveries(token, page: pageToFetch);

      if (refresh) {
        _historyData = response;
        _orders = response.deliveries.data;
        _currentPage = 1;
      } else {
        // If loading more, we append to orders list but keep the summary from initial fetch (or update it if API sends it every time)
        _orders.addAll(response.deliveries.data);
        // Optionally update summary if needed
        _historyData = response;
        _currentPage = pageToFetch;
      }

      // Check for pagination
      if (response.deliveries.lastPage != null) {
        _hasMore = _currentPage < response.deliveries.lastPage!;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    await fetchDeliveryHistory(refresh: false);
  }
}
