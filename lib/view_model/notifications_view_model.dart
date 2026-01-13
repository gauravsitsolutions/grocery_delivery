import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/model/notification_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = false;
  String? _error;
  Map<String, bool> _settings = {
    'new_order_alerts': true,
    'delivery_updates': true,
    'chat_messages': true,
    'promotional_offers': false,
    'app_updates': true,
  };

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  Map<String, bool> get settings => _settings;

  Future<String?> get _authToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = false;
      _error = null;
      _isLoading = true;
      notifyListeners();
    }

    try {
      final token = await _authToken;
      if (token == null) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response =
          await _apiService.getNotifications(token, page: _currentPage);

      if (refresh) {
        _notifications = response.data;
      } else {
        _notifications.addAll(response.data);
      }

      _hasMore = (response.currentPage ?? _currentPage) <
          (response.lastPage ?? _currentPage);
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _error = e is AppException ? e.message : e.toString();
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || _isLoading || !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();

    await fetchNotifications();
  }

  // Helper to get notifications filtered by type if needed
  List<NotificationModel> getNotificationsByType(String tab) {
    if (tab == 'All') return _notifications;
    // Map tab name to internal type strings if they exist
    // For now returning all as we don't know the types yet
    return _notifications;
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final token = await _authToken;
      if (token == null) return;

      // Find locally and update status immediately for better UX
      final index =
          _notifications.indexWhere((n) => n.id.toString() == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          createdAt: _notifications[index].createdAt,
          readAt: DateTime.now(),
        );
        notifyListeners();
      }

      await _apiService.markNotificationAsRead(token, notificationId);
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> fetchSettings() async {
    try {
      final token = await _authToken;
      if (token == null) return;

      final response = await _apiService.getNotificationSettings(token);
      if (response['status'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        _settings = {
          'new_order_alerts': data['new_order_alerts'] ?? true,
          'delivery_updates': data['delivery_updates'] ?? true,
          'chat_messages': data['chat_messages'] ?? true,
          'promotional_offers': data['promotional_offers'] ?? false,
          'app_updates': data['app_updates'] ?? true,
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    }
  }

  Future<void> markAllRead() async {
    // Optimistic update
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = NotificationModel(
          id: _notifications[i].id,
          title: _notifications[i].title,
          message: _notifications[i].message,
          type: _notifications[i].type,
          createdAt: _notifications[i].createdAt,
          readAt: DateTime.now(),
        );
      }
    }
    notifyListeners();

    try {
      final token = await _authToken;
      if (token != null) {
        // await _apiService.markAllNotificationsAsRead(token);
      }
    } catch (e) {
      // Revert or show error
      debugPrint("Error marking all read: $e");
    }
  }

  Future<void> clearAll() async {
    final backup = List<NotificationModel>.from(_notifications);
    _notifications.clear();
    notifyListeners();

    try {
      final token = await _authToken;
      if (token != null) {
        // await _apiService.clearAllNotifications(token);
      }
    } catch (e) {
      _notifications = backup;
      notifyListeners();
      debugPrint("Error clearing notifications: $e");
    }
  }

  Future<void> updateSetting(String key, bool value) async {
    final originalValue = _settings[key];
    _settings[key] = value;
    notifyListeners();

    try {
      final token = await _authToken;
      if (token == null) return;

      await _apiService.updateNotificationSettings(token, {key: value});
    } catch (e) {
      _settings[key] = originalValue ?? true;
      notifyListeners();
      debugPrint('Error updating setting: $e');
    }
  }
}
