import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/model/cancellation_reason_model.dart';
import 'package:samrudhi_delivery_agent_app/view/notification/notifications_view.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/view_model/notifications_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_list_view_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';

import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/animated_order_card.dart';
import 'package:samrudhi_delivery_agent_app/view/delivery_summary/delivery_completed_view.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/navigation_view.dart';
import 'package:samrudhi_delivery_agent_app/view/pickup/pickup_task_view.dart';
import 'package:samrudhi_delivery_agent_app/model/profile_model.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/dashboard_waiting_state.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_summary_model.dart';
import 'package:samrudhi_delivery_agent_app/view/feedback/order_rejected_feedback_view.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_accepted_success_view.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/widgets/performance_stats_row.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/order_cancellation_dialog.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/widgets/duty_status_card.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/widgets/new_request_card.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/widgets/dashboard_shimmer.dart';

class AgentDashboardView extends StatefulWidget {
  final bool isOnline;
  final String? dutyStatus; // Added parameter
  final ValueChanged<bool> onStatusChanged;

  const AgentDashboardView({
    super.key,
    required this.isOnline,
    this.dutyStatus,
    required this.onStatusChanged,
  });

  @override
  State<AgentDashboardView> createState() => _AgentDashboardViewState();
}

class _AgentDashboardViewState extends State<AgentDashboardView> {
  final ApiService _apiService = ApiService();
  List<Order> _newRequests = []; // From getNewOrders
  List<Order> _availableOrders = []; // From getAvailableOrders
  List<Order> _myOrders = []; // Full list of accepted orders
  Order? _currentOrder; // The first one in the queue
  bool _isLoading = true;

  // Timer State
  Timer? _dutyTimer;

  bool _isTimerPaused = false;
  DateTime? _lastToggleTimestamp;
  Timer? _dataRefreshTimer;

  // Pagination State
  int _availablePage = 1;
  int _myOrdersPage = 1;
  bool _hasMoreAvailable = false;
  bool _hasMoreMyOrders = false;
  bool _isAvailableLoadingMore = false;
  bool _isMyOrdersLoadingMore = false;
  bool _isAvailableExpanded = false; // Added to manage expansion state

  final Set<int> _removingOrderIds = {};
  ProfileModel? _userProfile;
  PartnerSummary? _partnerSummary;

  // Stats
  int _completedDeliveries = 0;
  int _pendingOrders = 0;
  int _cancelledOrders = 0;
  double _serverLoginHours = 0.0; // Synced from API
  int _localSessionSeconds = 0; // Incremented locally

  final int _dailyGoal = 15; // Hardcoded goal for now

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDashboard();
    });
    // Initialize timer state based on initial props
    if (widget.isOnline) {
      if (widget.dutyStatus?.toLowerCase() == 'paused') {
        _isTimerPaused = true;
        // Don't start timer ticking if paused
      } else {
        _startTimer();
      }
    }
    _startDataRefreshTimer();
  }

  @override
  void didUpdateWidget(covariant AgentDashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnline != oldWidget.isOnline) {
      if (widget.isOnline) {
        if (widget.dutyStatus?.toLowerCase() == 'paused') {
          _isTimerPaused = true;
        } else {
          _isTimerPaused = false;
          _startTimer();
        }
      } else {
        _stopTimer();
        // Reset timer when explicitly stopping duty (User Request)
        setState(() {
          _localSessionSeconds = 0;
        });
        SharedPrefsUtil.setSessionSeconds(0);
      }
    }
  }

  @override
  void dispose() {
    _dutyTimer?.cancel();
    _dataRefreshTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _stopTimer(); // Ensure no duplicate timers
    _dutyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerPaused && mounted) {
        setState(() {
          _localSessionSeconds++;
        });
        if (_localSessionSeconds % 5 == 0) {
          SharedPrefsUtil.setSessionSeconds(_localSessionSeconds);
        }
      }
    });
  }

  void _stopTimer() {
    _dutyTimer?.cancel();
    _dutyTimer = null;
  }

  void _startDataRefreshTimer() {
    _dataRefreshTimer?.cancel();
    // Refresh data every 10 seconds
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && widget.isOnline) {
        refreshData();
      }
    });
  }

  Future<void> refreshData() async {
    // Silent refresh - no loading indicators
    await Future.wait([
      _fetchOrders(refresh: false),
      _fetchProfile(),
      _partnerSummary != null ? _fetchPartnerSummary() : Future.value(),
      _fetchDeliveryStats(),
      _fetchLoginHours(),
    ]);
    if (mounted) {
      Provider.of<NotificationsViewModel>(context, listen: false)
          .fetchNotifications(refresh: false);
    }
  }

  Future<void> _toggleTimerPause() async {
    try {
      if (_isTimerPaused) {
        // RESUME
        await _apiService.resumeAgentDuty();
        if (mounted) {
          setState(() {
            _isTimerPaused = false;
            _lastToggleTimestamp = DateTime.now();
          });
          CustomSnackBar.showSuccess(context, 'Duty Resumed');
        }
      } else {
        // PAUSE
        await _apiService.pauseAgentDuty();
        if (mounted) {
          setState(() {
            _isTimerPaused = true;
            _lastToggleTimestamp = DateTime.now();
          });
          CustomSnackBar.showSuccess(context, 'Duty Paused');
        }
      }
    } catch (e) {
      if (!mounted) return;

      // Handle "Already active" or "Already paused" as success state sync
      final msg = e.toString().toLowerCase();
      if (e is ValidationException &&
          (msg.contains('active') || msg.contains('paused'))) {
        // Correct the state based on message to match server reality
        if (msg.contains('active')) {
          // Server says active, so Ensure UI is Resumed
          setState(() {
            _isTimerPaused = false;
          });
          CustomSnackBar.showSuccess(context, 'Duty is Active');
        } else if (msg.contains('paused')) {
          // Server says paused, Ensure UI is Paused
          setState(() {
            _isTimerPaused = true;
          });
          CustomSnackBar.showSuccess(context, 'Duty is Paused');
        }
      } else {
        CustomSnackBar.showError(context, 'Action failed: $e');
      }
    }
  }

  Future<void> _initDashboard() async {
    // If parent passed dutyStatus, use it to set timer state logic if needed
    // Note: _secondsOnDuty is primarily updated by _fetchPartnerSummary below

    // Re-fetch everything
    _fetchOrders(refresh: true);
    _fetchProfile();
    _fetchPartnerSummary();
    _fetchDeliveryStats();
    _fetchLoginHours();

    // Fetch notifications for badge
    if (mounted) {
      Provider.of<NotificationsViewModel>(context, listen: false)
          .fetchNotifications(refresh: true);
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final profileResponse = await _apiService.getProfile();
      if (mounted && profileResponse.data != null) {
        setState(() {
          _userProfile = profileResponse.data;
        });
      }
    } catch (e) {
      if (e is! NetworkException) {
        log('Error fetching profile: $e');
      }
    }
  }

  Future<void> _fetchPartnerSummary() async {
    try {
      final summary = await _apiService.getPartnerProfileSummary();
      if (mounted) {
        setState(() {
          _partnerSummary = summary;

          // Sync local pause state with server status
          // Skip sync if we recently toggled (within 10 seconds) to avoid flicker from stale data
          final bool recentlyToggled = _lastToggleTimestamp != null &&
              DateTime.now().difference(_lastToggleTimestamp!).inSeconds < 10;

          if (!recentlyToggled) {
            final status = summary.dutyStatus?.toLowerCase();
            if (status == 'paused') {
              _isTimerPaused = true;
            } else if (status == 'online' || status == 'active') {
              // Only auto-resume if we were paused locally but server explicitly says online/active
              if (_isTimerPaused) {
                _isTimerPaused = false;
              }
            }
          }
        });
      }
    } catch (e) {
      if (e is! NetworkException) {
        log('Error fetching partner summary: $e');
      }
    }
  }

  Future<void> _fetchDeliveryStats() async {
    try {
      final statusResponse = await _apiService.getDeliveryStatus();
      if (mounted && statusResponse.data != null) {
        setState(() {
          _completedDeliveries = statusResponse.data!.deliveredOrders;
          _cancelledOrders = statusResponse.data!.cancelledOrders;
          _pendingOrders = statusResponse.data!.pendingOrders;
        });
      }
    } catch (e) {
      log('Error fetching delivery stats: $e');
    }
  }

  Future<void> _fetchOrders({bool refresh = true}) async {
    if (!mounted) return;
    if (refresh) {
      if (_newRequests.isEmpty &&
          _availableOrders.isEmpty &&
          _currentOrder == null) {
        setState(() {
          _isLoading = true;
        });
      }
    }

    try {
      // 1. Check for active order first
      final activeOrderData = await _apiService.getCurrentOrder();

      // We will use this active order as the primary dashboard card if it exists
      Order? activeOrder;

      if (activeOrderData != null &&
          activeOrderData.isNotEmpty &&
          activeOrderData['id'] != null &&
          mounted) {
        try {
          // The current order API returns a partial object. We need to fetch the full details
          // to get vendor, items, etc. correctly.
          final minimalOrder = Order.fromJson(activeOrderData);
          log('Found active order ID: ${minimalOrder.id}. Fetching full details...');

          activeOrder = await _apiService.getOrderDetails(minimalOrder.id);
          log('Successfully fetched full details for order: ${activeOrder.id}');
        } catch (e) {
          log('Failed to fetch full details for current order: $e');
          // Fallback to minimal order if full fetch fails, or just ignore it?
          // For now, let's use minimal if we can, but it might lack data.
          // Better to show nothing than broken data, but let's try-catch safe.
          try {
            activeOrder = Order.fromJson(activeOrderData);
          } catch (parseError) {
            log('Failed to parse current order data: $parseError');
            activeOrder = null;
          }
        }
      }

      // Fetch new orders (New Requests)
      final newRequestsResponse = await _apiService.getNewOrders(page: 1);

      // Fetch available orders (Nearby Available)
      final availableResponse = await _apiService.getAvailableOrders(page: 1);

      // Fetch my orders (queue)
      final myOrdersResponse = await _apiService.getMyOrders(page: 1);

      if (mounted) {
        setState(() {
          log('Auth Token Set: Dashboard Refresh'); // Debug log

          // Filter out orders that are currently being removed (or have been processed locally)
          // We only filter new/available lists to hide them. We do NOT filter _myOrders,
          // so that if we just Accepted one, it can appear (if server has it), or if we are optimistic, we keep it.
          // Note: If server is stale and misses the Accepted order, it will disappear from _myOrders momentarily
          // until server syncs. This is an accepted tradeoff for now to ensure it CLEARS from Available.
          // Filter raw lists
          final pendingRaw = newRequestsResponse.data
              .where((o) => !_removingOrderIds.contains(o.id))
              .toList();

          final availableRaw = availableResponse.data
              .where((o) => !_removingOrderIds.contains(o.id))
              .toList();

          // Combine all incoming work
          final allIncoming = [...pendingRaw, ...availableRaw];

          // PER USER REQUEST:
          // 1. Show only top 2 orders in "New Order Request" section
          // 2. Show "all other" in "Available Orders" section
          if (allIncoming.isNotEmpty) {
            _newRequests = allIncoming.take(2).toList();
            _availableOrders = allIncoming.skip(2).toList();
          } else {
            _newRequests = [];
            _availableOrders = [];
          }

          _myOrders = myOrdersResponse.data
              // .where((o) => !_removingOrderIds.contains(o.id)) // <--- REMOVED FILTER for MyOrders
              .toList();

          _availablePage = 1;
          _myOrdersPage = 1;
          _hasMoreAvailable = (availableResponse.currentPage ?? 1) <
              (availableResponse.lastPage ?? 1);
          _hasMoreMyOrders = (myOrdersResponse.currentPage ?? 1) <
              (myOrdersResponse.lastPage ?? 1);

          // Sync pending orders with local queue length for consistency
          _pendingOrders = _myOrders.length;

          if (activeOrder != null) {
            _currentOrder = activeOrder;
            // Ensure this active order is also reflected in myOrders list if it matches
            if (_myOrders.any((o) => o.id == activeOrder!.id)) {
              final index =
                  _myOrders.indexWhere((o) => o.id == activeOrder!.id);
              _myOrders[index] = activeOrder;
            }
          } else if (_myOrders.isNotEmpty) {
            // If no "active" order from partner/orders/current, check queue
            // The first order in queue is effectively the current task
            _currentOrder = _myOrders.first;
          } else {
            _currentOrder = null;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (e is! NetworkException) {
        log('Error fetching orders: $e');
      }

      if (mounted) {
        if (e is UnauthorisedException) {
          await SharedPrefsUtil.clearSession();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (route) => false);
          }
        } else {
          // Only show error UI if it's a forced refresh or we have no data at all
          if (refresh ||
              (_availableOrders.isEmpty &&
                  _myOrders.isEmpty &&
                  _newRequests.isEmpty)) {
            setState(() {
              // Error occurred
              // Error occurred
              _isLoading = false;
            });
          } else {
            // Silently fail for background refresh
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  Future<void> _fetchLoginHours() async {
    try {
      final hours = await _apiService.getLoginHours();
      if (mounted) {
        setState(() {
          // Only update server hours if they have increased or it's the first sync
          if (hours > _serverLoginHours) {
            _serverLoginHours = hours;
            // Reset local, but keep any fractional overlap if needed.
            // Simplified: Reset local to 0 when we get a fresh authoritative update
            // However, to prevent "rewind", we only reset if the new server time is
            // indeed accounting for the time we just spent.
            // If server update is slow, _serverLoginHours might be old.
            // Strategy: _serverLoginHours accepts the new value.
            // We do NOT reset _localSessionSeconds immediately to 0 unless we are sure.
            // Actually, best approach for a "stopwatch" that syncs:
            // Total = Max(ServerValue, OldTotal) --> This handles "server lag"
            // But we want to show ticking.
            // Better: _serverLoginHours = hours; _localSessionSeconds = 0;
            // But this causes the "jump back" if server < (oldServer + local).
            //
            // Fix: We assume `hours` from server is the "truth" as of moment X.
            // We just set _serverLoginHours. To avoid jump back, we can dampen:
            final double currentTotal =
                _serverLoginHours + (_localSessionSeconds / 3600.0);
            if (hours > currentTotal) {
              // Server has caught up and passed us (likely). Sync up.
              _serverLoginHours = hours;
              _localSessionSeconds = 0;
            } else {
              // Server is lagging behind our local count.
              // We do NOT update _serverLoginHours to the lower value,
              // OR we update it but adjust local seconds to maintain the total.
              // Let's do the latter to keep base fresh.
              // newServer (10.0) < currentTotal (10.1)
              // We want displayed to still be 10.1
              // So newLocal = (currentTotal - newServer) converted to seconds
              final diffHours = currentTotal - hours;
              _serverLoginHours = hours;
              _localSessionSeconds = (diffHours * 3600).round();
            }
          }
        });
      }
    } catch (e) {
      log('Error fetching login hours: $e');
    }
  }

  Future<void> _loadMoreAvailableOrders() async {
    if (_isAvailableLoadingMore || !_hasMoreAvailable) return;

    setState(() {
      _isAvailableLoadingMore = true;
    });

    try {
      final nextPage = _availablePage + 1;
      final response = await _apiService.getAvailableOrders(page: nextPage);

      if (mounted) {
        setState(() {
          _availableOrders.addAll(response.data);
          _availablePage = nextPage;
          _hasMoreAvailable = (response.currentPage ?? nextPage) <
              (response.lastPage ?? nextPage);
          _isAvailableLoadingMore = false;
        });
      }
    } catch (e) {
      if (e is! NetworkException) {
        log('Error loading more available orders: $e');
      }
      if (mounted) {
        setState(() {
          _isAvailableLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreMyOrders() async {
    if (_isMyOrdersLoadingMore || !_hasMoreMyOrders) return;

    setState(() {
      _isMyOrdersLoadingMore = true;
    });

    try {
      final nextPage = _myOrdersPage + 1;
      final response = await _apiService.getMyOrders(page: nextPage);

      if (mounted) {
        setState(() {
          _myOrders.addAll(response.data);
          _myOrdersPage = nextPage;
          _hasMoreMyOrders = (response.currentPage ?? nextPage) <
              (response.lastPage ?? nextPage);
          _isMyOrdersLoadingMore = false;
        });
      }
    } catch (e) {
      if (e is! NetworkException) {
        log('Error loading more my orders: $e');
      }
      if (mounted) {
        setState(() {
          _isMyOrdersLoadingMore = false;
        });
      }
    }
  }

  Future<void> _acceptOrder(int orderId) async {
    if (!mounted) return;

    setState(() {
      _removingOrderIds.add(orderId);
    });

    try {
      // Show loading
      CustomSnackBar.showSuccess(context, 'Accepting order...');

      final response = await _apiService.acceptOrder(orderId);

      if (!mounted) return;

      if (response['status'] == true || response['status'] == 'success') {
        // Parse the accepted order from the response
        Order? orderToAccept;
        if (response['data'] != null) {
          orderToAccept = Order.fromJson(response['data']);
        }

        // Fallback: If response doesn't have data, try to find it locally
        if (orderToAccept == null) {
          try {
            orderToAccept = _newRequests.firstWhere((o) => o.id == orderId);
          } catch (_) {
            try {
              orderToAccept =
                  _availableOrders.firstWhere((o) => o.id == orderId);
            } catch (_) {
              // Last resort fallback
              orderToAccept = Order(
                id: orderId,
                userId: _userProfile?.userId ?? 0,
                orderNumber: '',
                subtotal: '0',
                deliveryCharge: '0',
                discount: '0',
                couponDiscount: '0',
                totalAmount: '0',
                orderItems: [],
                status: 'accepted', // Default to accepted
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
            }
          }
        }

        if (!context.mounted) return;

        // --- LOCAL STATE UPDATE ---
        setState(() {
          // Broadly remove from all source lists
          _newRequests.removeWhere((o) => o.id == orderId);
          _availableOrders.removeWhere((o) => o.id == orderId);

          // Add to My Queue
          _myOrders.add(orderToAccept!);

          // Update Pending Count
          _pendingOrders = _myOrders.length;

          // Update Current Order if null
          if (_currentOrder == null && _myOrders.isNotEmpty) {
            _currentOrder = _myOrders.first;
          }
        });

        // Sync with Deliveries Tab ViewModel
        if (context.mounted) {
          Provider.of<OrderListViewModel>(context, listen: false)
              .fetchActiveOrders(refresh: true);
        }

        await _showAcceptSuccessDialog(orderToAccept);
      } else {
        if (!context.mounted) return;
        CustomSnackBar.showError(
            context, response['message'] ?? 'Failed to accept order');
        if (mounted) {
          setState(() {
            _removingOrderIds.remove(orderId);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Error: ${e.toString()}');
        setState(() {
          _removingOrderIds.remove(orderId);
        });
      }
    }
    // Finally block removed to persist the hidden state
  }

  Future<void> _rejectOrder(int orderId) async {
    if (!mounted) return;

    try {
      // 1. Fetch Reasons
      log('Fetching cancellation reasons for rejection...');
      final reasons = await _apiService.getCancellationReasons();

      if (!mounted) return;

      // 2. Show Dialog
      final int? selectedReasonId = await showDialog<int>(
        context: context,
        barrierDismissible: true,
        builder: (context) => OrderCancellationDialog(reasons: reasons),
      );

      if (selectedReasonId == null) {
        log('Rejection cancelled by user');
        return; // User dismissed
      }

      // Find reason text
      final selectedReason = reasons.firstWhere(
        (r) => r.id == selectedReasonId,
        orElse: () => CancellationReason(id: -1, reason: 'Unknown'),
      );

      // 3. Perform Rejection
      setState(() {
        _removingOrderIds.add(orderId);
      });

      log('Rejecting order $orderId with reason ${selectedReason.reason}');

      // Use rejectOrder for new/available orders
      final response = await _apiService.rejectOrder(orderId, selectedReasonId);

      if (!mounted) return;

      if (response['status'] == true || response['status'] == 'success') {
        if (!context.mounted) return;

        // --- IMMEDIATE LOCAL REMOVAL ---
        setState(() {
          _newRequests.removeWhere((o) => o.id == orderId);
          _availableOrders.removeWhere((o) => o.id == orderId);
          _myOrders.removeWhere((o) => o.id == orderId);
          _pendingOrders = _myOrders.length;
        });

        // Pass the actual reason string
        await _showRejectSuccessDialog(orderId, selectedReason.reason);
      } else {
        if (!context.mounted) return;

        // Handle 404 - Order not available as a success (already removed from server)
        if (response['message']?.toString().contains('Order not available') ==
            true) {
          log('Order $orderId already not available on server, removing from local state.');

          // --- IMMEDIATE LOCAL REMOVAL ---
          setState(() {
            _newRequests.removeWhere((o) => o.id == orderId);
            _availableOrders.removeWhere((o) => o.id == orderId);
            _myOrders.removeWhere((o) => o.id == orderId);
            _pendingOrders = _myOrders.length;
          });

          await _showRejectSuccessDialog(orderId, selectedReason.reason);
          return;
        }

        CustomSnackBar.showError(
            context, response['message'] ?? 'Failed to reject order');
        if (mounted) {
          setState(() {
            _removingOrderIds.remove(orderId);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        log('Error in rejection flow: $e');

        // Check if the error message indicates the order is already gone
        if (e.toString().contains('Order not available')) {
          log('Caught "Order not available" exception, removing from local state.');

          // --- IMMEDIATE LOCAL REMOVAL ---
          setState(() {
            _newRequests.removeWhere((o) => o.id == orderId);
            _availableOrders.removeWhere((o) => o.id == orderId);
            _myOrders.removeWhere((o) => o.id == orderId);
            _pendingOrders = _myOrders.length;
          });

          await _showRejectSuccessDialog(orderId, 'Order already removed');
          return;
        }

        CustomSnackBar.showError(context, 'Error: ${e.toString()}');
        if (mounted) {
          setState(() {
            _removingOrderIds.remove(orderId);
          });
        }
      }
    }
    // Finally block removed to persist the hidden state
  }

  // Removed unused _tag method

  Widget _myQueueItem(Order order) {
    // Determine if it's pickup or dropoff based on status
    final bool isPickup = [
      'pending',
      'queued',
      'accepted',
      'ready_for_pickup',
      'assigned'
    ].contains(order.status.toLowerCase());

    return GestureDetector(
      onTap: () => _navigateToOrder(order),
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(12)),
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(R.w(12)),
              decoration: BoxDecoration(
                color: isPickup
                    ? AppColors.primaryGreen.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPickup
                    ? RemixIcons.shopping_bag_3_fill
                    : RemixIcons.home_4_fill,
                color: isPickup ? AppColors.primaryGreen : Colors.blue,
                size: R.sp(22),
              ),
            ),
            SizedBox(width: R.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPickup
                        ? (order.vendor?.storeName ?? "Fresh Mart - Sector 45")
                        : (order.deliveryAddress?.addressLine1 ??
                            "Apt 402, Green Heights"),
                    style: TextStyle(
                      fontSize: R.sp(15),
                      fontWeight: FontWeight.w800,
                      color: AppColors.headingText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: R.h(2)),
                  Text(
                    isPickup
                        ? '${order.orderItems.length} Items • Ready in 2 mins'
                        : '1.4 km from Store',
                    style: TextStyle(
                      fontSize: R.sp(12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(4)),
              decoration: BoxDecoration(
                color:
                    isPickup ? AppColors.badgeGreenBg : AppColors.badgeBlueBg,
                borderRadius: BorderRadius.circular(R.r(8)),
              ),
              child: Text(
                isPickup ? 'PICKUP' : 'DROP',
                style: TextStyle(
                  fontSize: R.sp(10),
                  fontWeight: FontWeight.w800,
                  color: isPickup
                      ? AppColors.badgeGreenText
                      : AppColors.badgeBlueText,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(width: R.w(8)),
            Icon(RemixIcons.arrow_right_s_line,
                color: AppColors.bodyText.withValues(alpha: 0.3),
                size: R.sp(20)),
          ],
        ),
      ),
    );
  }

  void _navigateToOrder(Order order) {
    // 1. If delivered/completed, show summary
    if (order.status == 'delivered' || order.status == 'completed') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: DeliveryCompletedView(order: order),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
      return;
    }

    // 2. If it is already picked up, go to navigation/delivery view
    if (order.pickupProof != null ||
        ['picked_up', 'in_progress'].contains(order.status.toLowerCase())) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: NavigationView(orderId: order.id, order: order),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
      return;
    }

    // 3. Otherwise (accepted, ready_for_pickup, queued, pending), go to pickup task
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: PickupTaskView(
        orderId: order.id,
        orderNumber: order.orderNumber,
        order: order,
      ),
      withNavBar: true,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  Widget _availableOrderItem(Order order) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(16)),
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)), // More rounded
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: ID - Badge - Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#${order.id}',
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.w800,
                  color: AppColors.headingText,
                ),
              ),
              SizedBox(width: R.w(12)),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(R.r(6)),
                ),
                child: Text(
                  'NEARBY',
                  style: TextStyle(
                    fontSize: R.sp(10),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${(double.tryParse(order.totalAmount) ?? 65.0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: R.sp(18),
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingText,
                    ),
                  ),
                  SizedBox(height: R.h(2)),
                  Text(
                    'EST. PAYOUT',
                    style: TextStyle(
                      fontSize: R.sp(10),
                      fontWeight: FontWeight.w700,
                      color: AppColors.bodyText.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(16)),

          // Row 2: Details
          Row(
            children: [
              Icon(RemixIcons.shopping_basket_2_fill,
                  size: R.sp(18),
                  color: AppColors.bodyText.withValues(alpha: 0.6)),
              SizedBox(width: R.w(6)),
              Text(
                '${order.orderItems.length} items',
                style: TextStyle(
                  fontSize: R.sp(14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyText.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(width: R.w(24)),
              Icon(RemixIcons.map_pin_fill,
                  size: R.sp(18), color: AppColors.primaryGreen),
              SizedBox(width: R.w(4)),
              Text(
                '${order.distance ?? '2.5'} km',
                style: TextStyle(
                  fontSize: R.sp(14),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(24)),

          // Row 3: Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _acceptOrder(order.id),
                  child: Container(
                    height: R.h(50),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen, // Bright Green
                      borderRadius:
                          BorderRadius.circular(R.r(50)), // Pill shape
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.w(16)),
              Expanded(
                child: GestureDetector(
                  onTap: () => _rejectOrder(order.id),
                  child: Container(
                    height: R.h(50),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.ghostButtonBg, // Grey
                      borderRadius:
                          BorderRadius.circular(R.r(50)), // Pill shape
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w800,
                        color: AppColors.ghostButtonText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({required String title, Widget? action, int? count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: R.sp(18),
                fontWeight: FontWeight.w900,
                color: AppColors.headingText,
              ),
            ),
            if (count != null && count > 0) ...[
              SizedBox(width: R.w(8)),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(R.r(12)),
                  border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.2)),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: R.sp(11),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (action != null) action,
      ],
    );
  }

  bool get _isWaiting =>
      _newRequests.isEmpty &&
      _availableOrders.isEmpty &&
      _myOrders.isEmpty &&
      _currentOrder == null;

  Widget _buildInfoBanner() {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(16)),
      padding: EdgeInsets.all(R.w(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(12)),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(R.w(8)),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4E5), // Light Orange
              shape: BoxShape.circle,
            ),
            child: Icon(RemixIcons.information_fill,
                color: const Color(0xFFFF9800), size: R.sp(18)),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No new orders found.',
                  style: TextStyle(
                    fontSize: R.sp(13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.headingText,
                  ),
                ),
                Text(
                  'We will notify you as soon as a task is assigned.',
                  style: TextStyle(
                    fontSize: R.sp(11),
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final isOnline = widget.isOnline;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: R.w(16),
              vertical: R.h(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeaderShimmer(),
                Expanded(
                  child: DashboardShimmer(
                    hasOrders: _currentOrder != null ||
                        _newRequests.isNotEmpty ||
                        _availableOrders.isNotEmpty ||
                        _myOrders.isNotEmpty,
                    showCurrentTask: _currentOrder != null,
                    showQueue: _myOrders.length > 1,
                    showNewRequests: _newRequests.isNotEmpty,
                    showAvailableOrders: _availableOrders.isNotEmpty,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: R.w(16),
            vertical: R.h(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dashboardHeader(isOnline),
              // Show Info Banner if waiting OR offline
              if (_isWaiting) _buildInfoBanner(),

              if (isOnline && _isTimerPaused)
                Padding(
                  padding: EdgeInsets.only(bottom: R.h(16)),
                  child: GestureDetector(
                    onTap: _toggleTimerPause,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(16), vertical: R.h(12)),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(R.r(12)),
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(RemixIcons.pause_circle_fill,
                              color: AppColors.warning, size: R.sp(20)),
                          SizedBox(width: R.w(12)),
                          Expanded(
                            child: Text(
                              'Timer is paused. Tap to resume.',
                              style: TextStyle(
                                fontSize: R.sp(14),
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                          if (widget.dutyStatus?.toLowerCase() == 'paused')
                            GestureDetector(
                                onTap: () async {
                                  try {
                                    CustomSnackBar.showSuccess(
                                        context, 'Resuming duty...');
                                    await _apiService.resumeAgentDuty();
                                    if (!mounted) return;
                                    setState(() {
                                      _isTimerPaused = false;
                                      _lastToggleTimestamp = DateTime.now();
                                    });
                                    widget.onStatusChanged(true);
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    CustomSnackBar.showError(
                                        context, 'Failed to resume: $e');
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: R.w(12), vertical: R.h(6)),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    borderRadius:
                                        BorderRadius.circular(R.r(20)),
                                  ),
                                  child: Text('RESUME',
                                      style: TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: R.sp(12))),
                                ))
                          else
                            Icon(RemixIcons.arrow_right_s_line,
                                color: AppColors.warning, size: R.sp(18)),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_isWaiting)
                Padding(
                  padding: EdgeInsets.only(top: R.h(8), bottom: R.h(12)),
                  child: DashboardWaitingState(
                    isOnline: isOnline,
                    completedToday: _completedDeliveries,
                    dailyGoal: _dailyGoal,
                    onToggle: () => widget.onStatusChanged(!isOnline),
                  ),
                )
              else
                AbsorbPointer(
                  absorbing: !isOnline &&
                      _myOrders.isEmpty &&
                      _currentOrder == null &&
                      _newRequests.isEmpty &&
                      _availableOrders.isEmpty,
                  child: ColorFiltered(
                    colorFilter: isOnline ||
                            _myOrders.isNotEmpty ||
                            _currentOrder != null ||
                            _newRequests.isNotEmpty ||
                            _availableOrders.isNotEmpty
                        ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.dst)
                        : const ColorFilter.mode(
                            AppColors.grey, BlendMode.saturation),
                    child: Opacity(
                      opacity: isOnline ||
                              _myOrders.isNotEmpty ||
                              _currentOrder != null ||
                              _newRequests.isNotEmpty ||
                              _availableOrders.isNotEmpty
                          ? 1.0
                          : 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. New Order Request (Top Priority)
                          if (_newRequests.isNotEmpty) ...[
                            _sectionHeader(
                              title: 'New Order Request',
                              count: _newRequests.length,
                            ),
                            SizedBox(height: R.h(12)),
                            // Header is now inside KeyRequestCard
                            Column(
                              children: _newRequests
                                  .where((order) =>
                                      !_removingOrderIds.contains(order.id))
                                  .map((order) {
                                final now = DateTime.now();
                                final difference =
                                    now.difference(order.createdAt);
                                final remaining = 60 - difference.inSeconds;
                                final countdown = remaining > 0 ? remaining : 0;

                                return NewRequestCard(
                                  order: order,
                                  countdownSeconds: countdown,
                                  onAccept: () => _acceptOrder(order.id),
                                  onDecline: () => _rejectOrder(order.id),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: R.h(24)),
                          ],

                          // 2. My Queue (Pending Orders including Active)
                          if (_myOrders.isNotEmpty) ...[
                            _sectionHeader(
                              title: 'My Queue',
                              count: _myOrders.length,
                            ),
                            SizedBox(height: R.h(12)),
                            Column(
                              children: _myOrders
                                  .take(3) // Show up to 3 items
                                  .map((order) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: R.h(12)),
                                  child: AnimatedOrderCard(
                                    key: ValueKey(order.id),
                                    child: _myQueueItem(order),
                                  ),
                                );
                              }).toList(),
                            ),
                            if (_hasMoreMyOrders)
                              Padding(
                                padding: EdgeInsets.only(top: R.h(8)),
                                child: Center(
                                  child: TextButton(
                                    onPressed: _isMyOrdersLoadingMore
                                        ? null
                                        : _loadMoreMyOrders,
                                    child: _isMyOrdersLoadingMore
                                        ? SizedBox(
                                            width: R.w(20),
                                            height: R.w(20),
                                            child:
                                                const CircularProgressIndicator(
                                                    strokeWidth: 2),
                                          )
                                        : const Text('Load More'),
                                  ),
                                ),
                              ),
                            SizedBox(height: R.h(24)),
                          ],

                          // 3. Nearby Available (Pool)
                          if (_availableOrders.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(R.w(6)),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF9800), // Orange
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(RemixIcons.compass_3_fill,
                                          color: Colors.white, size: R.sp(14)),
                                    ),
                                    SizedBox(width: R.w(8)),
                                    Text(
                                      'Available Orders',
                                      style: TextStyle(
                                        fontSize: R.sp(18),
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.headingText,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_availableOrders.length > 2)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isAvailableExpanded =
                                            !_isAvailableExpanded;
                                      });
                                    },
                                    child: Text(
                                      _isAvailableExpanded
                                          ? 'View Less'
                                          : 'View All',
                                      style: TextStyle(
                                        fontSize: R.sp(14),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: R.h(16)),
                            Builder(builder: (context) {
                              final ordersToShow = (_isAvailableExpanded
                                      ? _availableOrders
                                      : _availableOrders.take(2))
                                  .where((order) =>
                                      !_removingOrderIds.contains(order.id))
                                  .toList();
                              return Column(
                                children: ordersToShow
                                    .map((order) => _availableOrderItem(order))
                                    .toList(),
                              );
                            }),
                            if (_hasMoreAvailable && _isAvailableExpanded)
                              Padding(
                                padding: EdgeInsets.only(top: R.h(8)),
                                child: Center(
                                  child: TextButton(
                                    onPressed: _isAvailableLoadingMore
                                        ? null
                                        : _loadMoreAvailableOrders,
                                    child: _isAvailableLoadingMore
                                        ? SizedBox(
                                            width: R.w(20),
                                            height: R.w(20),
                                            child:
                                                const CircularProgressIndicator(
                                                    strokeWidth: 2),
                                          )
                                        : const Text('Load More'),
                                  ),
                                ),
                              ),
                            SizedBox(height: R.h(24)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(height: R.h(24)),
              PerformanceStatsRow(
                pending: _pendingOrders > 0 ? _pendingOrders : _myOrders.length,
                completed: _completedDeliveries,
                cancelled: _cancelledOrders,
                loginHours: _serverLoginHours + (_localSessionSeconds / 3600.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAcceptSuccessDialog(Order order) async {
    // Navigate to Order Accepted Success View (Full Screen)
    // This hides the bottom nav bar automatically when pushed with PersistentNavBarNavigator or standard push if rootNavigator is used.

    if (!mounted) return;

    // We use pushNewScreen withNavBar: false to hide the bottom nav
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: OrderAcceptedSuccessView(order: order),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    ).then((_) {
      // Refresh orders when coming back (if they navigate back instead of to pickup)
      _fetchOrders();
    });
  }

  Future<void> _showRejectSuccessDialog(int orderId, String reason) async {
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OrderRejectedFeedbackView(orderId: orderId, reason: reason),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    _fetchOrders(refresh: false);
  }

  String _formatLoginTime(double seconds) {
    if (seconds <= 0) return '00:00:00';
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = (seconds % 60).toInt();
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _dashboardHeader(bool isOnline) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT SIDE - Duty Mode Toggle
          DutyStatusCard(
            isOnline: isOnline,
            onToggle: () => widget.onStatusChanged(!isOnline),
          ),

          /// RIGHT SIDE - Timer & Notification
          Row(
            children: [
              // Timer Display
              // Timer Display (Tap to Pause/Resume)
              // Return Flow button removed from here
              GestureDetector(
                onTap: _toggleTimerPause,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(8), vertical: R.h(8)),
                  decoration: BoxDecoration(
                    color: _isTimerPaused
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(R.r(100)),
                    border: _isTimerPaused
                        ? Border.all(
                            color: AppColors.warning.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isTimerPaused
                            ? RemixIcons.pause_circle_fill
                            : RemixIcons.time_fill,
                        color: _isTimerPaused
                            ? AppColors.warning
                            : AppColors.primaryGreen,
                        size: R.sp(18),
                      ),
                      SizedBox(width: R.w(8)),
                      Text(
                        _isTimerPaused
                            ? 'Paused'
                            : _formatLoginTime((_serverLoginHours * 3600) +
                                _localSessionSeconds),
                        style: TextStyle(
                          fontSize: R.sp(13),
                          fontWeight: FontWeight.w800,
                          color: _isTimerPaused
                              ? AppColors.warning
                              : AppColors.headingText,
                        ),
                      ),
                      if (!_isTimerPaused) ...[
                        SizedBox(width: R.w(4)),
                        Icon(RemixIcons.pause_mini_fill,
                            size: R.sp(16),
                            color: AppColors.grey.withValues(alpha: 0.5)),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(width: R.w(6)),
              // Notification Bell
              Consumer<NotificationsViewModel>(
                builder: (context, vm, _) {
                  return GestureDetector(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: const NotificationsView(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Container(
                      width: R.w(42),
                      height: R.w(42),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            RemixIcons.notification_4_fill,
                            size: R.sp(22),
                            color: AppColors.headingText,
                          ),
                          if (vm.unreadCount > 0)
                            Positioned(
                              top: R.h(10),
                              right: R.w(10),
                              child: Container(
                                width: R.w(8),
                                height: R.w(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
