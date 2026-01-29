import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/widgets/order_cancellation_dialog.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_retry_button.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsView extends StatefulWidget {
  final int orderId;
  final String? orderNumber;
  final Order? order;

  const OrderDetailsView(
      {super.key, required this.orderId, this.orderNumber, this.order});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return ChangeNotifierProvider(
      create: (_) =>
          OrderViewModel(orderId: widget.orderId, initialOrder: widget.order)
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

          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
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
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: R.sp(20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'ORDER DETAILS',
            style: TextStyle(
              fontSize: R.sp(16),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.headingText,
            ),
          ),
          if (viewModel.order != null)
            Text(
              '#${viewModel.order!.orderNumber}',
              style: TextStyle(
                fontSize: R.sp(12),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
        ],
      ),
      actions: [
        if (viewModel.order != null)
          PopupMenuButton<String>(
            icon: Icon(RemixIcons.more_2_fill,
                color: AppColors.black, size: R.sp(24)),
            onSelected: (value) {
              if (value == 'cancel') {
                _showCancellationDialog(context, viewModel);
              } else if (value == 'pending') {
                _handleMarkPending(context, viewModel);
              }
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pending',
                child: Row(
                  children: [
                    Icon(RemixIcons.time_line,
                        size: 20, color: AppColors.bodyText),
                    SizedBox(width: 8),
                    Text('Mark as Pending'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(RemixIcons.close_circle_line,
                        size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Cancel Order',
                        style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
      ],
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
            Icon(RemixIcons.error_warning_line,
                size: 48, color: AppColors.error),
            SizedBox(height: 16),
            Text(viewModel.error!, style: TextStyle(color: AppColors.bodyText)),
            SizedBox(height: 16),
            CustomRetryButton(
              onTap: () => viewModel.fetchOrderDetails(),
              isLoading: viewModel.isLoading,
            ),
          ],
        ),
      );
    }

    final order = viewModel.order!;

    return RefreshIndicator(
      onRefresh: viewModel.fetchOrderDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(R.w(16), R.h(16), R.w(16), R.h(100)),
        child: Column(
          children: [
            _buildStatusCard(order),
            SizedBox(height: R.h(16)),
            if (order.vendor != null) _buildPickupSection(order),
            if (order.vendor != null) SizedBox(height: R.h(16)),
            if (order.deliveryAddress != null || order.user != null)
              _buildDeliverySection(order),
            if (order.deliveryAddress != null || order.user != null)
              SizedBox(height: R.h(16)),

            // Interactive Sections based on state
            if (viewModel.isPickupMode) ...[
              _buildTasksSection(viewModel),
            ] else ...[
              _buildOrderItemsList(viewModel),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Order order) {
    Color statusColor;
    String statusText = order.status.toUpperCase();
    IconData statusIcon;

    switch (order.status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        statusColor = AppColors.primaryGreen;
        statusIcon = RemixIcons.check_double_line;
        break;
      case 'cancelled':
      case 'rejected':
        statusColor = AppColors.error;
        statusIcon = RemixIcons.close_circle_line;
        break;
      case 'in_progress':
      case 'accepted':
      case 'checked_in':
        statusColor = Colors.blue;
        statusIcon = RemixIcons.truck_line;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = RemixIcons.time_line;
        break;
      default:
        statusColor = AppColors.grey;
        statusIcon = RemixIcons.information_line;
    }

    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
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
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: R.sp(24)),
          ),
          SizedBox(width: R.w(16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status',
                style: TextStyle(
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w600,
                  color: AppColors.bodyText.withValues(alpha: 0.6),
                ),
              ),
              Text(
                statusText.replaceAll('_', ' '),
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupSection(Order order) {
    return _buildSectionCard(
      title: 'PICKUP FROM',
      icon: RemixIcons.store_2_fill,
      iconColor: AppColors.primaryGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.vendor?.storeName ?? 'Unknown Store',
            style: TextStyle(
              fontSize: R.sp(18),
              fontWeight: FontWeight.bold,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: R.h(8)),
          Text(
            order.vendor?.address ?? 'No Address',
            style: TextStyle(
              fontSize: R.sp(14),
              color: AppColors.bodyText,
              height: 1.4,
            ),
          ),
          SizedBox(height: R.h(12)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _makePhoneCall(order.vendor?.mobile ?? ''),
              icon: Icon(RemixIcons.phone_fill, size: R.sp(18)),
              label: Text('Call Store'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: BorderSide(color: AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDeliverySection(Order order) {
    String fullAddress = '';
    if (order.deliveryAddress != null) {
      final addr = order.deliveryAddress!;
      fullAddress =
          '${addr.addressLine1}, ${addr.addressLine2 ?? ''}, ${addr.city}, ${addr.postcode}';
    }

    return _buildSectionCard(
      title: 'DELIVER TO',
      icon: RemixIcons.map_pin_user_fill,
      iconColor: Colors.blueAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.user?.fullName ?? order.user?.firstName ?? 'Customer',
            style: TextStyle(
              fontSize: R.sp(18),
              fontWeight: FontWeight.bold,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: R.h(8)),
          Text(
            fullAddress.isNotEmpty ? fullAddress : 'No Delivery Address',
            style: TextStyle(
              fontSize: R.sp(14),
              color: AppColors.bodyText,
              height: 1.4,
            ),
          ),
          SizedBox(height: R.h(12)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _makePhoneCall(order.user?.mobile ?? ''),
              icon: Icon(RemixIcons.phone_fill, size: R.sp(18)),
              label: Text('Call Customer'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                side: BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required Color iconColor,
      required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: R.sp(18), color: iconColor),
              SizedBox(width: R.w(8)),
              Text(
                title,
                style: TextStyle(
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          child,
        ],
      ),
    );
  }

  Widget _buildTasksSection(OrderViewModel viewModel) {
    final order = viewModel.order!;
    if (order.status == 'checked_in' ||
        order.status == 'in_progress' ||
        order.status == 'accepted') {
      return Column(
        children: [
          _buildItemsChecklist(viewModel),
          SizedBox(height: R.h(16)),
          // Proof upload logic reused visually
          _buildProofUpload(viewModel),
        ],
      );
    }
    return _buildItemsList(order.orderItems);
  }

  Widget _buildItemsList(List<OrderItem>? items) {
    if (items == null || items.isEmpty) return SizedBox();

    return _buildSectionCard(
      title: 'ITEMS',
      icon: RemixIcons.shopping_bag_3_fill,
      iconColor: AppColors.headingText,
      child: Column(
        children: items
            .map((item) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Text('${item.quantity}x',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: R.sp(14))),
                    SizedBox(width: 12),
                    Expanded(
                        child: Text(item.product?.name ?? 'Item',
                            style: TextStyle(fontSize: R.sp(14)))),
                    // Checkbox visual (checked if delivered?) - simplified for now
                  ]),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildItemsChecklist(OrderViewModel viewModel) {
    if (viewModel.orderItems.isEmpty) return SizedBox();
    return _buildSectionCard(
      title: 'VERIFY ITEMS',
      icon: RemixIcons.checkbox_circle_line,
      iconColor: AppColors.primaryGreen,
      child: Column(
        children: viewModel.orderItems.map((item) {
          final isChecked = viewModel.checkedItems.contains(item.id);
          return CheckboxListTile(
            value: isChecked,
            activeColor: AppColors.primaryGreen,
            contentPadding: EdgeInsets.zero,
            title: Text(item.product?.name ?? 'Unknown Item',
                style: TextStyle(fontSize: R.sp(14))),
            subtitle: Text('Qty: ${item.quantity}',
                style: TextStyle(fontSize: R.sp(12))),
            onChanged: (val) => viewModel.toggleItem(item.id),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProofUpload(OrderViewModel viewModel) {
    return _buildSectionCard(
      title: 'PICKUP PROOF',
      icon: RemixIcons.camera_line,
      iconColor: AppColors.primaryGreen,
      child: InkWell(
        onTap: () => viewModel.pickProofImage(ImageSource.camera),
        child: Container(
          height: R.h(200),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.softGreyBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.borderLight,
                style: BorderStyle.solid,
                width: 2), // Default solid border
          ),
          alignment: Alignment.center,
          child: viewModel.pickupProofImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(viewModel.pickupProofImage!,
                      fit: BoxFit.cover, width: double.infinity),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(RemixIcons.camera_line,
                        size: 32, color: AppColors.grey400),
                    SizedBox(height: 8),
                    Text('Tap to take pickup photo',
                        style: TextStyle(color: AppColors.grey500)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildOrderItemsList(OrderViewModel viewModel) {
    return _buildItemsList(viewModel.order?.orderItems);
  }

  Widget? _buildBottomAction(BuildContext context, OrderViewModel viewModel) {
    if (viewModel.order == null) return null;
    final order = viewModel.order!;

    // Determine action based on status
    VoidCallback? action;
    String label = '';
    bool isLoading = false;
    bool isEnabled = true;

    if (order.status.toLowerCase() == 'pending') {
      label = 'Accept Order';
      action = () => _handleAccept(context, viewModel);
      isLoading = viewModel.isAcceptLoading;
    } else if (order.status.toLowerCase() == 'accepted') {
      label = 'Start Trip';
      action = () => _handleStartTrip(context, viewModel);
      isLoading = viewModel.isStartLoading;
    } else if (viewModel.isPickupMode) {
      label = 'Confirm Pickup';
      isEnabled =
          viewModel.checkedItems.length == viewModel.orderItems.length &&
              viewModel.pickupProofImage != null;
      action =
          isEnabled ? () => _handleConfirmPickup(context, viewModel) : null;
      isLoading = viewModel.isPickupLoading;
    } else {
      // Delivery Actions?
      return null;
    }

    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: (isLoading || !isEnabled) ? null : action,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            padding: EdgeInsets.symmetric(vertical: R.h(16)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: AppColors.grey300,
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
        ),
      ),
    );
  }

  void _handleAccept(BuildContext context, OrderViewModel viewModel) async {
    final success = await viewModel.acceptOrder();
    if (success && context.mounted) {
      CustomSnackBar.showSuccess(context, "Order Accepted");
    }
  }

  void _handleStartTrip(BuildContext context, OrderViewModel viewModel) async {
    final success = await viewModel.startOrder();
    if (success && context.mounted) {
      CustomSnackBar.showSuccess(context, "Trip Started");
    }
  }

  void _handleConfirmPickup(
      BuildContext context, OrderViewModel viewModel) async {
    final success = await viewModel.pickupOrder();
    if (success && context.mounted) {
      CustomSnackBar.showSuccess(context, "Pickup Confirmed");
    } else if (viewModel.error != null && context.mounted) {
      CustomSnackBar.showError(context, viewModel.error!);
    }
  }

  void _showCancellationDialog(
      BuildContext context, OrderViewModel viewModel) async {
    if (viewModel.cancellationReasons.isEmpty) {
      await viewModel.fetchCancellationReasons();
    }
    if (!context.mounted) return;
    final result = await showDialog<int>(
      context: context,
      builder: (_) =>
          OrderCancellationDialog(reasons: viewModel.cancellationReasons),
    );
    if (result != null && context.mounted) {
      viewModel.cancelOrder(result);
    }
  }

  void _handleMarkPending(
      BuildContext context, OrderViewModel viewModel) async {
    final success = await viewModel.markAsPending();
    if (success && context.mounted) {
      CustomSnackBar.showSuccess(context, "Marked as pending");
    }
  }

  Widget _buildLoadingShimmer() {
    return Center(child: CircularProgressIndicator());
  }
}
