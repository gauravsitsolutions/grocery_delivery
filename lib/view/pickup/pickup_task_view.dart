import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/view/pickup/pickup_success_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';

class PickupTaskView extends StatefulWidget {
  final Order order;

  const PickupTaskView({super.key, required this.order});

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

  Future<void> _openMap(String address) async {
    // Encode the address for the query parameter
    final query = Uri.encodeComponent(address);
    final googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$query";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context); // Initialize Responsive Utils
    return Consumer<OrderViewModel>(
      builder: (context, viewModel, child) {
        final order = viewModel.order ?? widget.order;
        final canProceed =
            viewModel.checkedItems.length == viewModel.orderItems.length &&
                viewModel.pickupProofImage != null;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg, // Light gray background
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color: AppColors.black, size: R.sp(20)),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  'PICKUP TASK',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '#${order.orderNumber}',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: R.w(16),
                  right: R.w(16),
                  top: R.h(16),
                  bottom: R.h(120), // Increased space for bottom button
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationCard(order),
                    SizedBox(height: R.h(24)),
                    _buildItemChecklist(viewModel),
                    SizedBox(height: R.h(24)),
                    _buildPickupProof(viewModel),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    R.w(16),
                    R.w(16),
                    R.w(16),
                    R.w(16) +
                        MediaQuery.of(context).padding.bottom, // Safe Area
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: R.h(50),
                    child: ElevatedButton(
                      onPressed: canProceed && !viewModel.isPickupLoading
                          ? () => _handleConfirmPickup(viewModel)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        disabledBackgroundColor:
                            AppColors.primaryGreen.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.r(25)),
                        ),
                        elevation: 0,
                      ),
                      child: viewModel.isPickupLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: AppColors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Confirm & Start Delivery',
                                  style: TextStyle(
                                    fontSize: R.sp(16),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                if (canProceed) ...[
                                  SizedBox(width: R.w(8)),
                                  Icon(RemixIcons.checkbox_circle_fill,
                                      color: AppColors.white, size: R.sp(20)),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationCard(Order order) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(R.w(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PICKUP LOCATION',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: R.sp(11),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: R.h(8)),
                Text(
                  order.vendor?.storeName ?? 'Warehouse Bay 4B',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: R.sp(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  order.vendor?.address ??
                      'Avenue 5, Logistics Park, Sector 12',
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: R.sp(14),
                  ),
                ),
                SizedBox(height: R.h(16)),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Use vendor address or a default one
                          final address = order.vendor?.address ??
                              'Avenue 5, Logistics Park, Sector 12';
                          _openMap(address);
                        },
                        icon: Icon(RemixIcons.map_2_fill, size: R.sp(18)),
                        label: const Text('Show on Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: R.h(12)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(30)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.h(12)),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // Use vendor mobile or a default
                          _makePhoneCall(order.vendor?.mobile ?? '1234567890');
                        },
                        icon: Icon(RemixIcons.phone_fill,
                            color: AppColors.textPrimary, size: R.sp(18)),
                        label: Text(
                          'Call Manager',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: R.sp(14),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.softGreyBg,
                          padding: EdgeInsets.symmetric(vertical: R.h(12)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(30)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map Placeholder Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(R.r(20)),
              bottomRight: Radius.circular(R.r(20)),
            ),
            child: SizedBox(
              height: R.h(120),
              width: double.infinity,
              child: Image.asset(
                'assets/images/map_placeholder.png', // Needs to be generated/added
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                      color: AppColors.grey200,
                      child: Center(
                          child: Icon(Icons.map, color: AppColors.grey)));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemChecklist(OrderViewModel viewModel) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ITEM CHECKLIST',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: R.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
              decoration: BoxDecoration(
                color: AppColors.softGreyBg,
                borderRadius: BorderRadius.circular(R.r(6)),
              ),
              child: Text(
                '${viewModel.orderItems.length} ITEMS',
                style: TextStyle(
                  color: AppColors.bodyText,
                  fontSize: R.sp(11),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: R.h(16)),
        ...viewModel.orderItems.map((item) {
          final isSelected = viewModel.checkedItems.contains(item.id);
          final isVerifying = viewModel.isItemVerifying(item.id);

          return Padding(
            padding: EdgeInsets.only(bottom: R.h(12)),
            child: Theme(
              data: ThemeData(
                  checkboxTheme: const CheckboxThemeData(
                shape: CircleBorder(),
                side: BorderSide(color: AppColors.borderLight, width: 2),
              )),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(R.r(16)),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.5))
                      : null,
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: isVerifying
                      ? null
                      : (val) => viewModel.toggleItem(item.id),
                  activeColor: AppColors.primaryGreen,
                  checkColor: AppColors.white,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: R.w(16), vertical: R.h(6)),
                  secondary: isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primaryGreen),
                        )
                      : CircleAvatar(
                          backgroundColor: AppColors.softGreyBg,
                          radius: R.r(24),
                          child: Icon(RemixIcons.shopping_bag_3_fill,
                              color: AppColors.grey400, size: R.sp(20)),
                        ),
                  title: Text(
                    item.product?.name ?? 'Product Item',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  subtitle: Text(
                    'Qty: ${item.quantity}',
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPickupProof(OrderViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PICKUP PROOF',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: R.sp(16),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: R.h(16)),
        InkWell(
          onTap: () => viewModel.pickProofImage(ImageSource.camera),
          borderRadius: BorderRadius.circular(R.r(24)),
          child: Container(
            width: double.infinity,
            height: R.h(180),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(R.r(24)),
              border: Border.all(
                color: AppColors.borderLight, // Grey 200
                style: BorderStyle.solid,
              ),
            ),
            child: viewModel.pickupProofImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(R.r(24)),
                    child: Image.file(
                      viewModel.pickupProofImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(R.w(16)),
                          decoration: const BoxDecoration(
                            color: AppColors.softGreenBg, // Light green
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            RemixIcons.camera_fill,
                            color: AppColors.primaryGreen,
                            size: R.sp(32),
                          ),
                        ),
                        SizedBox(height: R.h(12)),
                        Text(
                          'Take Photo of Items',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: R.sp(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: R.h(4)),
                        Text(
                          'Required to start delivery',
                          style: TextStyle(
                            color: AppColors.hintText,
                            fontSize: R.sp(12),
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

  Future<void> _handleConfirmPickup(OrderViewModel viewModel) async {
    final success = await viewModel.pickupOrder();

    if (!mounted) return;

    if (success) {
      CustomSnackBar.showSuccess(context, 'Pickup confirmed successfully!');

      // Navigate to Pickup Success View
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: PickupSuccessView(order: widget.order),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else {
      if (viewModel.error != null) {
        CustomSnackBar.showError(context, viewModel.error!);
      }
    }
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderLight // Grey 300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const double dashWidth = 8;
    const double dashSpace = 6;
    const double r = 24.0; // Radius matching container

    // Start top center
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(r)));

    // Draw dashed path
    final Path dashedPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
