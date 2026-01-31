import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:avatar_glow/avatar_glow.dart';
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
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_network_image.dart';

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
      leading: const CustomBackButton(color: AppColors.black),
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'PICKUP TASK',
            style: TextStyle(
              fontSize: R.sp(14),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(height: 2),
          if (viewModel.order != null)
            Text(
              '#${viewModel.order!.orderNumber}',
              style: TextStyle(
                fontSize: R.sp(20),
                fontWeight: FontWeight.w900,
                color: AppColors.headingText,
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
          Expanded(
            child: Column(
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
          ),
          if (['in_progress', 'accepted', 'checked_in']
              .contains(order.status.toLowerCase()))
            AvatarGlow(
              glowColor: const Color(0xFF00E676),
              glowRadiusFactor: 0.4,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              child: Container(
                width: R.w(12),
                height: R.w(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPickupSection(Order order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(24)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INTERNAL WAREHOUSE',
                      style: TextStyle(
                        fontSize: R.sp(13),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: R.h(8)),
                    Text(
                      order.vendor?.storeName ?? 'AISLE 4, BAY B',
                      style: TextStyle(
                        fontSize: R.sp(28),
                        fontWeight: FontWeight.w900,
                        color: AppColors.headingText,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: R.w(56),
                height: R.w(56),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA), // Light Mint
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(RemixIcons.store_2_fill,
                      color: const Color(0xFF00E676), size: R.sp(28)),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(24)),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: R.h(50),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Show on Map
                    },
                    icon: Icon(RemixIcons.map_2_fill,
                        size: R.sp(20), color: Colors.black),
                    label: Text('Show on Map',
                        style: TextStyle(
                            fontSize: R.sp(15),
                            fontWeight: FontWeight.w800,
                            color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676), // Bright Green
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(100)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: SizedBox(
                  height: R.h(50),
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(order.vendor?.mobile ?? ''),
                    icon: Icon(RemixIcons.phone_fill,
                        size: R.sp(20), color: AppColors.headingText),
                    label: Text('Call Manager',
                        style: TextStyle(
                            fontSize: R.sp(15),
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingText)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F7FA), // Light Grey
                      foregroundColor: AppColors.headingText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(100)),
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

  Widget _locationActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: R.h(12)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(12)),
          border:
              Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: R.sp(16)),
            SizedBox(width: R.w(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: R.sp(13),
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.w(10)),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(RemixIcons.home_4_fill,
                    color: Colors.blue, size: R.sp(20)),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELIVER TO',
                      style: TextStyle(
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.w900,
                        color: AppColors.headingText.withValues(alpha: 0.4),
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      order.user?.fullName ?? 'Customer',
                      style: TextStyle(
                        fontSize: R.sp(18),
                        fontWeight: FontWeight.w900,
                        color: AppColors.headingText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Text(
            fullAddress.isNotEmpty ? fullAddress : 'No Delivery Address',
            style: TextStyle(
              fontSize: R.sp(15),
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText,
              height: 1.4,
            ),
          ),
          SizedBox(height: R.h(20)),
          _locationActionButton(
            icon: RemixIcons.phone_fill,
            label: 'Call Customer',
            onTap: () => _makePhoneCall(order.user?.mobile ?? ''),
          ),
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
    // if (viewModel.orderItems.isEmpty) return SizedBox(); // Keep visible even if empty maybe?

    final totalItems = viewModel.orderItems.length;
    final checkedCount = viewModel.checkedItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items to Pick',
                style: TextStyle(
                  fontSize: R.sp(18),
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingText,
                ),
              ),
              Text(
                '$checkedCount / $totalItems Done',
                style: TextStyle(
                  fontSize: R.sp(15),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: R.h(16)),
        ...viewModel.orderItems.map((item) {
          final bool isChecked = viewModel.checkedItems.contains(item.id);
          return GestureDetector(
            onTap: () => viewModel.toggleItem(item.id),
            child: Container(
              margin: EdgeInsets.only(bottom: R.h(12)),
              padding: EdgeInsets.all(R.w(12)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.circular(R.r(50)), // Rounded pill/card
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
                  // Item Image
                  Container(
                    width: R.w(60),
                    height: R.w(60),
                    decoration: BoxDecoration(
                      color: AppColors.softGreyBg,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: CustomNetworkImage(
                        imageUrl:
                            item.product?.productImageUrls.firstOrNull ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: R.w(16)),
                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product?.name ?? 'Unknown Item',
                          style: TextStyle(
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingText,
                          ),
                        ),
                        SizedBox(height: R.h(4)),
                        Row(
                          children: [
                            Text(
                              'Qty: ',
                              style: TextStyle(
                                fontSize: R.sp(15),
                                fontWeight: FontWeight.w600,
                                color:
                                    AppColors.bodyText.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: R.sp(16),
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Large Selection Circle
                  Container(
                    width: R.w(32),
                    height: R.w(32),
                    margin: EdgeInsets.only(right: R.w(8)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isChecked
                            ? Colors.transparent
                            : AppColors.grey.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      color: isChecked
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                    ),
                    child: isChecked
                        ? Icon(Icons.check, color: Colors.white, size: R.sp(20))
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProofUpload(OrderViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(4)),
          child: Text(
            'Pickup Proof',
            style: TextStyle(
              fontSize: R.sp(18),
              fontWeight: FontWeight.w800,
              color: AppColors.headingText,
            ),
          ),
        ),
        SizedBox(height: R.h(16)),
        InkWell(
          onTap: () => viewModel.pickProofImage(ImageSource.camera),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: AppColors.grey.withValues(alpha: 0.3),
              strokeWidth: 2.0,
              gap: 8.0,
              radius: 24.0,
            ),
            child: Container(
              height: R.h(200),
              width: double.infinity,
              padding: EdgeInsets.all(R.w(20)),
              child: viewModel.pickupProofImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(R.r(20)),
                      child: Image.file(viewModel.pickupProofImage!,
                          fit: BoxFit.cover, width: double.infinity),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(R.w(16)),
                          decoration: BoxDecoration(
                            color: AppColors.softGreyBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(RemixIcons.camera_3_fill,
                              color:
                                  AppColors.headingText.withValues(alpha: 0.6),
                              size: R.sp(32)),
                        ),
                        SizedBox(height: R.h(16)),
                        Text(
                          'Take Photo of Items',
                          style: TextStyle(
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingText,
                          ),
                        ),
                        SizedBox(height: R.h(6)),
                        Text(
                          'Mandatory for verification',
                          style: TextStyle(
                            fontSize: R.sp(13),
                            color: AppColors.bodyText.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
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
    } else if (order.status.toLowerCase() == 'checked_in' ||
        order.status.toLowerCase() == 'in_progress') {
      label = 'Start Navigation';
      action = () {
        Navigator.pushNamed(
          context,
          AppRoutes.customerInfo,
          arguments: order,
        );
      };
      isLoading = false;
    } else {
      // Delivery Actions?
      return null;
    }

    return Container(
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(R.r(32)),
          topRight: Radius.circular(R.r(32)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: (isLoading || !isEnabled) ? null : action,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: R.h(18)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.r(16))),
            disabledBackgroundColor: AppColors.grey300,
          ),
          child: isLoading
              ? SizedBox(
                  height: R.w(24),
                  width: R.w(24),
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 3))
              : Text(
                  label == 'Confirm Pickup'
                      ? 'Confirm & Start Delivery'
                      : label,
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
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

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.radius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final Path dashedPath = _dashPath(path, width: 10, space: gap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _dashPath(Path source, {required double width, required double space}) {
    final Path path = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        path.addPath(
          metric.extractPath(distance, distance + width),
          Offset.zero,
        );
        distance += width + space;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        gap != oldDelegate.gap ||
        radius != oldDelegate.radius;
  }
}
