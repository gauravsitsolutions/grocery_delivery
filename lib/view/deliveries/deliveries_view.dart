import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';

import 'package:samrudhi_delivery_agent_app/view_model/order_list_view_model.dart';
import 'package:samrudhi_delivery_agent_app/widget/filter_deliveries_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/widget/order_shimmer.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_details_view.dart';
import '../../utils/responsive.dart';

class DeliveriesView extends StatefulWidget {
  const DeliveriesView({super.key});

  @override
  State<DeliveriesView> createState() => _DeliveriesViewState();
}

class _DeliveriesViewState extends State<DeliveriesView> {
  String _selectedStatus = 'Pending';
  final ScrollController _scrollController = ScrollController();

  String? _authToken;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final viewModel = Provider.of<OrderListViewModel>(context, listen: false);
      if (_selectedStatus == 'Pending') {
        viewModel.loadMoreMyDeliveries();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return ChangeNotifierProvider(
      create: (_) => OrderListViewModel()..fetchMyDeliveries(refresh: true),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
          title: Text(
            'My Deliveries',
            style: TextStyle(
              color: AppColors.headingText,
              fontWeight: FontWeight.w700,
              fontSize: R.sp(18),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Consumer<OrderListViewModel>(
              builder: (context, viewModel, child) {
            // Simple local filter if needed, though typically API should filter.
            // For now, assuming API returns all relevant orders for 'my deliveries'
            // and we might filter locally for Delivered/Cancelled if they come in the same list,
            // or we need different VM methods for different statuses.
            // The original code only implemented 'Pending' -> 'getMyOrders'.
            // We will stick to that behavior.

            final orders = _selectedStatus == 'Pending'
                ? viewModel.myDeliveries
                : <Order>[];
            final isLoading = viewModel.isMyDeliveriesLoading;
            final isLoadingMore = viewModel.isMyDeliveriesLoadingMore;
            final error = viewModel.myDeliveriesError;

            return RefreshIndicator(
              onRefresh: () async {
                if (_selectedStatus == 'Pending') {
                  await viewModel.fetchMyDeliveries(refresh: true);
                }
              },
              color: AppColors.primaryGreen,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: R.w(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: R.h(16)),
                    _searchBar(context),
                    SizedBox(height: R.h(16)),
                    _filterChips(),
                    SizedBox(height: R.h(20)),

                    // SUMMARY
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Completed',
                            value: '12',
                            icon: RemixIcons.checkbox_circle_fill,
                            bg: AppColors.summaryBlueBg,
                            iconColor: AppColors.summaryBlueIcon,
                            textColor: Colors.green,
                          ),
                        ),
                        SizedBox(width: R.w(12)),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Distance',
                            value: '24km',
                            icon: RemixIcons.map_pin_fill,
                            bg: AppColors.summaryOrangeBg,
                            iconColor: AppColors.summaryOrangeIcon,
                            textColor: Colors.green,
                          ),
                        ),
                        SizedBox(width: R.w(12)),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Avg Time',
                            value: '28m',
                            icon: RemixIcons.timer_fill,
                            bg: AppColors.summaryPurpleBg,
                            iconColor: AppColors.summaryPurpleIcon,
                            textColor: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: R.h(20)),
                    _statusSwitch(),

                    if (error != null)
                      Padding(
                        padding: EdgeInsets.all(R.h(20)),
                        child: Center(
                            child: Text(error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red))),
                      ),
                    SizedBox(height: R.h(22)),
                    if (isLoading && orders.isEmpty)
                      const ListShimmer(count: 6)
                    else if (orders.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(R.h(20)),
                        child: const Center(child: Text('No orders found')),
                      )
                    else if (_selectedStatus == 'Pending') ...[
                      if (orders.isNotEmpty) ...[
                        _sectionLabel('IN PROGRESS'),
                        SizedBox(height: R.h(10)),
                        _inProgressCard(orders.first),
                        SizedBox(height: R.h(20)),
                      ],
                      if (orders.length > 1) ...[
                        _sectionLabel('UP NEXT'),
                        SizedBox(height: R.h(10)),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              orders.length - 1 + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == orders.length - 1 && isLoadingMore) {
                              return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: OrderShimmer());
                            }
                            // Skip the first one as it is In Progress
                            final order = orders[index + 1];
                            return _upNextCard(order);
                          },
                        ),
                      ],
                    ] else ...[
                      _sectionLabel(_selectedStatus.toUpperCase()),
                      SizedBox(height: R.h(10)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == orders.length && isLoadingMore) {
                            return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: OrderShimmer());
                          }
                          final order = orders[index];
                          return _orderCard(order);
                        },
                      ),
                    ],

                    SizedBox(height: R.h(20)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ================= SEARCH =================

  Widget _searchBar(BuildContext context) {
    return Container(
      height: R.h(54),
      padding: EdgeInsets.symmetric(horizontal: R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(28)),
      ),
      child: Row(
        children: [
          Icon(RemixIcons.search_line,
              color: AppColors.bodyText, size: R.sp(20)),
          SizedBox(width: R.w(10)),
          Expanded(
            child: Text(
              'Search Order ID, name...',
              style: TextStyle(
                color: AppColors.bodyText,
                fontSize: R.sp(15),
              ),
            ),
          ),
          Container(
            width: 1,
            height: R.h(24),
            color: AppColors.divider,
          ),
          SizedBox(width: R.w(12)),
          IconButton(
            icon: Icon(
              RemixIcons.equalizer_line,
              color: AppColors.headingText,
              size: R.sp(20),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.transparent,
                builder: (_) => const FilterDeliveriesSheet(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= STATUS SWITCH =================

  Widget _statusSwitch() {
    return Container(
      padding: EdgeInsets.all(R.w(4)),
      decoration: BoxDecoration(
        color: const Color(0xffe2e8f0),
        borderRadius: BorderRadius.circular(R.r(12)),
      ),
      child: Row(
        children: [
          _statusTab('Pending',
              active: _selectedStatus == 'Pending',
              onTap: () => setState(() => _selectedStatus = 'Pending')),
          _statusTab('Delivered',
              active: _selectedStatus == 'Delivered',
              onTap: () => setState(() => _selectedStatus = 'Delivered')),
          _statusTab('Cancelled',
              active: _selectedStatus == 'Cancelled',
              onTap: () => setState(() => _selectedStatus = 'Cancelled')),
        ],
      ),
    );
  }

  Widget _statusTab(String label,
      {String? count, bool active = false, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(R.w(1)),
          padding: EdgeInsets.symmetric(vertical: R.h(10)),
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(R.r(10)),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: R.sp(14),
                  color: active ? AppColors.headingText : AppColors.bodyText,
                ),
              ),
              if (count != null) ...[
                SizedBox(width: R.w(6)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(6), vertical: R.h(2)),
                  decoration: BoxDecoration(
                    color: const Color(0xffdcfce7),
                    borderRadius: BorderRadius.circular(R.r(10)),
                  ),
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: R.sp(11),
                      color: const Color(0xff15803d),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  // ================= CARDS =================

  Widget _orderCard(Order order) {
    Color statusColor;
    switch (order.status) {
      case 'delivered':
        statusColor = AppColors.primaryGreen;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = Colors.orange;
    }

    return GestureDetector(
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
        margin: EdgeInsets.only(bottom: R.h(16)),
        padding: EdgeInsets.all(R.w(15)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(R.r(22)),
                    bottomLeft: Radius.circular(R.r(22)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: R.w(12)),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: R.r(24),
                        backgroundColor: statusColor.withOpacity(0.1),
                        child: Icon(
                          RemixIcons.truck_line,
                          color: statusColor,
                          size: R.sp(22),
                        ),
                      ),
                      SizedBox(width: R.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'order_number_${order.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  order.orderNumber,
                                  style: TextStyle(
                                    fontSize: R.sp(18),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              order.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: R.sp(12),
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: R.w(16),
                          vertical: R.h(8),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xfff8fafc),
                          borderRadius: BorderRadius.circular(R.r(20)),
                          border: Border.all(color: const Color(0xfff1f5f9)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                fontSize: R.sp(13),
                                fontWeight: FontWeight.w600,
                                color: AppColors.headingText,
                              ),
                            ),
                            SizedBox(width: R.w(4)),
                            Icon(Icons.chevron_right,
                                size: R.sp(14), color: AppColors.bodyText),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: R.h(16)),
                  Container(
                    padding: EdgeInsets.all(R.w(12)),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xfff1f5f9),
                      borderRadius: BorderRadius.circular(R.r(10)),
                    ),
                    child: Row(
                      children: [
                        Icon(RemixIcons.map_pin_line,
                            size: R.sp(16), color: AppColors.bodyText),
                        SizedBox(width: R.w(8)),
                        Expanded(
                          child: Text(
                            order.deliveryAddress?.addressLine1 ?? 'No Address',
                            style: TextStyle(
                              fontSize: R.sp(13),
                              color: AppColors.bodyText,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₹ ${order.totalAmount}',
                          style: TextStyle(
                              fontSize: R.sp(14), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inProgressCard(Order order) {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(R.r(22)),
                  bottomLeft: Radius.circular(R.r(22)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: R.w(12)),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: R.r(24),
                      backgroundColor: AppColors.primaryGreen,
                      child: Icon(
                        RemixIcons.truck_line,
                        color: AppColors.white,
                        size: R.sp(22),
                      ),
                    ),
                    SizedBox(width: R.w(12)),
                    Expanded(
                      child: Hero(
                        tag: 'order_number_${order.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            order.orderNumber,
                            style: TextStyle(
                              fontSize: R.sp(22),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.w(16),
                        vertical: R.h(8),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfff8fafc),
                        borderRadius: BorderRadius.circular(R.r(20)),
                        border: Border.all(color: const Color(0xfff1f5f9)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Active',
                            style: TextStyle(
                              fontSize: R.sp(13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.headingText,
                            ),
                          ),
                          SizedBox(width: R.w(4)),
                          Icon(RemixIcons.pulse_line,
                              size: R.sp(14), color: AppColors.primaryGreen),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: R.h(16)),
                Container(
                  padding: EdgeInsets.all(R.w(12)),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xfff1f5f9),
                    borderRadius: BorderRadius.circular(R.r(10)),
                  ),
                  child: Row(
                    children: [
                      Icon(RemixIcons.map_pin_line,
                          size: R.sp(16), color: AppColors.bodyText),
                      SizedBox(width: R.w(8)),
                      Expanded(
                        child: Text(
                          order.deliveryAddress?.addressLine1 ?? 'No Address',
                          style: TextStyle(
                            fontSize: R.sp(13),
                            color: AppColors.bodyText,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹ ${order.totalAmount}',
                        style: TextStyle(
                            fontSize: R.sp(14), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.h(16)),
                Container(
                  padding: EdgeInsets.all(R.w(12)),
                  decoration: BoxDecoration(
                    color: const Color(0xffdcfce7),
                    borderRadius: BorderRadius.circular(R.r(12)),
                  ),
                  child: Row(
                    children: [
                      Icon(RemixIcons.time_line,
                          color: const Color(0xff15803d), size: R.sp(16)),
                      SizedBox(width: R.w(6)),
                      Text(
                        'Expected Delivery by 4:30 PM',
                        style: TextStyle(
                          fontSize: R.sp(13),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff15803d),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _upNextCard(Order order) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(16)),
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(22)),
      ),
      child: Row(
        children: [
          Container(
            height: R.w(48),
            width: R.w(48),
            decoration: BoxDecoration(
              color: const Color(0xfffff7ed),
              borderRadius: BorderRadius.circular(R.r(12)),
            ),
            child: order.orderItems.isNotEmpty &&
                    order.orderItems.first.product?.productImages.isNotEmpty ==
                        true
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    child: CachedNetworkImage(
                      imageUrl: AppUrls.productImages +
                          order.orderItems.first.product!.productImages.first,
                      httpHeaders: _authToken != null
                          ? {'Authorization': 'Bearer $_authToken'}
                          : null,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                  )
                : Icon(
                    RemixIcons.store_2_fill,
                    color: const Color(0xffea580c),
                    size: R.sp(24),
                  ),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'order_number_${order.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          order.orderNumber,
                          style: TextStyle(
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(6)),
                    Container(
                      height: 4,
                      width: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.bodyText,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: R.w(6)),
                    Text(
                      '1.1km away', // Placeholder distance
                      style: TextStyle(
                        fontSize: R.sp(12),
                        color: const Color(0xff16a34a),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.h(4)),
                Text(
                  'Drop off by 3:30 PM', // Placeholder logic
                  style: TextStyle(
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.headingText,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  '${order.orderItems.isNotEmpty ? order.orderItems.first.product?.name ?? "Store" : "Store"} • ${order.orderItems.length} items',
                  style: TextStyle(
                    fontSize: R.sp(13),
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: R.sp(20), color: AppColors.bodyText),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.bodyText,
          fontSize: R.sp(13),
        ),
      );
  Widget _filterChips() {
    final filters = [
      {'label': 'All', 'active': true},
      {'label': 'Date', 'icon': RemixIcons.calendar_event_line},
      {'label': 'Type', 'icon': RemixIcons.shopping_bag_3_line},
      {'label': 'COD', 'icon': RemixIcons.money_dollar_circle_line},
      {'label': 'Status', 'icon': RemixIcons.filter_3_line},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isActive = f['active'] == true;
          return Container(
            margin: EdgeInsets.only(right: R.w(8)),
            padding: EdgeInsets.symmetric(
              horizontal: R.w(12),
              vertical: R.h(8),
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.headingText : AppColors.white,
              borderRadius: BorderRadius.circular(R.r(20)),
              border: Border.all(
                color: isActive ? Colors.transparent : AppColors.divider,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (f['icon'] != null) ...[
                  Icon(
                    f['icon'] as IconData,
                    size: R.sp(16),
                    color: isActive ? AppColors.white : AppColors.bodyText,
                  ),
                  SizedBox(width: R.w(6)),
                ],
                Text(
                  f['label'] as String,
                  style: TextStyle(
                    color: isActive ? AppColors.white : AppColors.bodyText,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: R.sp(13),
                  ),
                ),
                if (f['icon'] != null && !isActive) ...[
                  SizedBox(width: R.w(2)),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: R.sp(14),
                    color: AppColors.bodyText,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ================= SUMMARY CARD =================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final Color textColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.bg,
    required this.iconColor,
    this.textColor = AppColors.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.w(14)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: R.w(32),
                width: R.w(32),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(R.r(8)),
                ),
                child: Icon(icon, color: iconColor, size: R.sp(16)),
              ),
              SizedBox(width: R.w(8)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xff16a34a),
                    fontSize: R.sp(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Text(
            value,
            style: TextStyle(
              fontSize: R.sp(24),
              fontWeight: FontWeight.w900,
              color: AppColors.headingText,
            ),
          ),
        ],
      ),
    );
  }
}
