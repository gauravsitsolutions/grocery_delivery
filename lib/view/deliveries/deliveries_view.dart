import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_list_view_model.dart';
import 'package:samrudhi_delivery_agent_app/widget/filter_deliveries_sheet.dart';
import 'package:samrudhi_delivery_agent_app/widget/order_shimmer.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_retry_button.dart';
import 'package:samrudhi_delivery_agent_app/view/delivery_summary/delivery_completed_view.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/navigation_view.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_cancelled_details_view.dart';
import 'package:samrudhi_delivery_agent_app/view/pickup/pickup_task_view.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/widgets/new_request_card.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/responsive.dart';

// Helper for date comparison
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class DeliveriesView extends StatefulWidget {
  const DeliveriesView({super.key});

  @override
  State<DeliveriesView> createState() => _DeliveriesViewState();
}

class _DeliveriesViewState extends State<DeliveriesView> {
  String _selectedStatus = 'Pending';
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<OrderListViewModel>();
      viewModel.fetchActiveOrders(refresh: true);
      viewModel.fetchNewOrders(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToOrder(Order order) {
    // 1. If cancelled, show cancelled details
    if (order.status == 'cancelled') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: OrderCancelledDetailsView(order: order),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
      return;
    }

    // 2. If delivered/completed, show summary
    if (order.status == 'delivered' || order.status == 'completed') {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: DeliveryCompletedView(order: order),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
      return;
    }

    // 3. If it is already picked up, go to navigation/delivery view
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

    // 4. Otherwise (accepted, ready_for_pickup, queued, pending), go to pickup task
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: PickupTaskView(
        orderId: order.id,
        orderNumber: order.orderNumber,
        order: order,
      ),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final viewModel = Provider.of<OrderListViewModel>(context, listen: false);
      if (viewModel.isSearching) {
        viewModel.loadMoreSearchResults();
      } else {
        viewModel.loadMoreMyDeliveries();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
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
            final statusFilter = _selectedStatus.toLowerCase();
            final orders = viewModel.isSearching
                ? viewModel.searchResults
                : viewModel.myDeliveries.where((o) {
                    // 1. Status Filter
                    bool matchStatus = false;
                    final orderStatus = o.status.toLowerCase();
                    if (_selectedStatus == 'Pending') {
                      // Trust the API queue response for active orders
                      matchStatus = true;
                    } else if (statusFilter == 'cancelled') {
                      matchStatus = orderStatus == 'cancelled' ||
                          orderStatus == 'canceled' ||
                          orderStatus == 'rejected' ||
                          orderStatus == 'declined';
                    } else {
                      matchStatus = orderStatus == statusFilter;
                    }

                    // 2. Date Filter
                    bool matchDate = true;
                    if (viewModel.activeDateFilter == 'Today') {
                      matchDate = isSameDay(o.createdAt, DateTime.now());
                    } else if (viewModel.activeDateFilter == 'Yesterday') {
                      matchDate = isSameDay(o.createdAt,
                          DateTime.now().subtract(const Duration(days: 1)));
                    } else if (viewModel.activeDateFilter == 'Last 7 Days') {
                      final difference =
                          DateTime.now().difference(o.createdAt).inDays;
                      matchDate = difference <= 7;
                    } else if (viewModel.activeDateFilter != 'All') {
                      // Custom Date (YYYY-MM-DD)
                      final customDate =
                          DateTime.tryParse(viewModel.activeDateFilter);
                      if (customDate != null) {
                        matchDate = isSameDay(o.createdAt, customDate);
                      }
                    }

                    // 3. Type Filter (Placeholder as model lacks type)
                    bool matchType = true;
                    if (viewModel.activeTypeFilter != 'All') {
                      // Logic would go here if we had type
                      // matchType = o.type == viewModel.activeTypeFilter;
                    }

                    return matchStatus && matchDate && matchType;
                  }).toList();

            final isLoading = viewModel.isSearching
                ? viewModel.isSearchLoading
                : viewModel.isMyDeliveriesLoading;
            final isLoadingMore = viewModel.isSearching
                ? viewModel.isSearchLoadingMore
                : viewModel.isMyDeliveriesLoadingMore;
            final error = viewModel.isSearching
                ? viewModel.searchError
                : viewModel.myDeliveriesError;

            return RefreshIndicator(
              onRefresh: () async {
                if (viewModel.isSearching) {
                  await viewModel.searchDeliveries(_searchController.text,
                      refresh: true);
                } else if (_selectedStatus == 'Pending') {
                  await Future.wait([
                    viewModel.fetchActiveOrders(refresh: true),
                    viewModel.fetchNewOrders(refresh: true),
                  ]);
                } else {
                  await viewModel.fetchHistoryOrders(refresh: true);
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
                    _searchHeader(context),
                    SizedBox(height: R.h(16)),
                    if (!viewModel.isSearching) ...[
                      _filterChips(),
                      SizedBox(height: R.h(20)),

                      // SUMMARY
                      if (viewModel.deliveryStatus != null)
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                title: 'Delivered',
                                value:
                                    '${viewModel.deliveryStatus!.deliveredOrders}',
                                icon: RemixIcons.checkbox_circle_fill,
                                bg: AppColors.summaryBlueBg,
                                iconColor: AppColors.summaryBlueIcon,
                                textColor: AppColors.primaryGreen,
                              ),
                            ),
                            SizedBox(width: R.w(12)),
                            Expanded(
                              child: _SummaryCard(
                                title: 'Pending',
                                value:
                                    '${viewModel.deliveryStatus!.pendingOrders}',
                                icon: RemixIcons.time_fill,
                                bg: AppColors.summaryOrangeBg,
                                iconColor: AppColors.summaryOrangeIcon,
                                textColor: AppColors.warning,
                              ),
                            ),
                            SizedBox(width: R.w(12)),
                            Expanded(
                              child: _SummaryCard(
                                title: 'Cancelled',
                                value:
                                    '${viewModel.deliveryStatus!.cancelledOrders}',
                                icon: RemixIcons.close_circle_fill,
                                bg: AppColors.summaryPurpleBg,
                                iconColor: AppColors.summaryPurpleIcon,
                                textColor: AppColors.error,
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: R.h(20)),
                      _statusSwitch(viewModel),
                    ],
                    if (error != null)
                      Padding(
                        padding: EdgeInsets.all(R.h(20)),
                        child: Column(
                          children: [
                            Text(error,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.error)),
                            SizedBox(height: R.h(16)),
                            CustomRetryButton(
                              onTap: () {
                                if (_selectedStatus == 'Pending') {
                                  viewModel.fetchActiveOrders(refresh: true);
                                } else {
                                  viewModel.fetchHistoryOrders(refresh: true);
                                }
                              },
                              isLoading: isLoading,
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: R.h(12)),
                    if (isLoading && orders.isEmpty)
                      const ListShimmer(count: 6)
                    else if (orders.isEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                viewModel.isSearching
                                    ? RemixIcons.search_line
                                    : RemixIcons.inbox_line,
                                size: R.sp(60),
                                color: AppColors.grey.withValues(alpha: 0.3),
                              ),
                              SizedBox(height: R.h(16)),
                              Text(
                                viewModel.isSearching
                                    ? 'No results found'
                                    : 'No orders found',
                                style: TextStyle(
                                  fontSize: R.sp(16),
                                  color: AppColors.bodyText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (viewModel.isSearching) ...[
                                SizedBox(height: R.h(8)),
                                Text(
                                  'Try a different order ID or customer name',
                                  style: TextStyle(
                                    fontSize: R.sp(14),
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    else if (_selectedStatus == 'Pending' &&
                        !viewModel.isSearching) ...[
                      // 1. New Orders Section (Accept/Reject)
                      if (viewModel.newOrders.isNotEmpty) ...[
                        _sectionLabel('NEW REQUESTS'),
                        SizedBox(height: R.h(10)),
                        Column(
                          children: viewModel.newOrders.map((order) {
                            return NewRequestCard(
                              order: order,
                              countdownSeconds:
                                  60, // Default or track timer if needed
                              onAccept: () => viewModel.acceptOrder(order.id),
                              onDecline: () => viewModel.rejectOrder(order.id),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: R.h(16)),
                      ],

                      if (orders.isNotEmpty) ...[
                        _sectionLabel('IN PROGRESS'),
                        SizedBox(height: R.h(10)),
                        _inProgressCard(orders.first),
                        SizedBox(height: R.h(12)),
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
                      _sectionLabel(viewModel.isSearching
                          ? 'SEARCH RESULTS'
                          : _selectedStatus.toUpperCase()),
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
                    SizedBox(height: R.h(8)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openFilterSheet(
      BuildContext context, OrderListViewModel viewModel) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => FilterDeliveriesSheet(
        initialDate: viewModel.activeDateFilter,
        initialType: viewModel.activeTypeFilter,
        initialStatus: _selectedStatus,
      ),
    );

    if (result != null) {
      viewModel.setFilters(result['date'], result['type']);
      if (result['status'] != null) {
        String newStatus = result['status'];
        if (newStatus == 'Pending' ||
            newStatus == 'Delivered' ||
            newStatus == 'Cancelled') {
          setState(() {
            _selectedStatus = newStatus;
          });
          if (newStatus == 'Pending') {
            viewModel.fetchActiveOrders(refresh: true);
            viewModel.fetchNewOrders(refresh: true);
          } else {
            viewModel.fetchHistoryOrders(refresh: true);
          }
        }
      }
    }
  }

  // ================= SEARCH =================

  Widget _searchBar(BuildContext context) {
    final viewModel = Provider.of<OrderListViewModel>(context);
    return Container(
      height: R.h(54),
      padding: EdgeInsets.symmetric(horizontal: R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(RemixIcons.search_2_line,
              color: AppColors.grey.withValues(alpha: 0.6), size: R.sp(22)),
          SizedBox(width: R.w(12)),
          Expanded(
            child: TextField(
              controller: _searchController,
              cursorColor: AppColors.primaryGreen,
              style: TextStyle(
                fontSize: R.sp(15),
                color: AppColors.headingText,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search Order ID, Name',
                hintStyle: TextStyle(
                  fontSize: R.sp(15),
                  color: AppColors.grey.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: R.h(12)),
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (value.isNotEmpty) {
                    viewModel.searchDeliveries(value);
                  } else {
                    viewModel.clearSearch();
                  }
                });
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  viewModel.searchDeliveries(value);
                } else {
                  viewModel.clearSearch();
                }
              },
            ),
          ),
          if (viewModel.isSearching && viewModel.isStatusLoading)
            SizedBox(
              width: R.w(20),
              height: R.w(20),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            )
          else if (viewModel.isSearching)
            InkWell(
              onTap: () {
                _searchController.clear();
                viewModel.clearSearch();
              },
              child: Icon(
                Icons.close,
                color: AppColors.grey,
                size: R.w(20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _searchHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _searchBar(context)),
        SizedBox(width: R.w(12)),
        Container(
          height: R.h(54),
          width: R.h(54),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(R.r(16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              RemixIcons.equalizer_line,
              color: AppColors.headingText,
              size: R.sp(20),
            ),
            onPressed: () => _openFilterSheet(context,
                Provider.of<OrderListViewModel>(context, listen: false)),
          ),
        ),
      ],
    );
  }

  // ================= STATUS SWITCH =================

  Widget _statusSwitch(OrderListViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(R.w(4)),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(R.r(12)),
      ),
      child: Row(
        children: [
          _statusTab('Pending',
              count: (viewModel.deliveryStatus?.pendingOrders ??
                      viewModel.myDeliveries.length)
                  .toString(),
              active: _selectedStatus == 'Pending', onTap: () {
            setState(() => _selectedStatus = 'Pending');
            viewModel.fetchActiveOrders(refresh: true);
          }),
          _statusTab('Delivered',
              count: viewModel.deliveryStatus?.deliveredOrders.toString(),
              active: _selectedStatus == 'Delivered', onTap: () {
            setState(() => _selectedStatus = 'Delivered');
            viewModel.fetchHistoryOrders(refresh: true);
          }),
          _statusTab('Cancelled',
              count: viewModel.deliveryStatus?.cancelledOrders.toString(),
              active: _selectedStatus == 'Cancelled', onTap: () {
            setState(() => _selectedStatus = 'Cancelled');
            viewModel.fetchHistoryOrders(refresh: true);
          }),
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
            color: active ? AppColors.white : AppColors.transparent,
            borderRadius: BorderRadius.circular(R.r(10)),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
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
                    color: AppColors.softGreenBg,
                    borderRadius: BorderRadius.circular(R.r(10)),
                  ),
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: R.sp(11),
                      color: AppColors.primaryGreen,
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
        statusColor = AppColors.warning;
    }

    return GestureDetector(
      onTap: () {
        _navigateToOrder(order);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(16)),
        padding: EdgeInsets.all(R.w(15)),
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
                        backgroundColor: statusColor.withValues(alpha: 0.1),
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
                                color: AppColors.transparent,
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
                          color: AppColors.scaffoldBg,
                          borderRadius: BorderRadius.circular(R.r(20)),
                          border: Border.all(color: AppColors.divider),
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
                      color: AppColors.softGreyBg,
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
            color: AppColors.black.withValues(alpha: 0.05),
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
                          color: AppColors.transparent,
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
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(R.r(20)),
                        border: Border.all(color: AppColors.divider),
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PICKUP FROM',
                              style: TextStyle(
                                  fontSize: R.sp(11),
                                  color: AppColors.bodyText,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                          SizedBox(height: R.h(4)),
                          Text(
                            order.vendor?.storeName ?? 'Unknown Store',
                            style: TextStyle(
                                fontSize: R.sp(14),
                                fontWeight: FontWeight.w700,
                                color: AppColors.headingText),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DELIVER TO',
                              style: TextStyle(
                                  fontSize: R.sp(11),
                                  color: AppColors.bodyText,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5)),
                          SizedBox(height: R.h(4)),
                          Text(
                            order.user?.fullName ?? 'Customer',
                            style: TextStyle(
                                fontSize: R.sp(14),
                                fontWeight: FontWeight.w700,
                                color: AppColors.headingText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _navigateToOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    minimumSize: Size(double.infinity, R.h(48)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                    elevation: 0,
                  ),
                  child: Text('VIEW ACTIVE TASK',
                      style: TextStyle(
                          fontSize: R.sp(14), fontWeight: FontWeight.w800)),
                ),
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
        borderRadius: BorderRadius.circular(R.r(20)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  style: TextStyle(
                    fontSize: R.sp(18),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '₹ ${order.totalAmount}',
                style:
                    TextStyle(fontSize: R.sp(16), fontWeight: FontWeight.w800),
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          Row(
            children: [
              const Icon(RemixIcons.map_pin_user_line,
                  size: 16, color: AppColors.bodyText),
              SizedBox(width: R.w(8)),
              Expanded(
                child: Text(
                  order.deliveryAddress?.addressLine1 ?? 'No Address',
                  style:
                      TextStyle(fontSize: R.sp(13), color: AppColors.bodyText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: R.w(12)),
              TextButton(
                onPressed: () => _navigateToOrder(order),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    final viewModel = Provider.of<OrderListViewModel>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _filterChip('All',
              active: viewModel.activeDateFilter == 'All' &&
                  viewModel.activeTypeFilter == 'All',
              isDark: viewModel.activeDateFilter == 'All', onTap: () {
            viewModel.clearFilters();
          }),
          SizedBox(width: R.w(8)),
          _filterChip(
            'Date',
            label: viewModel.activeDateFilter != 'All'
                ? viewModel.activeDateFilter
                : 'Date',
            active: viewModel.activeDateFilter != 'All',
            icon: RemixIcons.calendar_line,
            isDropdown: true,
            onTap: () => _openFilterSheet(context, viewModel),
          ),
          SizedBox(width: R.w(8)),
          _filterChip(
            'Type',
            label: viewModel.activeTypeFilter != 'All'
                ? viewModel.activeTypeFilter
                : 'Type',
            active: viewModel.activeTypeFilter != 'All',
            icon: RemixIcons.shopping_bag_3_line,
            isDropdown: true,
            onTap: () => _openFilterSheet(context, viewModel),
          ),
          // Removing COD/Filter icon placeholder code or keeping it but making it do something?
          // I'll keep COD as visual only for now or remove? User didn't circle it.
          // I'll keep it as is but add onTap safety
          SizedBox(width: R.w(8)),
          _filterChip(
            'COD',
            icon: RemixIcons.money_dollar_circle_line,
          ),
          SizedBox(width: R.w(8)),
          GestureDetector(
            onTap: () => _openFilterSheet(context, viewModel),
            child: Container(
              padding: EdgeInsets.all(R.w(8)),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Icon(
                RemixIcons.filter_3_line,
                size: R.sp(20),
                color: AppColors.headingText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    String text, {
    // Renamed label to text because I added named argument label
    String? label,
    bool active = false,
    bool isDark = false,
    IconData? icon,
    bool isDropdown = false,
    VoidCallback? onTap,
  }) {
    final bgColor = isDark
        ? AppColors.headingText
        : (active
            ? AppColors.primaryGreen.withValues(alpha: 0.1)
            : AppColors.white);
    final borderColor = isDark
        ? AppColors.headingText
        : (active ? AppColors.primaryGreen : AppColors.borderLight);
    final textColor = isDark
        ? AppColors.white
        : (active ? AppColors.primaryGreen : AppColors.headingText);
    final iconColor = isDark
        ? AppColors.white
        : (active ? AppColors.primaryGreen : AppColors.headingText);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(R.r(24)),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: R.sp(16), color: iconColor),
              SizedBox(width: R.w(6)),
            ],
            Text(
              label ?? text,
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (isDropdown) ...[
              SizedBox(width: R.w(4)),
              Icon(Icons.arrow_drop_down_rounded,
                  size: R.sp(20), color: iconColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: R.sp(12),
        fontWeight: FontWeight.w800,
        color: AppColors.bodyText.withValues(alpha: 0.6),
        letterSpacing: 1,
      ),
    );
  }
}

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
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.w(12)),
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
          Container(
            padding: EdgeInsets.all(R.w(8)),
            decoration: BoxDecoration(
              color: bg.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: R.sp(20)),
          ),
          SizedBox(height: R.h(12)),
          Text(
            value,
            style: TextStyle(
              fontSize: R.sp(20),
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          SizedBox(height: R.h(4)),
          Text(
            title,
            style: TextStyle(
              fontSize: R.sp(12),
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class ListShimmer extends StatelessWidget {
  final int count;
  const ListShimmer({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: R.h(16)),
            height: R.h(120),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}
