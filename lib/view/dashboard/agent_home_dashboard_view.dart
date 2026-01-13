import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart'; // Added shimmer import
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
import 'package:samrudhi_delivery_agent_app/view/dashboard/available_orders_view.dart';
import 'package:samrudhi_delivery_agent_app/view/pickup/pickup_task_view.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_retry_button.dart';
import 'package:samrudhi_delivery_agent_app/view/feedback/order_rejected_feedback_view.dart';
import 'package:samrudhi_delivery_agent_app/view/notification/notifications_view.dart';

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

  // Dashboard Stats (Mock Data for now)
  // Dashboard Stats
  int _completedDeliveries = 0;
  double _loginHours = 0.0;
  final int _dailyGoal =
      12; // Keeping goal mock/static for now or fetch if available
  final int _onTimePercentage = 95; // Keeping this mock/static for now

  @override
  void initState() {
    super.initState();
    _initDashboard();
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
      _fetchStats();
    } else {
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

  Future<void> _fetchStats() async {
    try {
      final token = _authToken ?? await SharedPrefsUtil.getToken();
      if (token != null) {
        final hours = await _apiService.getLoginHours(token);
        final orders = await _apiService.getTotalOrders(token);
        if (mounted) {
          setState(() {
            _loginHours = hours;
            _completedDeliveries = orders;
          });
        }
      }
    } catch (e) {
      log('Error fetching stats: $e');
    }
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
      if (activeOrderData != null && mounted) {
        final activeOrder = Order.fromJson(activeOrderData);
        log('Found active order: ${activeOrder.id}');
        if (mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.orderDetails,
            arguments: activeOrder,
          );
        }
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

          if (_myOrders.isNotEmpty) {
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

      await _apiService.acceptOrder(token, orderId);

      if (!mounted) return;

      if (!context.mounted) return;

      _showAcceptSuccessDialog(orderToAccept);
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

      await _apiService.rejectOrder(token, orderId);

      if (!mounted) return;

      if (!context.mounted) return;

      _showRejectSuccessDialog(orderId);
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
        borderRadius:
            BorderRadius.circular(R.r(24)), // Consistent with summary cards
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Top Progress Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen
                    .withValues(alpha: 0.2), // Light green bg
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: R.w(150), // Mock progress
                  color: AppColors.primaryGreen,
                ),
              ),
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
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(8), vertical: R.h(4)),
                      decoration: BoxDecoration(
                        color: AppColors.softGreenBg,
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
                    Row(
                      children: [
                        Text(
                          'ID: #ORD-$orderId',
                          style: TextStyle(
                            color: AppColors.bodyText.withValues(alpha: 0.5),
                            fontSize: R.sp(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: R.w(12)),
                        Icon(RemixIcons.timer_2_fill,
                            size: R.sp(16), color: AppColors.warning),
                        SizedBox(width: R.w(4)),
                        Text(
                          '45s',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w800,
                            fontSize: R.sp(15),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: R.h(16)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: R.sp(28),
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingText,
                          ),
                        ),
                        Text(
                          'Estimated Earnings',
                          style: TextStyle(
                            fontSize: R.sp(13),
                            color: AppColors.bodyText.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.near_me,
                                size: R.sp(16), color: AppColors.bodyText),
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
                        SizedBox(height: R.h(2)),
                        Text(
                          'Total Distance',
                          style: TextStyle(
                            fontSize: R.sp(13),
                            color: AppColors.bodyText.withValues(alpha: 0.7),
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
                      child: ElevatedButton(
                        onPressed: () => _rejectOrder(orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.softGreyBg,
                          foregroundColor: AppColors.headingText,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: R.h(14)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(12)),
                          ),
                        ),
                        child: Text(
                          'Decline',
                          style: TextStyle(
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(16)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptOrder(orderId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: R.h(14)),
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
    // Mocking for visual match: Even ID = Pickup, Odd ID = Drop (Just for demo/match)
    // Or use real logic if available.
    bool isPickup = order.status.toLowerCase().contains('accept') ||
        order.status.toLowerCase().contains('pickup'); // Simple heuristic

    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)), // increased radius
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
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(R.r(12)),
            ),
            child: Icon(
              isPickup ? Icons.shopping_bag : Icons.home_filled, // Icon match
              color: isPickup
                  ? AppColors.primaryGreen
                  : AppColors.info, // Green vs Blue
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
                  '${order.orderItems.length} Items • Ready in 2 mins', // Mock extra details
                  style: TextStyle(
                    fontSize: R.sp(13),
                    color: AppColors.bodyText.withValues(alpha: 0.6),
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
                  : AppColors.summaryBlueBg, // Light Green vs Light Blue
              borderRadius: BorderRadius.circular(R.r(6)),
            ),
            child: Text(
              isPickup ? 'PICKUP' : 'DROP',
              style: TextStyle(
                fontSize: R.sp(11),
                fontWeight: FontWeight.w800,
                color: isPickup ? AppColors.primaryGreen : AppColors.info,
              ),
            ),
          ),
          SizedBox(width: R.w(8)),
          Icon(Icons.chevron_right,
              size: R.sp(20), color: AppColors.bodyText.withValues(alpha: 0.4)),
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
        borderRadius: BorderRadius.circular(R.r(16)),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber, // e.g. Gourmet Grocery
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w700,
                        color: AppColors.headingText,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Row(
                      children: [
                        Text(
                          '0.8 km away', // Mock
                          style: TextStyle(
                            fontSize: R.sp(13),
                            color: AppColors.bodyText.withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(width: R.w(8)),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.borderLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: R.w(8)),
                        Text(
                          '₹${order.totalAmount}',
                          style: TextStyle(
                            fontSize: R.sp(13),
                            color: AppColors.bodyText.withValues(alpha: 0.7),
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
                    borderRadius: BorderRadius.circular(R.r(8)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: R.w(20)),
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
    final String? imageUrl = order.orderItems.isNotEmpty &&
            order.orderItems.first.product != null &&
            order.orderItems.first.product!.productImages.isNotEmpty
        ? AppUrls.productImages +
            order.orderItems.first.product!.productImages.first
        : null;

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
                    horizontal: R.w(16), vertical: R.h(14)),
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
                  onPressed: () async {
                    if (order.deliveryAddress != null) {
                      final address = order.deliveryAddress!;
                      final fullAddress =
                          "${address.addressLine1}, ${address.city}, ${address.state} ${address.postcode}";
                      final Uri googleMapsUrl = Uri.parse(
                          "https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(fullAddress)}");
                      await launchUrl(googleMapsUrl,
                          mode: LaunchMode.externalApplication);
                    } else {
                      CustomSnackBar.showError(
                          context, "Delivery coordinates missing");
                    }
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
        icon: Icon(icon, size: R.sp(20), color: AppColors.primaryGreen),
        onPressed: onTap,
        padding: EdgeInsets.all(R.w(8)),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String footer,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(R.w(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: R.sp(10),
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: AppColors.primaryGreen, size: R.sp(16)),
            ],
          ),
          SizedBox(height: R.h(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: R.sp(22),
              fontWeight: FontWeight.w800,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: R.h(4)),
          Text(
            footer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: R.sp(9),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
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
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(12)), // Reduced 16->12
                child: Row(
                  children: [
                    // Online Status Toggle
                    GestureDetector(
                      onTap: () => widget.onStatusChanged(!isOnline),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: R.w(60),
                        height: R.h(32),
                        padding: EdgeInsets.symmetric(horizontal: R.w(4)),
                        decoration: BoxDecoration(
                          color: isOnline
                              ? const Color(0xFF10C971)
                              : const Color(0xFFE2E2E2),
                          borderRadius: BorderRadius.circular(R.r(30)),
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: isOnline
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: R.w(24),
                                height: R.w(24),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
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
                                        size: R.sp(16),
                                        color: const Color(0xFF10C971))
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(8)), // Reduced 12->8
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: R.sp(18),
                              fontWeight: FontWeight.w800,
                              color: AppColors.headingText,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            isOnline ? 'DUTY MODE' : 'YOU ARE OFFLINE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: R.sp(11),
                              fontWeight: FontWeight.w600,
                              color: AppColors.bodyText.withValues(alpha: 0.6),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: R.w(8)), // Kept small
                    // Timer Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(8),
                          vertical: R.h(8)), // Reduced horiz 12->8
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(R.r(20)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(RemixIcons.time_fill,
                              size: R.sp(16), color: const Color(0xFF10C971)),
                          SizedBox(width: R.w(4)), // Reduced 6->4
                          Text(
                            '04:22:15',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: R.sp(14),
                              color: AppColors.headingText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: R.w(12)),
                    // Notification Button
                    Container(
                      width: R.w(38),
                      height: R.w(38),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(RemixIcons.notification_4_line,
                            size: R.sp(24), color: AppColors.headingText),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationsView()),
                          );
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.h(24)),
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
                            ? const DashboardWaitingState()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_currentOrder != null) ...[
                                    _sectionHeader(
                                      title: 'Current Task',
                                      count: null,
                                      action: GestureDetector(
                                        onTap: widget.onViewDeliveries,
                                        child: Text(
                                          'View all',
                                          style: TextStyle(
                                            fontSize: R.sp(14),
                                            color: AppColors.primaryGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: R.h(12)),
                                    _currentTaskCard(_currentOrder!),
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
                                                : _availableOrders.isEmpty
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

                                  // Delivery Queue (Shows if more than 1 accepted order)
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

                                  // Available Orders
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _sectionHeader(
                                        title: 'Nearby Available',
                                        action: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const AvailableOrdersView(),
                                                  ),
                                                ).then((_) => _fetchOrders());
                                              },
                                              child: Text(
                                                'See all',
                                                style: TextStyle(
                                                  fontSize: R.sp(14),
                                                  color: AppColors.primaryGreen,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
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
                                                      color:
                                                          AppColors.bodyText)));
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

                        // Performance Today Row
                        SizedBox(height: R.h(24)),
                        _sectionHeader(title: 'Performance Today'),
                        SizedBox(height: R.h(12)),
                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                label: 'COMPLETED',
                                value: '$_completedDeliveries',
                                footer: _completedDeliveries >= _dailyGoal
                                    ? 'Goal Met! ✨'
                                    : '+2 vs Avg',
                                icon: RemixIcons.checkbox_circle_fill,
                              ),
                            ),
                            SizedBox(width: R.w(10)),
                            Expanded(
                              child: _statCard(
                                label: 'ON-TIME',
                                value: '$_onTimePercentage%',
                                footer: 'Elite Status',
                                icon: RemixIcons.timer_flash_fill,
                              ),
                            ),
                            SizedBox(width: R.w(10)),
                            Expanded(
                              child: _statCard(
                                label: 'HOURS',
                                value: _loginHours.toStringAsFixed(1),
                                footer: 'Active Time',
                                icon: RemixIcons.time_fill,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(20)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAcceptSuccessDialog(Order order) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AnimationDialog(
        lottieAsset: 'assets/lottie/accept_order.json',
        title: 'Order Accepted!',
        subtitle: 'Redirecting to pickup task...',
        titleColor: AppColors.primaryGreen,
      ),
    );

    if (!mounted) return;

    // Navigate to Pickup Task View
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: PickupTaskView(order: order),
      withNavBar: false, // Hide nav bar for task focus
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    ).then((_) {
      // Refresh orders when coming back
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
}

class _AnimationDialog extends StatefulWidget {
  final String lottieAsset;
  final String title;
  final String? subtitle;
  final Color titleColor;

  const _AnimationDialog({
    required this.lottieAsset,
    required this.title,
    this.subtitle,
    required this.titleColor,
  });

  @override
  State<_AnimationDialog> createState() => _AnimationDialogState();
}

class _AnimationDialogState extends State<_AnimationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isClosed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _closeDialog();
      }
    });

    // Fallback timer to ensure dialog closes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _closeDialog();
      }
    });
  }

  void _closeDialog() {
    if (_isClosed || !mounted) return;
    _isClosed = true;
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 10,
      insetPadding: EdgeInsets.symmetric(horizontal: R.w(40)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(R.r(20)),
      ),
      child: Padding(
        padding: EdgeInsets.all(R.w(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              widget.lottieAsset,
              width: R.w(150),
              height: R.w(150),
              fit: BoxFit.contain,
              repeat: false,
              controller: _controller,
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..forward();
              },
              errorBuilder: (context, error, stackTrace) {
                // Determine icon based on title color (Success is Green, Error is Red)
                final isSuccess = widget.titleColor == AppColors.primaryGreen;
                return Icon(
                  isSuccess ? Icons.check_circle : Icons.cancel,
                  color: widget.titleColor,
                  size: R.w(80),
                );
              },
            ),
            SizedBox(height: R.h(20)),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: R.sp(22),
                fontWeight: FontWeight.w700,
                color: widget.titleColor,
              ),
            ),
            if (widget.subtitle != null) ...[
              SizedBox(height: R.h(8)),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.sp(14),
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
