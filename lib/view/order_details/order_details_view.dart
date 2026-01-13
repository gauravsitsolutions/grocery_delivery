import 'package:image_picker/image_picker.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_pickup_screen.dart';
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
    return viewModel.isPickupMode
        ? _buildPickupFooter(context, viewModel)
        : null;
  }

  Widget _buildPickupFooter(BuildContext context, OrderViewModel viewModel) {
    final allChecked =
        viewModel.checkedItems.length == viewModel.orderItems.length;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
            _buildProofSection(context, viewModel),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: viewModel.isPickupLoading
                    ? null
                    : () async {
                        if (!allChecked) {
                          CustomSnackBar.showError(
                            context,
                            "Please verify all items before confirming",
                          );
                          return;
                        }
                        if (viewModel.pickupProofImage == null) {
                          CustomSnackBar.showError(
                            context,
                            "Please upload pickup proof image",
                          );
                          return;
                        }
                        final success = await viewModel.pickupOrder();
                        if (!context.mounted) return;
                        if (success) {
                          CustomSnackBar.showSuccess(
                            context,
                            "Order picked up successfully!",
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: allChecked && !viewModel.isPickupLoading
                      ? AppColors.primaryGreen
                      : Colors.grey[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: viewModel.isPickupLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (allChecked)
                            const Icon(Remix.check_double_line, size: 20),
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

  Widget _buildProofSection(BuildContext context, OrderViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pickup Proof",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => viewModel.pickProofImage(ImageSource.camera),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.none,
              ),
            ),
            child: viewModel.pickupProofImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      viewModel.pickupProofImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Remix.camera_line,
                          size: 32, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        "Tap to take photo",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _showCancellationDialog(BuildContext context, OrderViewModel viewModel) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Order'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter cancellation reason',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  CustomSnackBar.showError(context, 'Reason is required');
                  return;
                }
                Navigator.pop(context); // Close dialog

                final success = await viewModel.cancelOrder(reason);
                if (context.mounted) {
                  if (success) {
                    CustomSnackBar.showSuccess(
                        context, 'Order cancelled successfully');
                    Navigator.pop(context); // Exit Order Details screen
                  } else {
                    CustomSnackBar.showError(
                        context, viewModel.error ?? 'Cancellation failed');
                  }
                }
              },
              child: const Text('Confirm Cancel',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
