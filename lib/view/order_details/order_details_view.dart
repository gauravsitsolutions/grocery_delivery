import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_pickup_screen.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/view/pickup/pickup_task_view.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/order_cancellation_dialog.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_delivery_screen.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_delivered_details_view.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_retry_button.dart';

class OrderDetailsView extends StatelessWidget {
  final int orderId;
  final String? orderNumber;
  final Order?
      order; // Accepting dynamic to avoid cyclical dependency issues if strictly typed, though Order type is better. Using Order type since it flows down.

  const OrderDetailsView(
      {super.key, required this.orderId, this.orderNumber, this.order});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderViewModel(orderId: orderId, initialOrder: order)
        ..fetchOrderDetails(),
      child: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isUnauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await SharedPrefsUtil.clearSession();
              if (context.mounted) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              }
            });
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          // If in Delivery Mode (and order is loaded), show full-screen Delivery Screen
          log('OrderDetailsView Rebuild. Status: ${viewModel.order?.status}, IsPickup: ${viewModel.isPickupMode}');

          if (!viewModel.isPickupMode && viewModel.order != null) {
            if (viewModel.order!.status.toLowerCase() == 'delivered') {
              return OrderDeliveredDetailsView(order: viewModel.order!);
            }
            return const OrderDeliveryScreen();
          }

          // Pickup Mode: Delegate completely to PickupTaskView
          if (viewModel.isPickupMode && viewModel.order != null) {
            return PickupTaskView(order: viewModel.order!);
          }

          // Fallback / Loading State for normal view (shouldn't really happen if logic is tight)
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

  // NOTE: The _buildAppBar, _buildBody, etc. below are now only used if NOT in Pickup/Delivery specialized modes,
  // or if viewModel.order is null (loading/error).
  // Ideally, PickupTaskView handles its own AppBar and Body.

  PreferredSizeWidget? _buildAppBar(
      BuildContext context, OrderViewModel viewModel) {
    if (viewModel.order == null) {
      return AppBar(
        title: const Text("Order Details"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    }

    // Safety check just in case logic changes, but normally purely handled above for delivery
    if (!viewModel.isPickupMode) return null;

    final order = viewModel.order!;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Remix.arrow_left_line),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'cancel') {
              _showCancellationDialog(context, viewModel);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'cancel',
                child:
                    Text('Cancel Order', style: TextStyle(color: Colors.red)),
              ),
            ];
          },
        ),
      ],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Pickup",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildBody(BuildContext context, OrderViewModel viewModel) {
    if (viewModel.isLoading && viewModel.order == null) {
      return _buildLoadingShimmer();
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Error: ${viewModel.error}"),
            const SizedBox(height: 16),
            CustomRetryButton(
              onTap: () => viewModel.fetchOrderDetails(),
              isLoading: viewModel.isLoading,
            ),
          ],
        ),
      );
    }

    // Only used for Pickup mode now
    return RefreshIndicator(
      onRefresh: viewModel.fetchOrderDetails,
      child: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 16),
            OrderPickupScreen(),
            SizedBox(height: 24),
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

    // Only for pickup, delivery handles its own status
    // Pickup flow is now fully handled within OrderPickupScreen / PickupTaskView
    return null;
  }

  void _showCancellationDialog(
      BuildContext context, OrderViewModel viewModel) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const OrderCancellationDialog(),
    );

    if (result != null && context.mounted) {
      final success = await viewModel.cancelOrder(result);
      if (context.mounted) {
        if (success) {
          CustomSnackBar.showSuccess(context, 'Order cancelled successfully');
          Navigator.pop(context); // Exit Order Details screen
        } else {
          CustomSnackBar.showError(
              context, viewModel.error ?? 'Cancellation failed');
        }
      }
    }
  }
}
