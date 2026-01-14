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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: R.sp(20)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delivery Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: R.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: R.w(8)),
            Text(
              '#${order.orderNumber}',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: R.sp(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(R.w(20)),
              child: Column(
                children: [
                  // Customer Profile Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: R.h(32), horizontal: R.w(24)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(24)),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: R.w(100),
                          height: R.w(100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white,
                                width: 4), // White border for clean look
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(R.r(50)),
                                child: order.user?.profilePhoto != null
                                    ? CachedNetworkImage(
                                        imageUrl: order.user!.profilePhoto!
                                                .startsWith('http')
                                            ? order.user!.profilePhoto!
                                            : '${AppUrls.baseUrl}/${order.user!.profilePhoto}',
                                        width: R.w(100),
                                        height: R.w(100),
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Icon(Remix.user_fill,
                                                color: Colors.grey[400],
                                                size: R.sp(40)),
                                      )
                                    : Icon(Remix.user_fill,
                                        color: Colors.grey[400],
                                        size: R.sp(40)),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: EdgeInsets.all(R.w(6)),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: Icon(Remix.verified_badge_fill,
                                      color: Colors.white, size: R.sp(14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: R.h(20)),
                        Text(
                          order.user?.fullName ?? 'Valued Customer',
                          style: TextStyle(
                            fontSize: R.sp(20),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: R.h(8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: R.w(12), vertical: R.h(6)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(R.r(100)),
                            border: Border.all(
                                color:
                                    const Color(0xFFBBF7D0).withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Remix.star_fill,
                                  color: const Color(0xFF059669),
                                  size: R.sp(12)),
                              SizedBox(width: R.w(4)),
                              Text(
                                'PRIMARY CUSTOMER',
                                style: TextStyle(
                                  fontSize: R.sp(11),
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF059669),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: R.h(20)),

                  SizedBox(height: R.h(20)),

                  // Drop-off Point Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(R.w(24)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(24)),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
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
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(R.r(12)),
                              ),
                              child: Icon(Remix.map_pin_fill,
                                  color: const Color(0xFF4B5563),
                                  size: R.sp(20)),
                            ),
                            SizedBox(width: R.w(12)),
                            Text(
                              'DROP-OFF LOCATION',
                              style: TextStyle(
                                fontSize: R.sp(13),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6B7280),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: R.h(16)),
                        Text(
                          order.deliveryAddress != null
                              ? '${order.deliveryAddress!.addressLine1}, ${order.deliveryAddress!.city}'
                              : 'No Address Provided',
                          style: TextStyle(
                            fontSize: R.sp(18),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: R.h(24)),
                        // Map Preview with Navigate Button
                        GestureDetector(
                          onTap: () async {
                            if (order.deliveryAddress == null) return;

                            double? lat = double.tryParse(
                                order.deliveryAddress!.latitude ?? '');
                            double? lng = double.tryParse(
                                order.deliveryAddress!.longitude ?? '');

                            Uri uri;

                            if (lat != null && lng != null) {
                              if (Platform.isAndroid) {
                                uri = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
                              } else if (Platform.isIOS) {
                                uri = Uri.parse(
                                    "https://maps.apple.com/?q=$lat,$lng");
                              } else {
                                uri = Uri.parse(
                                    "https://www.google.com/maps/search/?api=1&query=$lat,$lng");
                              }
                            } else {
                              final String address =
                                  "${order.deliveryAddress!.addressLine1}, ${order.deliveryAddress!.city}";
                              if (Platform.isAndroid) {
                                uri = Uri.parse(
                                    "geo:0,0?q=${Uri.encodeComponent(address)}");
                              } else if (Platform.isIOS) {
                                uri = Uri.parse(
                                    "https://maps.apple.com/?q=${Uri.encodeComponent(address)}");
                              } else {
                                uri = Uri.parse(
                                    "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}");
                              }
                            }

                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              // If generic launch fails, fallback to web google maps
                              final webUri = Uri.parse(
                                  "https://www.google.com/maps/search/?api=1&query=${lat ?? 0},${lng ?? 0}");
                              if (await canLaunchUrl(webUri)) {
                                await launchUrl(webUri,
                                    mode: LaunchMode.externalApplication);
                              }
                            }
                          },
                          child: Container(
                              height: R.h(160),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(R.r(20)),
                                color: Colors.grey[200],
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/images/map_placeholder.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: R.w(16),
                                          vertical: R.h(12)),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen,
                                        borderRadius:
                                            BorderRadius.circular(R.r(30)),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Remix.navigation_fill,
                                              color: Colors.white,
                                              size: R.sp(20)),
                                          SizedBox(width: R.w(8)),
                                          Text(
                                            "Navigate",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: R.sp(14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: R.h(20)),

                  // Item Summary Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(R.w(20)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(24)),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(R.w(14)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(R.r(16)),
                            border: Border.all(color: const Color(0xFFF3F4F6)),
                          ),
                          child: Icon(
                              Remix
                                  .shopping_bag_3_fill, // Note: Capital 'F' for correct Remix icon if needed, checking import
                              color: const Color(0xFF374151),
                              size: R.sp(22)),
                        ),
                        SizedBox(width: R.w(16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.orderItems.length} Item${order.orderItems.length > 1 ? 's' : ''} (${order.orderItems.isNotEmpty ? order.orderItems.first.product?.name ?? 'Product' : 'Items'})',
                                style: TextStyle(
                                    fontSize: R.sp(16),
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                    overflow: TextOverflow.ellipsis),
                                maxLines: 1,
                              ),
                              SizedBox(height: R.h(6)),
                              Row(
                                children: [
                                  Icon(Remix.checkbox_circle_fill,
                                      color: AppColors.primaryGreen,
                                      size: R.sp(16)),
                                  SizedBox(width: R.w(6)),
                                  Text(
                                    'Paid Online',
                                    style: TextStyle(
                                        fontSize: R.sp(13),
                                        color: const Color(0xFF6B7280),
                                        fontWeight: FontWeight.w500),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.grey[300], size: R.sp(16))
                      ],
                    ),
                  ),
                  SizedBox(height: R.h(100)), // Bottom padding for FAB/Button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: const Color(0xFFF9FAFB),
          padding: EdgeInsets.all(R.w(20)),
          child: SizedBox(
            width: double.infinity,
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
              icon: Icon(Remix.truck_fill, color: Colors.black, size: R.sp(20)),
              label: Text(
                'START DELIVERY',
                style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(30))),
                  elevation: 0),
            ),
          ),
        ),
      ),
    );
  }
}
