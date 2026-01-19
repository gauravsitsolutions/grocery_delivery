import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/view/notification/notifications_view.dart';

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/view_model/notifications_view_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/services/app_exceptions.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
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
import 'package:samrudhi_delivery_agent_app/view/pickup/pickup_task_view.dart';

class AgentDashboardView extends StatefulWidget {
  final bool isOnline;
  final ValueChanged<bool> onStatusChanged;
  final VoidCallback? onViewDeliveries;

  const AgentDashboardView({
    super.key,
    required this.isOnline,
    required this.onStatusChanged,
    this.onViewDeliveries,
  });

  @override
  State<AgentDashboardView> createState() => _AgentDashboardViewState();
}

class _AgentDashboardViewState extends State<AgentDashboardView> {
  final ApiService _apiService = ApiService();
  List<Order> _availableOrders = [];
  List<Order> _myOrders = []; // Full list of accepted orders
  Order? _currentOrder; // The first one in the queue
  bool _isLoading = true;

  String? _error;

  // Timer State
  Timer? _dutyTimer;
  int _secondsOnDuty = 0;
  bool _isTimerPaused = false;

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
  final int _dailyGoal = 15; // Hardcoded goal for now

  @override
  void initState() {
    super.initState();
    _initDashboard();
    // Initialize timer state based on initial props
    if (widget.isOnline) {
      _startTimer();
    }
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
      }
    }
  }

  @override
  void dispose() {
    _dutyTimer?.cancel();
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

  void _toggleTimerPause() {
    setState(() {
      _isTimerPaused = !_isTimerPaused;
    });
  }

  Future<void> _initDashboard() async {
    final token = await SharedPrefsUtil.getToken();
    if (token != null) {
      if (mounted) {
        setState(() {
          _authToken = token;
        });
      }
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
      log('Error fetching profile: $e');
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
            // Sync local timer with server time if not already wildly different?
            // Or just trust server time is the baseline for "today"
            // Only update if we are not currently ticking to avoid jumpiness, or always update?
            // best to update baseline.
            _secondsOnDuty = summary.todayDutyTime ?? 0;
          });
        }
      }
    } catch (e) {
      log('Error fetching partner summary: $e');
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

      // Fetch new orders
      final availableResponse = await _apiService.getNewOrders(token, page: 1);

      // Fetch my orders (queue)
      final myOrdersResponse = await _apiService.getMyOrders(token, page: 1);

      if (mounted) {
        setState(() {
          _authToken = token;
          log('Auth Token Set: ${_authToken?.substring(0, 10)}...'); // Debug log
          _availableOrders = availableResponse.data;
          _myOrders = myOrdersResponse.data;

          _availablePage = 1;
          _myOrdersPage = 1;
          _hasMoreAvailable = (availableResponse.currentPage ?? 1) <
              (availableResponse.lastPage ?? 1);
          _hasMoreMyOrders = (myOrdersResponse.currentPage ?? 1) <
              (myOrdersResponse.lastPage ?? 1);

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
      log('Error fetching orders: $e');
      if (mounted) {
        if (e is UnauthorisedException) {
          await SharedPrefsUtil.clearSession();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (route) => false);
          }
        } else {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
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
      log('Error fetching delivery stats: $e');
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
      final response = await _apiService.getNewOrders(token, page: nextPage);

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
      log('Error loading more available orders: $e');
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
      log('Error loading more my orders: $e');
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
      final orderToAccept = _availableOrders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => Order(
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
        ),
      );

      final response = await _apiService.acceptOrder(token, orderId);

      if (!mounted) return;

      if (response['status'] == true || response['status'] == 'success') {
        if (!context.mounted) return;
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

    setState(() {
      _removingOrderIds.add(orderId);
    });

    try {
      final token = _authToken ?? await SharedPrefsUtil.getToken();

      if (token == null) return;

      // Show loading
      if (mounted) {
        CustomSnackBar.showError(context, 'Rejecting order...');
      }

      final response = await _apiService.rejectOrder(token, orderId);

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
        CustomSnackBar.showError(context, 'Error: ${e.toString()}');
        setState(() {
          _removingOrderIds.remove(orderId);
        });
      }
    }
  }

  Widget _newRequestCard({
    required int orderId, // Changed to int
    required String title,
    required String price,
    required String meta,
    required String acceptText,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: R.w(4)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
        border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.3),
            width: 1.5), // Subtle green border
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top Accent Line
          Positioned(
            top: 0,
            left: 20,
            right: 150, // Partial width
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(4))),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(R.w(20), R.h(24), R.w(20), R.h(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: R.w(8), vertical: R.h(4)),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(R.r(4)),
                          ),
                          child: Text(
                            'NEW REQUEST',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: R.sp(12),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(width: R.w(10)),
                        Text(
                          'ID: #ORD-$orderId',
                          style: TextStyle(
                            color: AppColors.bodyText.withOpacity(0.5),
                            fontSize: R.sp(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(RemixIcons.timer_line,
                            size: R.sp(16), color: AppColors.warning),
                        SizedBox(width: R.w(4)),
                        Text('45s',
                            style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w800,
                                fontSize: R.sp(14)))
                      ],
                    )
                  ],
                ),
                SizedBox(height: R.h(8)),
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // Align text bottom
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: R.sp(32),
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingText,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: R.h(4)),
                        Text(
                          'Estimated Earnings',
                          style: TextStyle(
                            fontSize: R.sp(13),
                            color: AppColors.bodyText.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(RemixIcons.navigation_fill,
                                size: R.sp(16), color: AppColors.headingText),
                            SizedBox(width: R.w(4)),
                            Text(
                              '3.2 km', // Mock distance
                              style: TextStyle(
                                fontSize: R.sp(18),
                                fontWeight: FontWeight.w700,
                                color: AppColors.headingText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: R.h(4)),
                        Text(
                          'Total Distance',
                          style: TextStyle(
                            fontSize: R.sp(13),
                            color: AppColors.bodyText.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: R.h(24)),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: R.h(50),
                        child: ElevatedButton(
                          onPressed: () => _rejectOrder(orderId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.softGreyBg,
                            foregroundColor: AppColors.headingText,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(R.r(12)),
                            ),
                          ),
                          child: Text(
                            'Decline',
                            style: TextStyle(
                                fontSize: R.sp(16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.bodyText.withOpacity(0.8)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(16)),
                    Expanded(
                      child: SizedBox(
                        height: R.h(50),
                        child: ElevatedButton(
                          onPressed: () => _acceptOrder(orderId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(R.r(12)),
                            ),
                          ),
                          child: Text(
                            'Accept Order',
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
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(6)),
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.1), // #F2F4F7 ideally
        borderRadius: BorderRadius.circular(R.r(6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: R.sp(12),
          color: AppColors.bodyText.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _myQueueItem(Order order) {
    // Logic for icon/badge
    // Ideally use order.status or order.type.
    // Mocking for visual match.
    // We can assume first item is 'Pickup' and second is 'Drop' for visual demo as user requested "make like this"
    // Using even/odd id or just forcing it for now.
    bool isPickup = order.id % 2 != 0;

    // In real app, check order status e.g.
    // isPickup = order.status == 'accepted' || order.status == 'arrived_at_pickup';

    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
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
            padding: EdgeInsets.all(R.w(10)),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(R.r(12)),
            ),
            child: Icon(
              isPickup
                  ? RemixIcons.shopping_bag_3_fill
                  : RemixIcons.home_smile_fill,
              color: isPickup
                  ? AppColors.primaryGreen
                  : AppColors.info, // Blue for Drop
              size: R.sp(24),
            ),
          ),
          SizedBox(width: R.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber, // e.g. "Fresh Mart - Sector 45"
                  style: TextStyle(
                    fontSize: R.sp(15),
                    fontWeight: FontWeight.w700,
                    color: AppColors.headingText,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  '${order.orderItems.length} Items • Ready in 2 mins',
                  style: TextStyle(
                    fontSize: R.sp(13),
                    color: AppColors.bodyText.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // BADGE
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(4)),
            decoration: BoxDecoration(
              color: isPickup
                  ? AppColors.softGreenBg
                  : AppColors.summaryBlueBg, // Soft Blue
              borderRadius: BorderRadius.circular(R.r(6)),
            ),
            child: Text(
              isPickup ? 'PICKUP' : 'DROP',
              style: TextStyle(
                fontSize: R.sp(11),
                fontWeight: FontWeight.w700,
                color: isPickup ? AppColors.primaryGreen : AppColors.info,
              ),
            ),
          ),
          SizedBox(width: R.w(12)),
          Icon(Icons.chevron_right,
              size: R.sp(20), color: AppColors.bodyText.withOpacity(0.4)),
        ],
      ),
    );
  }

  Widget _availableOrderItem(Order order) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(16)),
      padding: EdgeInsets.all(R.w(16)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* 
              Container(
                width: R.w(48),
                height: R.w(48),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(R.r(12)),
                ),
                child: Center(
                  child: Text(
                    order.orderNumber.isNotEmpty ? order.orderNumber[0] : 'O',
                    style: TextStyle(
                      fontSize: R.sp(20),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              */
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber, // e.g. Gourmet Grocery
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w800,
                        color: AppColors.headingText,
                      ),
                    ),
                    SizedBox(height: R.h(6)),
                    Row(
                      children: [
                        Text(
                          '0.8 km away', // Mock
                          style: TextStyle(
                            fontSize: R.sp(13),
                            color: AppColors.bodyText.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(width: R.w(8)),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.bodyText.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: R.w(8)),
                        Text(
                          '₹${order.totalAmount}',
                          style: TextStyle(
                            fontSize: R.sp(14),
                            color: AppColors.bodyText.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => _acceptOrder(order.id),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(10)),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(24), vertical: R.h(10)),
                ),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: R.sp(14),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          // TAGS
          Row(
            children: [
              _tag('Medium Task'),
              SizedBox(width: R.w(8)),
              _tag('No Cold Storage'),
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
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              httpHeaders: _authToken != null
                                  ? {'Authorization': 'Bearer $_authToken'}
                                  : null,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: AppColors.shimmerBase,
                                highlightColor: AppColors.shimmerHighlight,
                                child: Container(color: AppColors.white),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                  RemixIcons.store_2_line,
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
                              fontWeight: FontWeight.w700,
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
                      screen: PickupTaskView(order: order),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: EdgeInsets.symmetric(vertical: R.h(14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Navigate to Pickup',
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
        icon: Icon(icon, size: R.sp(20), color: AppColors.primaryGreen),
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
        child: RefreshIndicator(
          onRefresh: _initDashboard,
          color: AppColors.primaryGreen,
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
                SizedBox(height: R.h(12)),
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
                          (_availableOrders.isEmpty &&
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
                                    pendingOrders: _pendingOrders,
                                    cancelledOrders: _cancelledOrders,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Current Task (Priority)
                                    if (_currentOrder != null) ...[
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
                                            padding: EdgeInsets.only(
                                                bottom: R.h(12)),
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
                                          transitionBuilder:
                                              (child, animation) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: SlideTransition(
                                                position: Tween<Offset>(
                                                  begin:
                                                      const Offset(0.0, 0.05),
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
                                                      key: const ValueKey(
                                                          'error'),
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
                                                            isLoading:
                                                                _isLoading,
                                                          ),
                                                        ],
                                                      ))
                                                  : _availableOrders.isEmpty
                                                      ? Container(
                                                          key: const ValueKey(
                                                              'empty'),
                                                          width:
                                                              double.infinity,
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
                                                      : _newRequestCard(
                                                          orderId:
                                                              _availableOrders
                                                                  .first.id,
                                                          title: _availableOrders
                                                              .first
                                                              .orderNumber, // e.g. Costco
                                                          price:
                                                              '₹ ${_availableOrders.first.totalAmount}',
                                                          meta:
                                                              '${_availableOrders.first.orderItems.length} items', // e.g. 15 items
                                                          acceptText:
                                                              'Accept', // Ignored by newRequestCard but kept compatible
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
                                                Icon(
                                                    RemixIcons.sparkling_2_fill,
                                                    size: R.sp(14),
                                                    color:
                                                        AppColors.primaryGreen),
                                                SizedBox(width: R.w(6)),
                                                Text(
                                                  'Batch All',
                                                  style: TextStyle(
                                                    fontSize: R.sp(13),
                                                    color:
                                                        AppColors.primaryGreen,
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
                                          final remainingOrders =
                                              _availableOrders.skip(1).toList();
                                          if (remainingOrders.isEmpty) {
                                            return Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: R.h(20)),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                    'No other available orders',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .bodyText)));
                                          }
                                          return Column(
                                            children: remainingOrders
                                                .take(2)
                                                .map((order) =>
                                                    _availableOrderItem(order))
                                                .toList(),
                                          );
                                        }),
                                        if (_hasMoreAvailable)
                                          Padding(
                                            padding:
                                                EdgeInsets.only(top: R.h(8)),
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
      MaterialPageRoute(
        builder: (context) => OrderRejectedFeedbackView(orderId: orderId),
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
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w800,
                      color: AppColors.headingText,
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
                onTap: isOnline ? _toggleTimerPause : null,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsView(),
                              ),
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
