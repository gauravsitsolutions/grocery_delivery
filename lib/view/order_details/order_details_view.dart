import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_pickup_screen.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_delivery_screen.dart';
import 'package:shimmer/shimmer.dart';

class OrderDetailsView extends StatelessWidget {
  final int orderId;
  final String? orderNumber;
  const OrderDetailsView({super.key, required this.orderId, this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderViewModel(orderId: orderId)..fetchOrderDetails(),
      child: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: _buildAppBar(context, viewModel),
            body: _buildBody(context, viewModel),
            bottomNavigationBar: _buildBottomAction(context, viewModel),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, OrderViewModel viewModel) {
    if (viewModel.isLoading || viewModel.order == null) {
      return AppBar(
        title: const Text("Order Details"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    }

    final order = viewModel.order!;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Remix.arrow_left_line),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            viewModel.isPickupMode ? "Order Pickup" : "Order Delivery",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            "INTERNAL ORDER #${order.orderNumber}",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Remix.more_2_fill, size: 20),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, OrderViewModel viewModel) {
    if (viewModel.isLoading) {
      return _buildLoadingShimmer();
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Error: ${viewModel.error}"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchOrderDetails(),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.fetchOrderDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            if (viewModel.isPickupMode)
              const OrderPickupScreen()
            else
              const OrderDeliveryScreen(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 150,
                height: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildBottomAction(BuildContext context, OrderViewModel viewModel) {
    if (viewModel.isLoading || viewModel.order == null) return null;

    return viewModel.isPickupMode
        ? _buildPickupFooter(context, viewModel)
        : _buildDeliveryFooter(context, viewModel);
  }

  Widget _buildPickupFooter(BuildContext context, OrderViewModel viewModel) {
    final allChecked =
        viewModel.checkedItems.length == viewModel.orderItems.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSupportLink(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                if (!allChecked) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Please verify all items before confirming"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                final success = await viewModel.pickupOrder();
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Order picked up successfully!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    allChecked ? AppColors.primaryGreen : Colors.grey[400],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (allChecked) const Icon(Remix.check_double_line, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Confirm Pickup",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryFooter(BuildContext context, OrderViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSupportLink(),
          const SizedBox(height: 12),
          Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    "SLIDE TO COMPLETE",
                    style: TextStyle(
                      color: Color(0xFF495057),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Positioned(
                  left: viewModel.swipePosition,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (!viewModel.hasReadInstructions) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please read and confirm instructions first"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }
                      double newPos =
                          viewModel.swipePosition + details.delta.dx;
                      if (newPos < 0) newPos = 0;
                      if (newPos >
                          MediaQuery.of(context).size.width - 16 - 16 - 54) {
                        newPos =
                            MediaQuery.of(context).size.width - 16 - 16 - 54;
                      }
                      viewModel.swipePosition = newPos;
                    },
                    onHorizontalDragEnd: (details) async {
                      if (viewModel.swipePosition >
                          MediaQuery.of(context).size.width * 0.6) {
                        viewModel.swipePosition =
                            MediaQuery.of(context).size.width - 16 - 16 - 54;
                        // Handle completion logic here if needed
                      } else {
                        viewModel.swipePosition = 0;
                      }
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0052CC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Remix.arrow_right_s_line,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Remix.customer_service_2_line, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          "Contact Internal Support",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}
