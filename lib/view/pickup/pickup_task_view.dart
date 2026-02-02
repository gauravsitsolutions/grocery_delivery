import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';

import 'package:samrudhi_delivery_agent_app/widget/custom_retry_button.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:samrudhi_delivery_agent_app/view/pickup/widgets/pickup_task_shimmer.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_network_image.dart';
import 'package:samrudhi_delivery_agent_app/view/customer_info/customer_info_view.dart';
import 'package:samrudhi_delivery_agent_app/auth/login/login_view.dart';
import 'dart:ui';

class PickupTaskView extends StatefulWidget {
  final int orderId;
  final String? orderNumber;
  final Order? order;

  const PickupTaskView({
    super.key,
    required this.orderId,
    this.orderNumber,
    this.order,
  });

  @override
  State<PickupTaskView> createState() => _PickupTaskViewState();
}

class _PickupTaskViewState extends State<PickupTaskView> {
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth(context);
    });
  }

  Future<void> _checkAuth(BuildContext context) async {
    final token = await SharedPrefsUtil.getToken();
    if (token == null && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
        (route) => false,
      );
    }
  }

  void _showAddressBottomSheet(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(R.w(24)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(R.r(40)),
              topRight: Radius.circular(R.r(40)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: R.w(40),
                  height: R.h(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(R.r(2)),
                  ),
                ),
              ),
              SizedBox(height: R.h(24)),
              Row(
                children: [
                  CircleAvatar(
                    radius: R.r(24),
                    backgroundColor:
                        AppColors.primaryGreen.withValues(alpha: 0.1),
                    child: Icon(RemixIcons.map_pin_2_fill,
                        color: AppColors.primaryGreen, size: R.sp(24)),
                  ),
                  SizedBox(width: R.w(16)),
                  Text(
                    "Pickup Address",
                    style: TextStyle(
                      fontSize: R.sp(20),
                      fontWeight: FontWeight.w800,
                      color: AppColors.headingText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.h(24)),
              Text(
                order.vendor?.storeName ?? "Warehouse",
                style: TextStyle(
                  fontSize: R.sp(18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingText,
                ),
              ),
              SizedBox(height: R.h(8)),
              Text(
                order.vendor?.address ?? "Address details not available",
                style: TextStyle(
                  fontSize: R.sp(16),
                  color: AppColors.bodyText,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: R.h(32)),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, R.h(54)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(27)),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Got It",
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + R.h(16)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return ChangeNotifierProvider(
      create: (context) => OrderViewModel(
        orderId: widget.orderId,
        initialOrder: widget.order,
      )..fetchOrderDetails(),
      child: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: _buildAppBar(context, viewModel),
            body: viewModel.isLoading
                ? const PickupTaskShimmer()
                : viewModel.order == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Failed to load order"),
                            SizedBox(height: R.h(20)),
                            CustomRetryButton(
                              onTap: () => viewModel.fetchOrderDetails(),
                            ),
                          ],
                        ),
                      )
                    : _buildContent(context, viewModel),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, OrderViewModel viewModel) {
    final displayOrderNumber = viewModel.order?.orderNumber ??
        widget.orderNumber ??
        widget.orderId.toString();
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: const CustomBackButton(color: Colors.black),
      centerTitle: true,
      title: Text(
        "PICKUP TASK",
        style: TextStyle(
          fontSize: R.sp(18),
          color: AppColors.headingText,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: R.w(16), top: R.h(18)),
          child: Text(
            "#$displayOrderNumber",
            style: TextStyle(
              fontSize: R.sp(16),
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, OrderViewModel viewModel) {
    final order = viewModel.order!;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(R.w(16)),
        child: Column(
          children: [
            _locationCard(order),
            SizedBox(height: R.h(24)),
            _itemsHeader(viewModel),
            SizedBox(height: R.h(16)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.orderItems.length,
              itemBuilder: (context, index) {
                final item = viewModel.orderItems[index];
                final isChecked = viewModel.checkedItems.contains(item.id);
                return _itemTile(
                  item: item,
                  isChecked: isChecked,
                  onTap: () => viewModel.toggleItem(item.id),
                );
              },
            ),
            SizedBox(height: R.h(24)),
            _pickupProof(viewModel),
            SizedBox(height: R.h(24)),
            _confirmButton(context, viewModel),
            SizedBox(height: R.h(40)),
          ],
        ),
      ),
    );
  }

  Widget _locationCard(Order order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(R.w(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PICKUP LOCATION",
                  style: TextStyle(
                    fontSize: R.sp(12),
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: R.h(8)),
                Text(
                  order.vendor?.storeName ?? "WAREHOUSE BAY 4B",
                  style: TextStyle(
                    fontSize: R.sp(22),
                    fontWeight: FontWeight.w800,
                    color: AppColors.headingText,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  order.vendor?.address ??
                      "Avenue 5, Logistics Park, Sector 12",
                  style: TextStyle(
                    fontSize: R.sp(14),
                    color: AppColors.bodyText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: R.h(20)),
                ElevatedButton.icon(
                  onPressed: () => _showAddressBottomSheet(context, order),
                  icon: Icon(RemixIcons.map_pin_2_fill, size: R.sp(18)),
                  label: const Text("See Address"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, R.h(50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(25)),
                    ),
                    elevation: 0,
                    textStyle: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: R.h(12)),
                ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(order.vendor?.mobile ?? ''),
                  icon: Icon(RemixIcons.phone_fill, size: R.sp(18)),
                  label: const Text("Call Manager"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryGreen.withValues(alpha: 0.1),
                    foregroundColor: AppColors.headingText,
                    minimumSize: Size(double.infinity, R.h(50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(25)),
                    ),
                    elevation: 0,
                    textStyle: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(R.r(24)),
              bottomRight: Radius.circular(R.r(24)),
            ),
            child: CustomNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80\u0026w=2066\u0026auto=format\u0026fit=crop',
              height: R.h(160),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemsHeader(OrderViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "ITEM CHECKLIST",
          style: TextStyle(
            fontSize: R.sp(16),
            fontWeight: FontWeight.w800,
            color: AppColors.headingText,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(4)),
          decoration: BoxDecoration(
            color: AppColors.softGreyBg,
            borderRadius: BorderRadius.circular(R.r(8)),
          ),
          child: Text(
            "${viewModel.orderItems.length} ITEMS",
            style: TextStyle(
              fontSize: R.sp(10),
              fontWeight: FontWeight.w800,
              color: AppColors.bodyText.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemTile({
    required OrderItem item,
    required bool isChecked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(12)),
        padding: EdgeInsets.all(R.w(12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: R.w(60),
              height: R.h(60),
              decoration: BoxDecoration(
                color: AppColors.softGreyBg,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CustomNetworkImage(
                  imageUrl: item.product?.productImageUrls.firstOrNull ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: R.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product?.name ?? "Product",
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingText,
                    ),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    "Qty: ${item.quantity}",
                    style: TextStyle(
                      fontSize: R.sp(14),
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isChecked
                  ? RemixIcons.checkbox_circle_fill
                  : RemixIcons.checkbox_blank_circle_line,
              color: isChecked
                  ? AppColors.primaryGreen
                  : Colors.grey.withValues(alpha: 0.3),
              size: R.sp(28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickupProof(OrderViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PICKUP PROOF",
          style: TextStyle(
            fontSize: R.sp(16),
            fontWeight: FontWeight.w800,
            color: AppColors.headingText,
          ),
        ),
        SizedBox(height: R.h(16)),
        InkWell(
          onTap: () => viewModel.pickProofImage(ImageSource.camera),
          child: CustomPaint(
            painter: DashedRectPainter(
              color: AppColors.bodyText.withValues(alpha: 0.2),
              strokeWidth: 1.5,
              gap: 5,
            ),
            child: Container(
              height: R.h(140),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(R.r(40)),
              ),
              child: viewModel.pickupProofImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(R.r(40)),
                      child: Image.file(viewModel.pickupProofImage!,
                          fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: R.r(30),
                          backgroundColor:
                              AppColors.primaryGreen.withValues(alpha: 0.1),
                          child: Icon(RemixIcons.camera_2_fill,
                              color: AppColors.primaryGreen, size: R.sp(24)),
                        ),
                        SizedBox(height: R.h(12)),
                        Text(
                          "Take Photo of Items",
                          style: TextStyle(
                            fontSize: R.sp(14),
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
                        ),
                        SizedBox(height: R.h(4)),
                        Text(
                          "Required to start delivery",
                          style: TextStyle(
                            fontSize: R.sp(12),
                            color: AppColors.bodyText.withValues(alpha: 0.6),
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

  Widget _confirmButton(BuildContext context, OrderViewModel viewModel) {
    final bool isReady =
        viewModel.checkedItems.length == viewModel.orderItems.length &&
            viewModel.pickupProofImage != null;

    return SizedBox(
      width: double.infinity,
      height: R.h(54),
      child: ElevatedButton(
        onPressed: isReady && !viewModel.isPickupLoading
            ? () => _handleConfirmPickup(context, viewModel)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isReady ? AppColors.primaryGreen : Colors.grey.shade200,
          foregroundColor: isReady ? Colors.white : Colors.grey.shade500,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(R.r(27))),
          disabledBackgroundColor: Colors.grey.shade200,
        ),
        child: viewModel.isPickupLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3))
            : Text(
                "Confirm & Start Delivery",
                style: TextStyle(
                  fontSize: R.sp(18),
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  void _handleConfirmPickup(
      BuildContext context, OrderViewModel viewModel) async {
    final success = await viewModel.pickupOrder();
    if (success && context.mounted) {
      CustomSnackBar.showSuccess(context, "Pickup Confirmed");
      // Navigate to customer info or whatever is next
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerInfoView(
            order: viewModel.order,
            orderId: viewModel.order?.id,
          ),
        ),
      );
    } else if (context.mounted) {
      CustomSnackBar.showError(context,
          viewModel.error ?? "Please check all items and upload proof");
    }
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
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
        Radius.circular(R.r(40)),
      ));

    final Path dashPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) => false;
}
