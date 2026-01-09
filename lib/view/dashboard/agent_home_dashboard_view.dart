import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_toggle_button.dart';
import 'package:samrudhi_delivery_agent_app/widget/order_shimmer.dart';

class AgentDashboardView extends StatefulWidget {
  final bool isOnline;
  final ValueChanged<bool> onStatusChanged;

  const AgentDashboardView({
    super.key,
    required this.isOnline,
    required this.onStatusChanged,
  });

  @override
  State<AgentDashboardView> createState() => _AgentDashboardViewState();
}

class _AgentDashboardViewState extends State<AgentDashboardView> {
  final ApiService _apiService = ApiService();
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

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

      final response = await _apiService.getNewOrders(token);
      if (mounted) {
        setState(() {
          _orders = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order accepted successfully!')),
      );
      _fetchOrders(); // Refresh list
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order rejected successfully!')),
      );
      _fetchOrders(); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final isOnline = widget.isOnline;

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

                // Order Requests
                _sectionHeader(
                  title: 'Order Requests',
                  action: Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
                SizedBox(height: R.h(12)),

                GestureDetector(
                  onTap: () {
                    // Navigate to details if needed
                  },
                  child: Container(
                    padding: EdgeInsets.all(R.w(16)),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(R.r(22)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: R.r(20),
                              backgroundColor:
                                  AppColors.primaryGreen.withOpacity(0.1),
                              child: Icon(
                                RemixIcons.shopping_bag_3_line,
                                color: AppColors.primaryGreen,
                                size: R.sp(20),
                              ),
                            ),
                            SizedBox(width: R.w(12)),
                            const Expanded(
                              child: Text(
                                'Pending Requests',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              '${_orders.length} Orders',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: R.h(12)),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _isLoading
                              ? const OrderShimmer()
                              : _error != null
                                  ? Center(
                                      key: const ValueKey('error'),
                                      child: Text(_error!,
                                          style: const TextStyle(
                                              color: AppColors.error)))
                                  : _orders.isEmpty
                                      ? const Center(
                                          key: ValueKey('empty'),
                                          child: Text('No new orders'))
                                      : _orderCard(
                                          key: const ValueKey('content'),
                                          orderId: _orders.first.id,
                                          title: _orders.first.orderNumber,
                                          price:
                                              '₹ ${_orders.first.totalAmount}',
                                          meta:
                                              '${_orders.first.orderItems.length} items • ${_orders.first.status.toUpperCase()}',
                                          acceptText: 'Accept',
                                        ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: R.h(24)),

                // Current Task Header
                _sectionHeader(
                  title: 'Current Task',
                  action: Text(
                    'View all',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
                SizedBox(height: R.h(12)),
                _currentTaskCard(),
                SizedBox(height: R.h(24)),

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
                          action: Text(
                            'See all',
                            style: TextStyle(
                              fontSize: R.sp(14),
                              color: AppColors.bodyText,
                            ),
                          ),
                        ),
                        SizedBox(height: R.h(12)),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _isLoading
                              ? const ListShimmer(count: 2)
                              : _error != null
                                  ? const SizedBox.shrink(
                                      key: ValueKey('error'))
                                  : _orders.isEmpty
                                      ? const Center(
                                          key: ValueKey('empty'),
                                          child: Text('No available orders'))
                                      : Column(
                                          key: const ValueKey('content'),
                                          children: _orders
                                              .skip(1)
                                              .take(2)
                                              .map((order) => _orderCard(
                                                    orderId: order.id,
                                                    title: order.orderNumber,
                                                    price:
                                                        '₹ ${order.totalAmount}',
                                                    meta:
                                                        '${order.orderItems.length} items • ${order.status.toUpperCase()}',
                                                    acceptText: 'Accept Order',
                                                  ))
                                              .toList(),
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

  // Current Task Card

  Widget _currentTaskCard() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: R.w(42),
                width: R.w(42),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(R.r(10)),
                  color: AppColors.borderLight,
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Text(
                  'Whole Foods Market',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '₹ 14.50',
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          Container(
            padding: EdgeInsets.all(R.w(14)),
            decoration: BoxDecoration(
              color: AppColors.softGreenBg,
              borderRadius: BorderRadius.circular(R.r(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dropoff by 4:45 PM',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(height: R.h(4)),
                      Text(
                        '123 Maple Street (Apt 4B)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: R.sp(15),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: R.w(8)),
                CircleAvatar(
                  radius: R.r(22),
                  backgroundColor: AppColors.white,
                  child: Icon(RemixIcons.chat_3_line,
                      size: R.sp(18), color: AppColors.black),
                ),
                SizedBox(width: R.w(10)),
                CircleAvatar(
                  radius: R.r(22),
                  backgroundColor: AppColors.white,
                  child: Icon(RemixIcons.phone_line,
                      size: R.sp(18), color: AppColors.black),
                ),
              ],
            ),
          ),
          SizedBox(height: R.h(16)),
          SizedBox(
            width: double.infinity,
            height: R.h(48),
            child: ElevatedButton(
              onPressed: widget.isOnline ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isOnline
                    ? AppColors.primaryGreen
                    : AppColors.borderLight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Navigate to Dropoff',
                    style: TextStyle(
                      fontSize: R.sp(15),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(width: R.w(8)),
                  Icon(
                    Icons.navigation,
                    size: R.sp(18),
                    color: AppColors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({required String title, required Widget action}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: R.sp(20),
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        action,
      ],
    );
  }

  // Order Card

  Widget _orderCard({
    Key? key,
    required int orderId,
    required String title,
    required String price,
    required String meta,
    required String acceptText,
  }) {
    return Container(
      key: key,
      margin: EdgeInsets.only(bottom: R.h(12)),
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: R.w(40),
                width: R.w(40),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(R.r(10)),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.sp(14),
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
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: R.h(45),
                  child: OutlinedButton.icon(
                    onPressed:
                        widget.isOnline ? () => _rejectOrder(orderId) : null,
                    icon: Icon(Icons.close, size: R.sp(18)),
                    label: Text(
                      'Reject',
                      style: TextStyle(
                          fontSize: R.sp(14), fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(12)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: SizedBox(
                  height: R.h(45),
                  child: ElevatedButton.icon(
                    onPressed:
                        widget.isOnline ? () => _acceptOrder(orderId) : null,
                    icon: Icon(Icons.check, size: R.sp(18)),
                    label: Text(
                      acceptText,
                      style: TextStyle(
                          fontSize: R.sp(14), fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(12)),
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
}
