import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/view/notification/notifications_view.dart';

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/view_model/notifications_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_list_view_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:animations/animations.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_network_image.dart';
import 'package:samrudhi_delivery_agent_app/widget/order_shimmer.dart';
import 'package:samrudhi_delivery_agent_app/widget/animated_order_card.dart';
import 'package:samrudhi_delivery_agent_app/widget/dashboard_shimmer.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_details_view.dart';
import 'package:samrudhi_delivery_agent_app/model/profile_model.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/dashboard_waiting_state.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_summary_model.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_retry_button.dart';
import 'package:samrudhi_delivery_agent_app/view/feedback/order_rejected_feedback_view.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_accepted_success_view.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/widgets/performance_stats_row.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/order_cancellation_dialog.dart';

class AgentDashboardView extends StatefulWidget {
  final bool isOnline;
  final String? dutyStatus; // Added parameter
  final ValueChanged<bool> onStatusChanged;
  final VoidCallback? onViewDeliveries;

  const AgentDashboardView({
    super.key,
    required this.isOnline,
    this.dutyStatus,
    required this.onStatusChanged,
    this.onViewDeliveries,
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

  String? _error;

  // Timer State
  Timer? _dutyTimer;
  int _secondsOnDuty = 0;
  bool _isTimerPaused = false;
  Timer? _dataRefreshTimer;

  // Pagination State
  int _availablePage = 1;
  int _myOrdersPage = 1;
  bool _hasMoreAvailable = false;
  bool _hasMoreMyOrders = false;
  bool _isAvailableLoadingMore = false;
  bool _isMyOrdersLoadingMore = false;

  String? _authToken;
  final Set<int> _removingOrderIds = {};
  ProfileModel? _userProfile;
  PartnerSummary? _partnerSummary;

  // Stats
  int _completedDeliveries = 0;
  int _pendingOrders = 0;
  int _cancelledOrders = 0;
  // Removed _earningsToday

  final int _dailyGoal = 15; // Hardcoded goal for now

  @override
  void initState() {
    super.initState();
    _initDashboard();
    // Initialize timer state based on initial props
    if (widget.isOnline) {
      if (widget.dutyStatus == 'paused') {
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
        _isTimerPaused = false; // Reset pause state when going online
        _startTimer();
      } else {
        _stopTimer();
        // Reset timer when explicitly stopping duty (User Request)
        setState(() {
          _secondsOnDuty = 0;
        });
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
      if (!_isTimerPaused) {
        if (mounted) {
          setState(() {
            _secondsOnDuty++;
          });
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
        _refreshData();
      }
    });
  }

  Future<void> _refreshData() async {
    // Silent refresh - no loading indicators
    await Future.wait([
      _fetchOrders(refresh: false),
      _fetchProfile(),
      _partnerSummary != null ? _fetchPartnerSummary() : Future.value(),
      _fetchDeliveryStats(),
    ]);
    if (mounted) {
      Provider.of<NotificationsViewModel>(context, listen: false)
          .fetchNotifications(refresh: false);
    }
  }

  Future<void> _toggleTimerPause() async {
    final token = _authToken ?? await SharedPrefsUtil.getToken();
    if (token == null) return;

    try {
      if (_isTimerPaused) {
        // RESUME
        await _apiService.resumeAgentDuty(token);
        if (mounted) {
          setState(() {
            _isTimerPaused = false;
          });
          CustomSnackBar.showSuccess(context, 'Duty Resumed');
          // Optionally notify parent if needed, but we manage pause locally mostly
          // widget.onStatusChanged(true);
        }
      } else {
        // PAUSE
        await _apiService.pauseAgentDuty(token);
        if (mounted) {
          setState(() {
            _isTimerPaused = true;
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
    final token = await SharedPrefsUtil.getToken();
    if (token != null) {
      if (mounted) {
        setState(() {
          _authToken = token;
        });
      }
      // If parent passed dutyStatus, use it to set timer state logic if needed
      // Note: _secondsOnDuty is primarily updated by _fetchPartnerSummary below

      // Re-fetch everything with the token
      _fetchOrders(refresh: true);
      _fetchProfile();
      _fetchPartnerSummary();
      _fetchDeliveryStats();

      // Fetch notifications for badge
      if (mounted) {
        Provider.of<NotificationsViewModel>(context, listen: false)
            .fetchNotifications(refresh: true);
      }
    } else {
      // Handle no token? Login screen?
      if (mounted) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final token = _authToken ?? await SharedPrefsUtil.getToken();
      if (token != null) {
        final profileResponse = await _apiService.getProfile(token);
        if (mounted && profileResponse.data != null) {
          setState(() {
            _userProfile = profileResponse.data;
          });
        }
      }
    } catch (e) {
      if (e is! NetworkException) {
        log('Error fetching profile: $e');
      }
    }
  }

  Future<void> _fetchPartnerSummary() async {
    try {
      final token = _authToken ?? await SharedPrefsUtil.getToken();
      if (token != null) {
        final summary = await _apiService.getPartnerProfileSummary(token);
        if (mounted) {
          setState(() {
            _partnerSummary = summary;
            // Sync local timer with server time ONLY if valid to avoid unwanted resets
            // User requested: "Timer reset only when stop duty"
            // So if server returns 0 or negative (invalid), ignore it to keep local count.
            if (summary.todayDutyTime > 0) {
              _secondsOnDuty = summary.todayDutyTime;
            }

            // Update stats from the new API
            if (summary.stats != null) {
              _completedDeliveries = summary.stats!.deliveredOrders;
              _pendingOrders = summary.stats!.totalOrdersToday -
                  summary.stats!.deliveredOrders; // Approx
            }
          });
        }
      }
    } catch (e) {
      if (e is! NetworkException) {
        log('Error fetching partner summary: $e');
      }
    }
  }

  String _formatDutyTime(int totalSeconds) {
    if (totalSeconds <= 0) return '00:00:00';
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _fetchOrders({bool refresh = true}) async {
    if (!mounted) return;
    if (refresh) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final token = _authToken ?? await SharedPrefsUtil.getToken();

      if (token == null) {
        if (mounted) {
          setState(() {
            _error = 'User not authenticated';
            _isLoading = false;
          });
        }
        return;
      }

      // 1. Check for active order first
      final activeOrderData = await _apiService.getCurrentOrder(token);

      // We will use this active order as the primary dashboard card if it exists
      Order? activeOrder;

      if (activeOrderData != null && mounted) {
        activeOrder = Order.fromJson(activeOrderData);
        log('Found active order: ${activeOrder.id}');

        // Only auto-navigate if it's a fresh app launch or explicit refresh
        // For now, let's prioritize showing it on dashboard cleanly
        // If we want auto-nav, we can keep it, but let's make sure _currentOrder is set below
      }

      // Fetch new orders (New Requests)
      final newRequestsResponse =
          await _apiService.getNewOrders(token, page: 1);

      // Fetch available orders (Nearby Available)
      final availableResponse =
          await _apiService.getAvailableOrders(token, page: 1);

      // Fetch my orders (queue)
      final myOrdersResponse = await _apiService.getMyOrders(token, page: 1);

      if (mounted) {
        setState(() {
          _authToken = token;
          log('Auth Token Set: ${_authToken?.substring(0, 10)}...'); // Debug log
          _newRequests = newRequestsResponse.data;
          _availableOrders = availableResponse.data;
          _myOrders = myOrdersResponse.data;

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

          _removingOrderIds.clear();
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
              _error = e.toString();
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

  Future<void> _fetchDeliveryStats() async {
    try {
      final token = _authToken ?? await SharedPrefsUtil.getToken();
      if (token == null) return;

      final deliveryStatus = await _apiService.getDeliveryStatus(token);
      if (deliveryStatus.status && deliveryStatus.data != null) {
        if (mounted) {
          setState(() {
            _completedDeliveries = deliveryStatus.data!.deliveredOrders;
            _pendingOrders = deliveryStatus.data!.pendingOrders;
            _cancelledOrders = deliveryStatus.data!.cancelledOrders;
            // If API returns target, set it here. For now using hardcoded _dailyGoal.
          });
        }
      }
    } catch (e) {
      if (e is! NetworkException) {
        log('Error fetching delivery stats: $e');
      }
    }
  }

  Future<void> _loadMoreAvailableOrders() async {
    if (_isAvailableLoadingMore || !_hasMoreAvailable) return;

    setState(() {
      _isAvailableLoadingMore = true;
    });

    try {
      final token = _authToken ?? await SharedPrefsUtil.getToken();
      if (token == null) return;

      final nextPage = _availablePage + 1;
      final response =
          await _apiService.getAvailableOrders(token, page: nextPage);

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
      final token = _authToken ?? await SharedPrefsUtil.getToken();
      if (token == null) return;

      final nextPage = _myOrdersPage + 1;
      final response = await _apiService.getMyOrders(token, page: nextPage);

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
      final token = _authToken ?? await SharedPrefsUtil.getToken();

      if (token == null) return;

      if (!mounted) return;

      // Show loading
      CustomSnackBar.showSuccess(context, 'Accepting order...');

      // Find the order object to pass to the next screen
      // Find the order object to pass to the next screen
      Order? orderToAccept;
      bool isFromNewRequests = false;
      try {
        orderToAccept = _newRequests.firstWhere((o) => o.id == orderId);
        isFromNewRequests = true;
      } catch (_) {
        try {
          orderToAccept = _availableOrders.firstWhere((o) => o.id == orderId);
        } catch (_) {
          // Fallback if not found in lists (shouldn't happen mainly)
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
            status: 'accepted',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }

      final response = await _apiService.acceptOrder(token, orderId);

      if (!mounted) return;

      if (response['status'] == true || response['status'] == 'success') {
        if (!context.mounted) return;

        // --- LOCAL STATE UPDATE ---
        setState(() {
          // 1. Remove from source list
          if (isFromNewRequests) {
            _newRequests.removeWhere((o) => o.id == orderId);
          } else {
            _availableOrders.removeWhere((o) => o.id == orderId);
          }

          // 2. Add to My Queue (at the end usually, or sorted by creation)
          // Ideally we clone it and status=accepted, but for now moving the object is fine
          // We assume the API returns the updated list on next refresh, but for immediate UI:
          _myOrders.add(orderToAccept!);

          // 3. Update Pending Count (Active Queue)
          _pendingOrders = _myOrders.length;

          // 4. Update Current Order if null
          if (_currentOrder == null && _myOrders.isNotEmpty) {
            _currentOrder = _myOrders.first;
          }

          _removingOrderIds.remove(orderId);
        });

        // 5. Sync with Deliveries Tab ViewModel
        if (context.mounted) {
          // We use read() here because we are in a callback/async function, not build
          Provider.of<OrderListViewModel>(context, listen: false)
              .fetchActiveOrders(refresh: true);
        }

        _showAcceptSuccessDialog(orderToAccept);
      } else {
        if (!context.mounted) return;
        CustomSnackBar.showError(
            context, response['message'] ?? 'Failed to accept order');
        setState(() {
          _removingOrderIds.remove(orderId);
        });
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Error: ${e.toString()}');
        setState(() {
          _removingOrderIds.remove(orderId);
        });
      }
    }
  }

  Future<void> _rejectOrder(int orderId) async {
    if (!mounted) return;

    try {
      final token = _authToken ?? await SharedPrefsUtil.getToken();
      if (token == null) return;

      // 1. Fetch Reasons
      log('Fetching cancellation reasons for rejection...');
      final reasons = await _apiService.getCancellationReasons(token);

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

      // 3. Perform Rejection
      setState(() {
        _removingOrderIds.add(orderId);
      });

      log('Rejecting order $orderId with reason $selectedReasonId');

      // Use cancelOrder if we have a reason, or rejectOrder as fallback
      final response =
          await _apiService.cancelOrder(token, orderId, selectedReasonId);

      if (!mounted) return;

      if (response['status'] == true || response['status'] == 'success') {
        if (!context.mounted) return;
        _showRejectSuccessDialog(orderId);
      } else {
        if (!context.mounted) return;
        CustomSnackBar.showError(
            context, response['message'] ?? 'Failed to reject order');
        setState(() {
          _removingOrderIds.remove(orderId);
        });
      }
    } catch (e) {
      if (mounted) {
        log('Error in rejection flow: $e');
        CustomSnackBar.showError(context, 'Error: ${e.toString()}');
        setState(() {
          _removingOrderIds.remove(orderId);
        });
      }
    }
  }

  Widget _newRequestCard(Order order) {
    // Determine image URL
    String? imageUrl;
    if (order.orderItems.isNotEmpty && order.orderItems.first.product != null) {
      final product = order.orderItems.first.product!;
      if (product.productImageUrls.isNotEmpty) {
        imageUrl = product.productImageUrls.first;
      } else if (product.productImages.isNotEmpty) {
        imageUrl = AppUrls.productImages + product.productImages.first;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: R.w(4), vertical: R.h(8)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
        border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section with Store Info
          Padding(
            padding: EdgeInsets.all(R.w(16)),
            child: Row(
              children: [
                // Store/Product Image
                Container(
                  width: R.w(56),
                  height: R.w(56),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    border: Border.all(color: AppColors.borderLight),
                    color: AppColors.softGreyBg,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    child: imageUrl != null
                        ? CustomNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: Icon(RemixIcons.store_2_line,
                                color: AppColors.grey),
                          )
                        : Icon(RemixIcons.store_2_line,
                            size: R.sp(24), color: AppColors.grey),
                  ),
                ),
                SizedBox(width: R.w(12)),
                // Order Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order.orderNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: R.sp(16),
                                fontWeight: FontWeight.w700,
                                color: AppColors.headingText,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: R.w(8), vertical: R.h(4)),
                            decoration: BoxDecoration(
                              color: AppColors.softGreenBg,
                              borderRadius: BorderRadius.circular(R.r(6)),
                            ),
                            child: Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: R.sp(10),
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: R.h(4)),
                      Text(
                        '${order.orderItems.length} items • 2.5 km', // Mock distance
                        style: TextStyle(
                          fontSize: R.sp(13),
                          color: AppColors.bodyText.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: R.h(4)),
                      Text(
                        order.deliveryAddress?.addressLine1 ??
                            'Delivery Address',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: R.sp(12),
                          color: AppColors.bodyText.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(16)),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),

          // Price and Actions
          Padding(
            padding: EdgeInsets.all(R.w(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EARNINGS',
                      style: TextStyle(
                        fontSize: R.sp(10),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.bodyText.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      '₹ ${order.totalAmount}',
                      style: TextStyle(
                        fontSize: R.sp(20),
                        fontWeight: FontWeight.w800,
                        color: AppColors.headingText,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Reject Button
                    SizedBox(
                      height: R.h(44),
                      child: OutlinedButton(
                        onPressed: () => _rejectOrder(order.id),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppColors.error.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(12)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: R.w(16)),
                        ),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                            fontSize: R.sp(14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(12)),
                    // Accept Button
                    SizedBox(
                      height: R.h(44),
                      child: ElevatedButton(
                        onPressed: () => _acceptOrder(order.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(12)),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: R.w(24)),
                        ),
                        child: Text(
                          'Accept',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: R.sp(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Removed unused _tag method

  Widget _myQueueItem(Order order) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(12)),
      padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
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
            padding: EdgeInsets.all(R.w(12)),
            decoration: BoxDecoration(
              color: AppColors.softGreenBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              RemixIcons.box_3_fill,
              color: AppColors.primaryGreen,
              size: R.sp(22),
            ),
          ),
          SizedBox(width: R.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER #${order.orderNumber}',
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: R.h(2)),
                Text(
                  order.orderNumber.contains('Mart') ||
                          order.orderNumber.contains('Hub')
                      ? order.orderNumber
                      : "Store # ${order.id}", // Fallback for demo
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w800,
                    color: AppColors.headingText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            RemixIcons.arrow_right_s_line,
            size: R.sp(22),
            color: AppColors.bodyText.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _availableOrderItem(Order order) {
    bool isNearby = (double.tryParse(order.distance ?? '0') ?? 0) < 3.0;

    return Container(
      margin: EdgeInsets.only(bottom: R.h(20)),
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ORDER ID & TAG
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${order.orderNumber}',
                        style: TextStyle(
                          fontSize: R.sp(18),
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingText,
                        ),
                      ),
                      SizedBox(width: R.w(10)),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: R.w(10), vertical: R.h(4)),
                        decoration: BoxDecoration(
                          color: isNearby
                              ? const Color(0xFFE8FFF3)
                              : const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(R.r(8)),
                        ),
                        child: Text(
                          isNearby ? 'NEARBY' : 'STANDARD',
                          style: TextStyle(
                            fontSize: R.sp(11),
                            fontWeight: FontWeight.w800,
                            color: isNearby
                                ? const Color(0xFF10CE67)
                                : const Color(0xFF74828F),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(8)),
                  // ITEMS & DISTANCE
                  Row(
                    children: [
                      Icon(RemixIcons.shopping_bag_3_line,
                          size: R.sp(16),
                          color: AppColors.bodyText.withOpacity(0.5)),
                      SizedBox(width: R.w(6)),
                      Text(
                        '${order.orderItems.length} items',
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w500,
                          color: AppColors.bodyText.withOpacity(0.6),
                        ),
                      ),
                      SizedBox(width: R.w(16)),
                      Icon(RemixIcons.map_pin_2_line,
                          size: R.sp(16), color: const Color(0xFF10CE67)),
                      SizedBox(width: R.w(6)),
                      Text(
                        '${order.distance ?? '0.0'} km',
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10CE67),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // PAYOUT
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${order.totalAmount}',
                    style: TextStyle(
                      fontSize: R.sp(22),
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingText,
                    ),
                  ),
                  Text(
                    'EST. PAYOUT',
                    style: TextStyle(
                      fontSize: R.sp(10),
                      fontWeight: FontWeight.w700,
                      color: AppColors.bodyText.withOpacity(0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(24)),
          // BUTTONS
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: R.h(54),
                  child: ElevatedButton(
                    onPressed: () => _acceptOrder(order.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10CE67),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(16)),
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: R.h(54),
                  child: ElevatedButton(
                    onPressed: () => _rejectOrder(order.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F3F5),
                      foregroundColor: const Color(0xFF74828F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(16)),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w700,
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

  Widget _currentTaskCard(Order order) {
    // Determine image URL
    String? imageUrl;
    if (order.orderItems.isNotEmpty && order.orderItems.first.product != null) {
      final product = order.orderItems.first.product!;
      if (product.productImageUrls.isNotEmpty) {
        imageUrl = product.productImageUrls.first;
      } else if (product.productImages.isNotEmpty) {
        imageUrl = AppUrls.productImages + product.productImages.first;
      }
    }

    return AnimatedOrderCard(
      key: ValueKey(order.id),
      visible: !_removingOrderIds.contains(order.id),
      child: GestureDetector(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: OrderDetailsView(
              orderId: order.id,
              orderNumber: order.orderNumber,
              order: order,
            ),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: Container(
          padding: EdgeInsets.all(R.w(16)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(R.r(16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Merchant / Order Info Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Merchant Logo / Image
                  Container(
                    width: R.w(50),
                    height: R.w(50),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(R.r(8)),
                      border: Border.all(color: AppColors.borderLight),
                      color: AppColors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(R.r(8)),
                      child: imageUrl != null
                          ? CustomNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: Icon(RemixIcons.store_2_line,
                                  color: AppColors.grey),
                            )
                          : Icon(RemixIcons.store_2_line,
                              size: R.sp(24), color: AppColors.black),
                    ),
                  ),
                  SizedBox(width: R.w(12)),
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'order_number_${order.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              order.orderNumber, // e.g. "Whole Foods Market"
                              style: TextStyle(
                                fontSize: R.sp(18),
                                fontWeight: FontWeight.w700,
                                color: AppColors.headingText,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: R.h(4)),
                        Row(
                          children: [
                            Icon(RemixIcons.shopping_bag_3_fill,
                                size: R.sp(14), color: AppColors.grey),
                            SizedBox(width: R.w(4)),
                            Text(
                              '${order.orderItems.length} items • Grocery', // Mock category if needed
                              style: TextStyle(
                                fontSize: R.sp(13),
                                color: AppColors.bodyText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  Text(
                    '₹ ${order.totalAmount}',
                    style: TextStyle(
                      fontSize: R.sp(18),
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.h(16)),

              // 2. Green Dropoff Box
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(16), vertical: R.h(12)),
                decoration: BoxDecoration(
                  color: AppColors.paleGreen, // Light green bg
                  borderRadius: BorderRadius.circular(R.r(12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dropoff by 4:45 PM', // Mock time or calculate
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: R.sp(13),
                            ),
                          ),
                          SizedBox(height: R.h(4)),
                          Text(
                            order.deliveryAddress?.addressLine1 ??
                                'Delivery Address',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.headingText,
                              fontWeight: FontWeight.w800,
                              fontSize: R.sp(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: R.w(12)),
                    // Chat Button
                    _iconButton(
                      icon: RemixIcons.message_2_line,
                      onTap: () {},
                    ),
                    SizedBox(width: R.w(8)),
                    // Phone Button
                    _iconButton(
                      icon: RemixIcons.phone_fill,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.h(16)),

              // 3. Navigate Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: OrderDetailsView(
                        orderId: order.id,
                        orderNumber: order.orderNumber,
                        order: order,
                      ),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(14)),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Navigate to Dropoff',
                        style: TextStyle(
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(width: R.w(8)),
                      Icon(RemixIcons.navigation_fill,
                          size: R.sp(18), color: AppColors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: R.sp(20), color: AppColors.headingText),
        onPressed: onTap,
        padding: EdgeInsets.all(R.w(8)),
        constraints: const BoxConstraints(),
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
                fontWeight: FontWeight.w800,
                color: AppColors.headingText,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: R.w(8)),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(2)),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.2), // #E0E2E7
                  borderRadius: BorderRadius.circular(R.r(6)),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.headingText,
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

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final isOnline = widget.isOnline;

    if (_isLoading) {
      return const DashboardShimmer();
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

              // Always Visible Stats
              Padding(
                padding: EdgeInsets.only(bottom: R.h(24)),
                child: PerformanceStatsRow(
                  pending: _pendingOrders > 0
                      ? _pendingOrders
                      : _myOrders.length, // Fallback to queue length
                  completed: _completedDeliveries,
                  cancelled: _cancelledOrders,
                  loginHours: _secondsOnDuty / 3600.0,
                ),
              ),

              if (widget.isOnline && _isTimerPaused)
                Padding(
                  padding: EdgeInsets.only(bottom: R.h(16)),
                  child: GestureDetector(
                    onTap: _toggleTimerPause,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(16), vertical: R.h(12)),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(R.r(12)),
                        border: Border.all(
                            color: AppColors.warning.withOpacity(0.5)),
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
                          if (widget.dutyStatus ==
                              'paused') // Only show resume button if strictly paused from API
                            GestureDetector(
                                onTap: () async {
                                  // TRIGGER RESUME API
                                  try {
                                    CustomSnackBar.showSuccess(
                                        context, 'Resuming duty...');
                                    await _apiService
                                        .resumeAgentDuty(_authToken!);
                                    if (!mounted) return;
                                    setState(() {
                                      _isTimerPaused = false;
                                    });
                                    // Propagate online status up just in case
                                    widget.onStatusChanged(true);
                                  } catch (e) {
                                    if (mounted)
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
              AbsorbPointer(
                absorbing: !isOnline,
                child: ColorFiltered(
                  colorFilter: isOnline
                      ? const ColorFilter.mode(
                          AppColors.transparent, BlendMode.multiply)
                      : const ColorFilter.matrix(<double>[
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                  child: Opacity(
                    opacity: isOnline ? 1.0 : 0.6,
                    child: Column(
                      children: [
                        (_newRequests.isEmpty &&
                                _availableOrders.isEmpty &&
                                _myOrders.isEmpty &&
                                _currentOrder == null &&
                                !_isLoading)
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: R.h(8), bottom: R.h(12)),
                                child: DashboardWaitingState(
                                  isOnline: isOnline,
                                  completedToday: _completedDeliveries,
                                  dailyGoal: _dailyGoal,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Current Task (Priority)
                                  if (_currentOrder != null) ...[
                                    _sectionHeader(
                                        title: 'Current Task & Delivery'),
                                    SizedBox(height: R.h(12)),
                                    _currentTaskCard(_currentOrder!),
                                    SizedBox(height: R.h(24)),
                                  ],

                                  // Delivery Queue (Priority)
                                  if (_myOrders.length > 1) ...[
                                    _sectionHeader(
                                      title: 'My Queue',
                                      count: _myOrders.length - 1,
                                      action: GestureDetector(
                                        onTap: widget.onViewDeliveries,
                                        child: Text(
                                          '${_myOrders.length - 1} more',
                                          style: TextStyle(
                                            fontSize: R.sp(14),
                                            color: AppColors.primaryGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: R.h(12)),
                                    Column(
                                      children: _myOrders
                                          .skip(1)
                                          .take(2)
                                          .map((order) {
                                        return Padding(
                                          padding:
                                              EdgeInsets.only(bottom: R.h(12)),
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

                                  // New Order Request

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _sectionHeader(
                                        title: 'New Order Request',
                                        count: null,
                                      ),
                                      SizedBox(height: R.h(12)),
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        transitionBuilder: (child, animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0.0, 0.05),
                                                end: Offset.zero,
                                              ).animate(animation),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: _isLoading
                                            ? const OrderShimmer()
                                            : _error != null
                                                ? Center(
                                                    key:
                                                        const ValueKey('error'),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(_error!,
                                                            style: const TextStyle(
                                                                color: AppColors
                                                                    .error)),
                                                        SizedBox(
                                                            height: R.h(16)),
                                                        CustomRetryButton(
                                                          onTap: () =>
                                                              _fetchOrders(
                                                                  refresh:
                                                                      true),
                                                          isLoading: _isLoading,
                                                        ),
                                                      ],
                                                    ))
                                                : _newRequests.isEmpty
                                                    ? Container(
                                                        key: const ValueKey(
                                                            'empty'),
                                                        width: double.infinity,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical:
                                                                    R.h(20)),
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Text(
                                                            'No new orders',
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .bodyText)))
                                                    : Column(
                                                        children: _newRequests
                                                            .map((order) =>
                                                                _newRequestCard(
                                                                    order))
                                                            .toList(),
                                                      ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: R.h(24)),

                                  // Available Orders
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _sectionHeader(
                                        title: 'Nearby Available',
                                        action: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: R.w(12),
                                              vertical: R.h(6)),
                                          decoration: BoxDecoration(
                                              color: AppColors
                                                  .softGreenBg, // Light Green
                                              borderRadius:
                                                  BorderRadius.circular(100)),
                                          child: Row(
                                            children: [
                                              Icon(RemixIcons.sparkling_2_fill,
                                                  size: R.sp(14),
                                                  color:
                                                      AppColors.primaryGreen),
                                              SizedBox(width: R.w(6)),
                                              Text(
                                                'Batch All',
                                                style: TextStyle(
                                                  fontSize: R.sp(13),
                                                  color: AppColors.primaryGreen,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: R.h(12)),
                                      // ... logic for available list or mock
                                      Builder(builder: (context) {
                                        if (_availableOrders.isEmpty) {
                                          return Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: R.h(20)),
                                              alignment: Alignment.center,
                                              child: const Text(
                                                  'No other available orders',
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.bodyText)));
                                        }
                                        return Column(
                                          children: _availableOrders
                                              .map((order) =>
                                                  _availableOrderItem(order))
                                              .toList(),
                                        );
                                      }),
                                      if (_hasMoreAvailable)
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
                                    ],
                                  ),
                                ],
                              ),

                        // Bottom Spacing
                        SizedBox(height: R.h(8)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(8)),
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

  Future<void> _showRejectSuccessDialog(int orderId) async {
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OrderRejectedFeedbackView(orderId: orderId),
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

  Widget _dashboardHeader(bool isOnline) {
    return Padding(
      padding: EdgeInsets.fromLTRB(R.w(4), R.h(6), R.w(4), R.h(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT SIDE
          Row(
            children: [
              // Toggle
              GestureDetector(
                onTap: () => widget.onStatusChanged(!isOnline),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: R.w(58),
                  height: R.h(30),
                  padding: EdgeInsets.all(R.w(3)),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? AppColors.primaryGreen
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    alignment:
                        isOnline ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: R.w(26),
                      height: R.w(26),
                      decoration: BoxDecoration(
                        color: isOnline ? AppColors.white : AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isOnline
                          ? Icon(Icons.check,
                              size: R.sp(16), color: AppColors.white)
                          : null,
                    ),
                  ),
                ),
              ),

              SizedBox(width: R.w(12)),

              // Status Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isTimerPaused || widget.dutyStatus == 'paused'
                        ? 'Paused'
                        : (isOnline ? 'Online' : 'Offline'),
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w800,
                      color: (_isTimerPaused || widget.dutyStatus == 'paused')
                          ? AppColors.warning
                          : AppColors.headingText,
                    ),
                  ),
                  Text(
                    'DUTY MODE',
                    style: TextStyle(
                      fontSize: R.sp(10),
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// RIGHT SIDE
          Row(
            children: [
              // Timer Pill
              GestureDetector(
                onTap: () {
                  if (isOnline) {
                    // If "Resume" is needed (i.e. paused), calling toggle might not be enough if we have a specific API
                    // But for now, using the pause toggle logic
                    _toggleTimerPause();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(16), vertical: R.h(10)),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: R.w(18),
                        height: R.w(18),
                        decoration: BoxDecoration(
                          color: isOnline
                              ? (_isTimerPaused
                                  ? AppColors.warning
                                  : AppColors.primaryGreen)
                              : AppColors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isOnline
                              ? (_isTimerPaused
                                  ? RemixIcons.play_fill
                                  : RemixIcons.time_line)
                              : RemixIcons.time_fill,
                          size: R.sp(11),
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(width: R.w(6)),
                      Text(
                        _formatDutyTime(_secondsOnDuty),
                        style: TextStyle(
                          fontSize: R.sp(13),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: R.w(12)),

              // Notification
              Consumer<NotificationsViewModel>(
                builder: (context, vm, _) {
                  return Stack(
                    children: [
                      Container(
                        width: R.w(40),
                        height: R.w(40),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: const NotificationsView(),
                              withNavBar: false, // Hide bottom nav bar
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                          icon: Icon(RemixIcons.notification_4_line,
                              size: R.sp(22)),
                        ),
                      ),
                      if (vm.unreadCount > 0)
                        Positioned(
                          top: 4,
                          right: 4,
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
