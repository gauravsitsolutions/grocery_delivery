import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart'; // Added shimmer import
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_toggle_button.dart';
import 'package:samrudhi_delivery_agent_app/widget/order_shimmer.dart';
import 'package:samrudhi_delivery_agent_app/widget/animated_order_card.dart';
import 'package:samrudhi_delivery_agent_app/widget/dashboard_shimmer.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/available_orders_view.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_details_view.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (mounted) {
          setState(() {
            _error = 'User not authenticated';
            _isLoading = false;
          });
        }
        return;
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

          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching orders: $e');
      if (mounted) {
        setState(() {
          // Keep existing data on error if possible, or show error
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreAvailableOrders() async {
    if (_isAvailableLoadingMore || !_hasMoreAvailable) return;

    setState(() {
      _isAvailableLoadingMore = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Accepting order...'),
            duration: Duration(seconds: 1)),
      );

      await _apiService.acceptOrder(token, orderId);

      if (!mounted) return;

      if (!context.mounted) return;

      _showAcceptSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _rejectOrder(int orderId) async {
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Rejecting order...'),
              duration: Duration(seconds: 1)),
        );
      }

      await _apiService.rejectOrder(token, orderId);

      if (!mounted) return;

      if (!context.mounted) return;

      _showRejectSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _orderCard({
    Key? key,
    required int orderId,
    required String title,
    required String price,
    required String meta,
    required String acceptText,
    String? imageUrl,
    bool showActions = true,
  }) {
    return AnimatedOrderCard(
      key: key,
      child: GestureDetector(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: OrderDetailsView(
              orderId: orderId,
              orderNumber: title,
            ),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        },
        child: Container(
          padding: EdgeInsets.all(R.w(16)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(R.r(12)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Image
                  if (imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: AppUrls.productImages + imageUrl,
                      httpHeaders: _authToken != null
                          ? {'Authorization': 'Bearer $_authToken'}
                          : null,
                      width: R.w(48),
                      height: R.w(48),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.shimmerBase,
                        highlightColor: AppColors.shimmerHighlight,
                        child: Container(
                          width: R.w(48),
                          height: R.w(48),
                          color: AppColors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: R.w(48),
                        height: R.w(48),
                        color: AppColors.borderLight,
                        child: Icon(RemixIcons.image_line, size: R.sp(24)),
                      ),
                    )
                  else
                    Container(
                      width: R.w(48),
                      height: R.w(48),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(R.r(8)),
                      ),
                      child: Icon(RemixIcons.shopping_bag_line, size: R.sp(24)),
                    ),
                  SizedBox(width: R.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'order_number_${orderId}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: R.sp(16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          meta,
                          style: TextStyle(
                            fontSize: R.sp(12),
                            color: AppColors.bodyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              if (showActions) ...[
                SizedBox(height: R.h(16)),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _rejectOrder(orderId),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: R.h(12)),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(R.r(12)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Reject',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: R.sp(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(12)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _acceptOrder(orderId),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: R.h(12)),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(R.r(12)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            acceptText,
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: R.sp(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
                  color: const Color(0xFFE8F5E9), // Light green bg
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
                      onTap: () {
                        // TODO: Implement chat
                      },
                    ),
                    SizedBox(width: R.w(8)),
                    // Phone Button
                    _iconButton(
                      icon: RemixIcons.phone_fill,
                      onTap: () {
                        // TODO: Implement call
                      },
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
                    // Start navigation logic
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(R.w(10)),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: R.sp(20), color: AppColors.headingText),
      ),
    );
  }

  Widget _sectionHeader({required String title, Widget? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: R.sp(18),
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _timerWidget() {
    // Placeholder for a timer widget
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(R.r(8)),
      ),
      child: Row(
        children: [
          Icon(RemixIcons.time_line, size: R.sp(14), color: AppColors.black),
          SizedBox(width: R.w(4)),
          Text(
            '00:59', // Example time
            style: TextStyle(
              fontSize: R.sp(12),
              fontWeight: FontWeight.w600,
              color: AppColors.black,
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
      return const DashboardShimmer();
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _fetchOrders,
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
                // Status
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: R.r(22),
                          backgroundColor: AppColors.borderLight,
                          child: Icon(Icons.person, size: R.sp(20)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: R.r(6),
                            backgroundColor: isOnline
                                ? AppColors.primaryGreen
                                : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: R.w(12)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATUS',
                          style: TextStyle(
                            fontSize: R.sp(12),
                            color: AppColors.bodyText,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              isOnline ? 'You are Online' : 'You are Offline',
                              style: TextStyle(
                                fontSize: R.sp(18),
                                fontWeight: FontWeight.w700,
                                color: isOnline
                                    ? AppColors.black
                                    : AppColors.bodyText,
                              ),
                            ),
                            SizedBox(width: R.w(6)),
                            Icon(
                              Icons.circle,
                              size: R.sp(10),
                              color: isOnline
                                  ? AppColors.primaryGreen
                                  : AppColors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    RemixIconToggle(
                      value: isOnline,
                      onChanged: widget.onStatusChanged,
                    ),
                  ],
                ),
                SizedBox(height: R.h(24)),

                // Current Task Header
                if (_currentOrder != null) ...[
                  // Current Task Header
                  _sectionHeader(
                    title: 'Current Task',
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
                Opacity(
                  opacity: isOnline ? 1 : 0.35,
                  child: AbsorbPointer(
                    absorbing: !isOnline,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          title: 'New Order Request',
                          action: _timerWidget(),
                        ),
                        SizedBox(height: R.h(12)),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
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
                                      key: const ValueKey('error'),
                                      child: Text(_error!,
                                          style: const TextStyle(
                                              color: AppColors.error)))
                                  : _availableOrders.isEmpty
                                      ? Container(
                                          key: const ValueKey('empty'),
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              vertical: R.h(20)),
                                          alignment: Alignment.center,
                                          child: const Text('No new orders',
                                              style: TextStyle(
                                                  color: AppColors.bodyText)))
                                      : _orderCard(
                                          key: const ValueKey('content'),
                                          orderId: _availableOrders.first.id,
                                          title: _availableOrders
                                              .first.orderNumber, // e.g. Costco
                                          price:
                                              '₹ ${_availableOrders.first.totalAmount}',
                                          meta:
                                              '${_availableOrders.first.orderItems.length} items', // e.g. 15 items
                                          acceptText: 'Accept',
                                          imageUrl: _availableOrders.first
                                                      .orderItems.isNotEmpty &&
                                                  _availableOrders
                                                          .first
                                                          .orderItems
                                                          .first
                                                          .product !=
                                                      null &&
                                                  _availableOrders
                                                      .first
                                                      .orderItems
                                                      .first
                                                      .product!
                                                      .productImages
                                                      .isNotEmpty
                                              ? _availableOrders
                                                  .first
                                                  .orderItems
                                                  .first
                                                  .product!
                                                  .productImages
                                                  .first
                                              : null,
                                        ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: R.h(24)),

                // Delivery Queue (Shows if more than 1 accepted order)
                if (_myOrders.length > 1) ...[
                  _sectionHeader(
                    title: 'Delivery Queue',
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
                    children: _myOrders.skip(1).take(2).map((order) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: R.h(12)),
                        child: AnimatedOrderCard(
                          key: ValueKey(order.id),
                          child: _orderCard(
                            orderId: order.id,
                            title: order.orderNumber,
                            price: '₹ ${order.totalAmount}',
                            meta: '${order.orderItems.length} items',
                            acceptText: 'Next Up',
                            showActions:
                                false, // Hide actions for queued orders
                            imageUrl: order.orderItems.isNotEmpty &&
                                    order.orderItems.first.product != null &&
                                    order.orderItems.first.product!
                                        .productImages.isNotEmpty
                                ? order.orderItems.first.product!.productImages
                                    .first
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_hasMoreMyOrders)
                    Padding(
                      padding: EdgeInsets.only(top: R.h(8)),
                      child: Center(
                        child: TextButton(
                          onPressed:
                              _isMyOrdersLoadingMore ? null : _loadMoreMyOrders,
                          child: _isMyOrdersLoadingMore
                              ? SizedBox(
                                  width: R.w(20),
                                  height: R.w(20),
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text('Load More'),
                        ),
                      ),
                    ),
                  SizedBox(height: R.h(24)),
                ],

                // Available Orders
                Opacity(
                  opacity: isOnline ? 1 : 0.35,
                  child: AbsorbPointer(
                    absorbing: !isOnline,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          title: 'Available Orders',
                          action: GestureDetector(
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
                        ),
                        SizedBox(height: R.h(12)),
                        // ... logic for available list or mock
                        Builder(builder: (context) {
                          final remainingOrders =
                              _availableOrders.skip(1).toList();
                          if (remainingOrders.isEmpty) {
                            return Container(
                                width: double.infinity,
                                padding:
                                    EdgeInsets.symmetric(vertical: R.h(20)),
                                alignment: Alignment.center,
                                child: const Text('No other available orders',
                                    style:
                                        TextStyle(color: AppColors.bodyText)));
                          }
                          return Column(
                            children: remainingOrders
                                .take(2)
                                .map((order) => AnimatedOrderCard(
                                      key: ValueKey(order.id),
                                      child: _orderCard(
                                        orderId: order.id,
                                        title: 'Safeway', // title logic?
                                        price: '₹ ${order.totalAmount}',
                                        meta:
                                            '${order.orderItems.length} items',
                                        acceptText: 'Accept Order',
                                      ),
                                    ))
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
                                        child: const CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('Load More'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: R.h(20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAcceptSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                  'assets/lottie/accept_order.json',
                  width: R.w(150),
                  height: R.w(150),
                  fit: BoxFit.contain,
                  repeat: false,
                ),
                SizedBox(height: R.h(20)),
                Text(
                  'Order Accepted!',
                  style: TextStyle(
                    fontSize: R.sp(22),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: R.h(8)),
                Text(
                  'Order moved to delivery queue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.sp(14),
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
        _fetchOrders(); // Refresh dashboard
      }
    });
  }

  void _showRejectSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                  'assets/lottie/reject_order.json',
                  width: R.w(150),
                  height: R.w(150),
                  fit: BoxFit.contain,
                  repeat: false,
                ),
                SizedBox(height: R.h(20)),
                Text(
                  'Order Rejected!',
                  style: TextStyle(
                    fontSize: R.sp(22),
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
        _fetchOrders();
      }
    });
  }
}
