import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:samrudhi_delivery_agent_app/view/verification/delivery_verification_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDeliveryScreen extends StatelessWidget {
  const OrderDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final viewModel = context.watch<OrderViewModel>();
    final order = viewModel.order;

    if (order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.softGreyBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.softGreyBg,
        leading: Container(
          margin: EdgeInsets.all(R.w(8)),
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: AppColors.black, size: R.sp(18)),
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Order #${order.orderNumber}',
          style: TextStyle(
            color: AppColors.black,
            fontSize: R.sp(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: R.w(16)),
            padding:
                EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
            decoration: BoxDecoration(
              color: AppColors.softGreenBg, // Light green
              borderRadius: BorderRadius.circular(R.r(20)),
            ),
            alignment: Alignment.center,
            child: Text(
              'ACTIVE',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
                fontSize: R.sp(12),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= TIMELINE =================
            Container(
              padding: EdgeInsets.all(R.w(20)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(R.r(30)),
              ),
              child: Column(
                children: [
                  _buildTimelineItem(
                    isCompleted: true,
                    title: 'Order Picked Up',
                    subtitle:
                        'Today, ${TimeOfDay.fromDateTime(order.updatedAt).format(context)}',
                    icon: remix_check_line_circle(true),
                    isFirst: true,
                  ),
                  _buildTimelineItem(
                    isCompleted: false, // Currently active step
                    isActive: true,
                    title: 'Reached Location',
                    subtitle: 'Pending Confirmation',
                    icon: remix_truck_line_circle(true), // Green truck
                    isLast: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(24)),

            // ================= CUSTOMER DETAILS =================
            Text(
              'CUSTOMER DETAILS',
              style: TextStyle(
                color: AppColors.bodyText,
                fontSize: R.sp(14),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: R.h(12)),
            Container(
              padding: EdgeInsets.all(R.w(20)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(R.r(30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: R.w(50),
                        height: R.w(50),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(R.r(25)),
                          child: order.user?.profilePhoto != null
                              ? CachedNetworkImage(
                                  imageUrl: order.user!.profilePhoto!
                                          .startsWith('http')
                                      ? order.user!.profilePhoto!
                                      : '${AppUrls.baseUrl}/${order.user!.profilePhoto}',
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Image.asset(
                                      'assets/images/profile_placeholder.png'),
                                )
                              : Image.asset(
                                  'assets/images/profile_placeholder.png'),
                        ),
                      ),
                      SizedBox(width: R.w(16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.user?.fullName ?? 'Customer',
                              style: TextStyle(
                                fontSize: R.sp(18),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            // Optional: Premium Member badge if needed, skipping for dynamic data
                            SizedBox(height: R.h(4)),
                            Text(
                              order.deliveryAddress != null
                                  ? '${order.deliveryAddress!.addressLine1}, ${order.deliveryAddress!.city}, ${order.deliveryAddress!.state} ${order.deliveryAddress!.postcode}'
                                  : 'No Address Provided',
                              style: TextStyle(
                                color: AppColors.bodyText,
                                fontSize: R.sp(13),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(20)),
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          icon: Remix.phone_fill,
                          label: 'Call',
                          onTap: () async {
                            if (order.user?.mobile != null) {
                              final uri =
                                  Uri.parse('tel:${order.user!.mobile}');
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: R.w(12)),
                      Expanded(
                        child: _actionButton(
                          icon: Remix.message_2_fill,
                          label: 'Message',
                          color: AppColors.softGreenBg, // Light Green bg
                          iconColor: AppColors.green, // Dark Green text
                          onTap: () async {
                            if (order.user?.mobile != null) {
                              final uri =
                                  Uri.parse('sms:${order.user!.mobile}');
                              if (await canLaunchUrl(uri)) await launchUrl(uri);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(24)),

            // ================= ORDER MANIFEST =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ORDER MANIFEST',
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(8), vertical: R.h(4)),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(R.r(8)),
                  ),
                  child: Text(
                    '${order.orderItems.length} ITEMS',
                    style: TextStyle(
                      fontSize: R.sp(11),
                      fontWeight: FontWeight.bold,
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(12)),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(R.r(30)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(R.w(20)),
                itemCount: order.orderItems.length,
                separatorBuilder: (ctx, index) =>
                    Divider(height: R.h(32), color: AppColors.grey200),
                itemBuilder: (ctx, index) {
                  final item = order.orderItems[index];
                  final product = item.product;
                  return Row(
                    children: [
                      Container(
                        width: R.w(56),
                        height: R.w(56),
                        decoration: BoxDecoration(
                          color: AppColors.softGreyBg,
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(R.w(28)),
                          child: product?.productImages.isNotEmpty == true
                              ? CachedNetworkImage(
                                  imageUrl: product!.productImages.first
                                          .startsWith('http')
                                      ? product.productImages.first
                                      : '${AppUrls.baseUrl}/${product.productImages.first}',
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Icon(
                                      Remix.image_line,
                                      color: AppColors.grey),
                                )
                              : Icon(Remix.gift_fill, color: AppColors.grey),
                        ),
                      ),
                      SizedBox(width: R.w(16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product?.name ?? 'Unknown Item',
                              style: TextStyle(
                                fontSize: R.sp(16),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (product?.description != null) // Or unit
                              Text(
                                '${product?.stock ?? ''} Unit',
                                style: TextStyle(
                                  fontSize: R.sp(13),
                                  color: AppColors.hintText,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: R.w(12), vertical: R.h(6)),
                        decoration: BoxDecoration(
                          color: AppColors.softGreenBg,
                          borderRadius: BorderRadius.circular(R.r(20)),
                        ),
                        child: Text(
                          'x${item.quantity}',
                          style: TextStyle(
                            fontSize: R.sp(14),
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: R.h(24)),

            // ================= TOTAL TO COLLECT =================
            Container(
              padding: EdgeInsets.all(R.w(20)),
              decoration: BoxDecoration(
                color: AppColors.softGreenBg, // Light green background
                borderRadius: BorderRadius.circular(R.r(30)),
                border: Border.all(color: AppColors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total to Collect',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: R.sp(14),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: R.w(10), vertical: R.h(4)),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(R.r(8)),
                        ),
                        child: Text(
                          'COD',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: R.sp(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    '₹${order.totalAmount}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: R.sp(32),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: R.h(12)),
                  Row(
                    children: [
                      Icon(Remix.money_dollar_circle_line,
                          color: AppColors.green, size: R.sp(18)),
                      SizedBox(width: R.w(6)),
                      Text(
                        'CASH ON DELIVERY REQUIRED',
                        style: TextStyle(
                          fontSize: R.sp(12),
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(120)), // Space for sticky button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(R.w(20)),
        decoration: BoxDecoration(
          color: AppColors.transparent, // Or gradient
        ),
        child: SafeArea(
          child: SizedBox(
            height: R.h(56),
            child: ElevatedButton.icon(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: ChangeNotifierProvider.value(
                    value: viewModel,
                    child: DeliveryVerificationView(
                      orderId: order.id,
                    ),
                  ),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen, // Bright green
                foregroundColor: AppColors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.r(30)),
                ),
                elevation: 4,
                shadowColor: AppColors.primaryGreen.withOpacity(0.4),
              ),
              icon: Icon(Remix.map_pin_user_fill, size: R.sp(20)),
              label: Text(
                'Mark as Arrived',
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isCompleted,
    bool isActive = false,
    required String title,
    required String subtitle,
    required Widget icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              icon,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? AppColors.green : AppColors.divider,
                  ),
                ),
            ],
          ),
          SizedBox(width: R.w(16)),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : R.h(24), top: R.h(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: R.sp(13),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontStyle: isActive ? FontStyle.italic : FontStyle.normal,
                    color: isActive ? AppColors.green : AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget remix_check_line_circle(bool active) {
    return Container(
      width: R.w(28),
      height: R.w(28),
      decoration: BoxDecoration(
        color: AppColors.softGreenBg,
        shape: BoxShape.circle,
      ),
      child: Icon(Remix.check_fill, color: AppColors.green, size: R.sp(16)),
    );
  }

  Widget remix_truck_line_circle(bool active) {
    return Container(
      width: R.w(28),
      height: R.w(28),
      decoration: BoxDecoration(
        color: active ? AppColors.green : AppColors.softGreyBg,
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.green.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Icon(Remix.truck_fill, color: AppColors.white, size: R.sp(14)),
    );
  }

  Widget _actionButton(
      {required IconData icon,
      required String label,
      Color? color,
      Color? iconColor,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(R.r(16)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: R.h(12)),
        decoration: BoxDecoration(
          color: color ?? AppColors.softGreyBg,
          borderRadius: BorderRadius.circular(R.r(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: R.sp(18), color: iconColor ?? AppColors.textPrimary),
            SizedBox(width: R.w(8)),
            Text(
              label,
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w600,
                color: iconColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
