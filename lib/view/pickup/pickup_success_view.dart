import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class PickupSuccessView extends StatelessWidget {
  final Order order;

  const PickupSuccessView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.softGreyBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.transparent,
        leading: IconButton(
          icon: Icon(Icons.adaptive.arrow_back,
              color: AppColors.black, size: R.sp(20)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Pickup Status',
          style: TextStyle(
            color: AppColors.black,
            fontSize: R.sp(18),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(20)),
        child: Column(
          children: [
            SizedBox(height: R.h(20)),

            // Success Indicator
            AvatarGlow(
              glowColor: AppColors.primaryGreen,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              startDelay: const Duration(milliseconds: 100),
              child: Container(
                padding: EdgeInsets.all(R.w(30)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                ),
                child: Container(
                  padding: EdgeInsets.all(R.w(24)),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen,
                  ),
                  child: Icon(
                    Remix.check_line,
                    color: AppColors.white,
                    size: R.sp(48),
                  ),
                ),
              ),
            ),
            SizedBox(height: R.h(20)),
            Text(
              'Pickup Complete!',
              style: TextStyle(
                fontSize: R.sp(24),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: R.h(8)),
            Text(
              'Ready for delivery',
              style: TextStyle(
                fontSize: R.sp(14),
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: R.h(32)),

            // Items Loaded Card
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(16)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(R.r(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${order.orderItems.length} Items Loaded',
                        style: TextStyle(
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: R.h(4)),
                      Text(
                        'Order #${order.orderNumber}',
                        style: TextStyle(
                          fontSize: R.sp(12),
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(R.w(12)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Remix.shopping_bag_3_fill,
                      color: AppColors.textPrimary,
                      size: R.sp(20),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(24)),

            // Next Destination Header
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Next Destination',
                style: TextStyle(
                  fontSize: R.sp(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: R.h(16)),

            // Next Destination Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(R.r(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Map Placeholder (Top half of card)
                  Container(
                    height: R.h(120),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(R.r(24))),
                      color: AppColors.grey200, // Placeholder color
                      image: const DecorationImage(
                        image: AssetImage(
                            'assets/images/map_placeholder.png'), // Ensure this asset exists or use a network placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Remix.map_pin_fill,
                            color: AppColors.primaryGreen,
                            size: R.sp(32),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Customer Info (Bottom half)
                  Padding(
                    padding: EdgeInsets.all(R.w(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.user?.fullName ?? 'Customer',
                              style: TextStyle(
                                fontSize: R.sp(18),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: R.w(12), vertical: R.h(6)),
                              decoration: BoxDecoration(
                                color: AppColors.softGreenBg, // Light green
                                borderRadius: BorderRadius.circular(R.r(20)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '8 mins', // Placeholder
                                    style: TextStyle(
                                      fontSize: R.sp(12),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '1.2 km', // Placeholder
                                    style: TextStyle(
                                      fontSize: R.sp(10),
                                      color: AppColors.bodyText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: R.h(8)),
                        Row(
                          children: [
                            Icon(Remix.navigation_fill,
                                size: R.sp(14), color: AppColors.bodyText),
                            SizedBox(width: R.w(4)),
                            Expanded(
                              child: Text(
                                order.deliveryAddress?.addressLine1 ??
                                    'Delivery Address',
                                style: TextStyle(
                                  fontSize: R.sp(14),
                                  color: AppColors.bodyText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: R.h(16)),
                        // Delivery Note (if any, or static placeholder from mockup)
                        Container(
                          padding: EdgeInsets.all(R.w(12)),
                          decoration: BoxDecoration(
                            color: AppColors.softGreyBg,
                            borderRadius: BorderRadius.circular(R.r(12)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: R.w(10),
                                height: R.w(10),
                                decoration: const BoxDecoration(
                                  color: Color(
                                      0xFF53B1B1), // Teal color from mockup
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: R.w(12)),
                              const Expanded(
                                child: Text(
                                  '"Please leave at the front door and ring bell."', // Static placeholder for now as per mockup
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.bodyText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(30)),

            // Start Navigation Button
            SizedBox(
              width: double.infinity,
              height: R.h(56),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Delivery Screen (OrderDetailsView handles routing to OrderDeliveryScreen)
                  // Pop to reveal the underlying OrderDetailsView which will have updated to Delivery Mode
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(30)),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Navigation',
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: R.h(16)),

            // View Items List
            TextButton.icon(
              onPressed: () {
                _showItemsList(context);
              },
              icon: Icon(Remix.list_check_2,
                  color: AppColors.primaryGreen, size: R.sp(18)),
              label: Text(
                'View Items List',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: R.sp(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: R.h(20)),
          ],
        ),
      ),
    );
  }

  void _showItemsList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
        ),
        child: Column(
          children: [
            SizedBox(height: R.h(12)),
            Container(
              width: R.w(40),
              height: R.h(4),
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(R.r(2)),
              ),
            ),
            SizedBox(height: R.h(16)),
            Text(
              'Order Items',
              style: TextStyle(
                fontSize: R.sp(18),
                fontWeight: FontWeight.bold,
                color: AppColors.headingText,
              ),
            ),
            SizedBox(height: R.h(16)),
            Expanded(
              child: order.orderItems.isEmpty
                  ? Center(
                      child: Text(
                        'No items found',
                        style: TextStyle(
                          color: AppColors.bodyText,
                          fontSize: R.sp(16),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(20), vertical: R.h(8)),
                      itemCount: order.orderItems.length,
                      itemBuilder: (context, index) {
                        final item = order.orderItems[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: R.h(16)),
                          child: Row(
                            children: [
                              Container(
                                width: R.w(60),
                                height: R.w(60),
                                decoration: BoxDecoration(
                                  color: AppColors.softGreyBg,
                                  borderRadius: BorderRadius.circular(R.r(12)),
                                  image: item.product?.productImageUrls
                                              .isNotEmpty ==
                                          true
                                      ? DecorationImage(
                                          image: NetworkImage(item
                                              .product!.productImageUrls.first),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: item.product?.productImageUrls.isEmpty ??
                                        true
                                    ? Icon(Remix.image_line,
                                        color: AppColors.grey400,
                                        size: R.sp(24))
                                    : null,
                              ),
                              SizedBox(width: R.w(16)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product?.name ?? 'Unknown Product',
                                      style: TextStyle(
                                        fontSize: R.sp(16),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: R.h(4)),
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: R.sp(14),
                                        color: AppColors.bodyText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
