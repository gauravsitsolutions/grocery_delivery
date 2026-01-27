import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
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
              icon: Icon(
                  Theme.of(context).platform == TargetPlatform.iOS
                      ? Remix.arrow_left_s_line
                      : Remix.arrow_left_line,
                  color: AppColors.black,
                  size: R.sp(20)),
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
                    R.w(20),
                    R.w(16),
                    R.w(20),
                    R.w(16) + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(R.r(24)),
                      topRight: Radius.circular(R.r(24)),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: R.h(56),
                    child: ElevatedButton(
                      onPressed: canProceed && !viewModel.isPickupLoading
                          ? () => _handleConfirmPickup(viewModel)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        disabledBackgroundColor: AppColors.grey300,
                        elevation: canProceed ? 8 : 0,
                        shadowColor:
                            AppColors.primaryGreen.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.r(16)),
                        ),
                      ),
                      child: viewModel.isPickupLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: AppColors.white, strokeWidth: 2.5),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Confirm Pickup',
                                  style: TextStyle(
                                    fontSize: R.sp(16),
                                    fontWeight: FontWeight.bold,
                                    color: canProceed
                                        ? AppColors.white
                                        : AppColors.grey500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (canProceed) ...[
                                  SizedBox(width: R.w(10)),
                                  Icon(RemixIcons.arrow_right_line,
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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(R.w(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.w(10)),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(RemixIcons.store_2_fill,
                    color: AppColors.primaryGreen, size: R.sp(24)),
              ),
              SizedBox(width: R.w(12)),
              Text(
                'PICKUP LOCATION',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Text(
            order.vendor?.storeName ?? 'Warehouse Bay 4B',
            style: TextStyle(
              color: AppColors.headingText,
              fontSize: R.sp(22), // Larger font
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          SizedBox(height: R.h(8)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: R.h(2)),
                child: Icon(RemixIcons.map_pin_line,
                    color: AppColors.bodyText, size: R.sp(16)),
              ),
              SizedBox(width: R.w(8)),
              Expanded(
                child: Text(
                  order.vendor?.address ??
                      'Avenue 5, Logistics Park, Sector 12, Bengaluru',
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: R.sp(15),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(24)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _makePhoneCall(order.vendor?.mobile ?? '1234567890');
              },
              icon: Icon(RemixIcons.phone_fill, size: R.sp(20)),
              label: Text(
                'Call Store Manager',
                style: TextStyle(
                  fontSize: R.sp(15),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryGreen,
                elevation: 0,
                side:
                    const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: R.h(14)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.r(12)),
                ),
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
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
              decoration: BoxDecoration(
                color: AppColors.softGreenBg,
                borderRadius: BorderRadius.circular(R.r(20)),
              ),
              child: Text(
                '${viewModel.checkedItems.length}/${viewModel.orderItems.length} VERIFIED',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: R.sp(11),
                  fontWeight: FontWeight.w800,
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
            child: GestureDetector(
              onTap: isVerifying ? null : () => viewModel.toggleItem(item.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen.withValues(alpha: 0.04)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(R.r(16)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.borderLight,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                padding: EdgeInsets.all(R.w(12)),
                child: Row(
                  children: [
                    // Product Icon Image
                    Container(
                      width: R.w(56),
                      height: R.w(56),
                      decoration: BoxDecoration(
                        color: AppColors.softGreyBg,
                        borderRadius: BorderRadius.circular(R.r(12)),
                        image: item.product != null &&
                                (item.product!.productImageUrls.isNotEmpty ||
                                    item.product!.productImages.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(
                                  item.product!.productImageUrls.isNotEmpty
                                      ? item.product!.productImageUrls.first
                                      : '${AppUrls.productImages}${item.product!.productImages.first}',
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: item.product == null ||
                              (item.product!.productImageUrls.isEmpty &&
                                  item.product!.productImages.isEmpty)
                          ? Center(
                              child: Icon(RemixIcons.shopping_bag_3_fill,
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.grey400,
                                  size: R.sp(24)),
                            )
                          : null,
                    ),
                    SizedBox(width: R.w(16)),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product?.name ?? 'Product Item',
                            style: TextStyle(
                              fontSize: R.sp(15),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? AppColors.headingText
                                  : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: R.h(4)),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: R.w(8), vertical: R.h(2)),
                                decoration: BoxDecoration(
                                  color: AppColors.softGreenBg,
                                  borderRadius: BorderRadius.circular(R.r(4)),
                                ),
                                child: Text(
                                  'QTY: ${item.quantity}',
                                  style: TextStyle(
                                    fontSize: R.sp(12),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Checkbox
                    SizedBox(width: R.w(12)),
                    isVerifying
                        ? SizedBox(
                            width: R.w(24),
                            height: R.w(24),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primaryGreen,
                            ),
                          )
                        : Container(
                            width: R.w(28),
                            height: R.w(28),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : AppColors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : AppColors.grey300!,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(Icons.check,
                                    color: AppColors.white, size: R.sp(16))
                                : null,
                          ),
                  ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PICKUP PROOF',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: R.sp(16),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            if (viewModel.pickupProofImage != null)
              GestureDetector(
                onTap: () => viewModel.pickProofImage(ImageSource.camera),
                child: Text(
                  'Retake Photo',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: R.sp(13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: R.h(16)),
        InkWell(
          onTap: () => viewModel.pickProofImage(ImageSource.camera),
          borderRadius: BorderRadius.circular(R.r(24)),
          child: Container(
            width: double.infinity,
            height: R.h(200),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(R.r(24)),
              border: viewModel.pickupProofImage != null
                  ? Border.all(color: AppColors.primaryGreen, width: 2)
                  : Border.all(color: AppColors.borderLight, width: 1.5),
              boxShadow: viewModel.pickupProofImage != null
                  ? [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: viewModel.pickupProofImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(R.r(22)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          viewModel.pickupProofImage!,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.black.withValues(alpha: 0.0),
                                AppColors.black.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: R.h(16)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle,
                                    color: AppColors.white, size: R.sp(20)),
                                SizedBox(width: R.w(8)),
                                Text(
                                  'Photo Captured',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: R.sp(14),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: R.w(64),
                          height: R.w(64),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            RemixIcons.camera_lens_line,
                            color: AppColors.primaryGreen,
                            size: R.sp(32),
                          ),
                        ),
                        SizedBox(height: R.h(16)),
                        Text(
                          'Tap to Capture Items',
                          style: TextStyle(
                            color: AppColors.headingText,
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: R.h(6)),
                        Text(
                          'Ensure all items are clearly visible',
                          style: TextStyle(
                            color: AppColors.bodyText,
                            fontSize: R.sp(13),
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
      ..color = AppColors.primaryGreen.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const double dashWidth = 6;
    const double dashSpace = 4;
    const double r = 24.0;

    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(r)));

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
