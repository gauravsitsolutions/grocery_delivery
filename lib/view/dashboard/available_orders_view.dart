import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_network_image.dart';
// import 'package:lottie/lottie.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_list_view_model.dart';
import 'package:samrudhi_delivery_agent_app/widget/animated_order_card.dart';
import 'package:samrudhi_delivery_agent_app/widget/order_shimmer.dart';

class AvailableOrdersView extends StatefulWidget {
  const AvailableOrdersView({super.key});

  @override
  State<AvailableOrdersView> createState() => _AvailableOrdersViewState();
}

class _AvailableOrdersViewState extends State<AvailableOrdersView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch initial data using global provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderListViewModel>().fetchAvailableOrders(refresh: true);
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
      // Access VM via context to load more
      if (mounted) {
        context.read<OrderListViewModel>().loadMoreAvailableOrders();
      }
    }
  }

  Future<void> _acceptOrder(int orderId, List<Order> orders) async {
    if (!mounted) return;

    try {
      // Find the order object to pass its details
      final acceptedOrder = orders.firstWhere((o) => o.id == orderId);

      // Show loading
      CustomSnackBar.showSuccess(context, 'Accepting order...');

      final viewModel = context.read<OrderListViewModel>();
      final success = await viewModel.acceptOrder(orderId);

      if (success && mounted) {
        _showAcceptSuccessDialog(acceptedOrder);
      } else if (mounted) {
        CustomSnackBar.showError(context, 'Failed to accept order');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Error: ${e.toString()}');
      }
    }
  }

  void _showAcceptSuccessDialog(Order order) {
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
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primaryGreen,
                  size: R.w(100),
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
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close dialog

        // Navigate to details of the accepted order
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Available Orders',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.headingText)),
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.bodyText),
      ),
      body: SafeArea(
        child: Consumer<OrderListViewModel>(
          builder: (context, viewModel, child) {
            return RefreshIndicator(
              onRefresh: () async =>
                  await viewModel.fetchAvailableOrders(refresh: true),
              color: AppColors.primaryGreen,
              child: viewModel.isAvailableOrdersLoading
                  ? const ListShimmer(count: 6)
                  : viewModel.availableOrdersError != null
                      ? Center(
                          child: Text(viewModel.availableOrdersError!,
                              style: const TextStyle(color: Colors.red)))
                      : viewModel.availableOrders.isEmpty
                          ? const Center(child: Text('No available orders'))
                          : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(R.w(16)),
                              itemCount: viewModel.availableOrders.length +
                                  (viewModel.isAvailableOrdersLoadingMore
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index == viewModel.availableOrders.length) {
                                  return const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: OrderShimmer());
                                }
                                final order = viewModel.availableOrders[index];
                                return AnimatedOrderCard(
                                  key: ValueKey(order.id),
                                  child: _orderCard(
                                      order, viewModel.availableOrders),
                                );
                              },
                            ),
            );
          },
        ),
      ),
    );
  }

  Widget _orderCard(Order order, List<Order> orders) {
    return GestureDetector(
      onTap: () {
        // Tapping card no longer goes to details page
      },
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(16)),
        padding: EdgeInsets.all(R.w(16)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(22)),
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
                  color: AppColors.primaryGreen,
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
                  // Header
                  Row(
                    children: [
                      Container(
                        height: R.w(48),
                        width: R.w(48),
                        decoration: BoxDecoration(
                          color: const Color(0xfffff7ed),
                          borderRadius: BorderRadius.circular(R.r(12)),
                        ),
                        child: order.orderItems.isNotEmpty &&
                                order.orderItems.first.product?.productImages
                                        .isNotEmpty ==
                                    true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(R.r(12)),
                                child: CustomNetworkImage(
                                  imageUrl: AppUrls.productImages +
                                      order.orderItems.first.product!
                                          .productImages.first,
                                  fit: BoxFit.cover,
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
                            Text(
                              order.orderNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: R.sp(16),
                                fontWeight: FontWeight.w800,
                                color: AppColors.headingText,
                              ),
                            ),
                            SizedBox(height: R.h(4)),
                            Text(
                              '${order.orderItems.length} items',
                              style: TextStyle(
                                fontSize: R.sp(13),
                                color: AppColors.bodyText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹ ${order.totalAmount}',
                        style: TextStyle(
                          fontSize: R.sp(18),
                          fontWeight: FontWeight.w800,
                          color: AppColors.headingText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(16)),
                  Container(
                    padding: EdgeInsets.all(R.w(12)),
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
                      ],
                    ),
                  ),
                  SizedBox(height: R.h(16)),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _acceptOrder(order.id, orders),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: R.h(12)),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(R.r(12)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Accept Order',
                              style: TextStyle(
                                fontSize: R.sp(14),
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
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
      ),
    );
  }
}
