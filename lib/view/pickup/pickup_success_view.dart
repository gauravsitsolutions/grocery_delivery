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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: R.sp(20)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Pickup Status',
          style: TextStyle(
            color: Colors.black,
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
            Container(
              padding: EdgeInsets.all(R.w(30)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withOpacity(0.1),
              ),
              child: Container(
                padding: EdgeInsets.all(R.w(24)),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen,
                ),
                child: Icon(
                  Remix.check_line,
                  color: Colors.white,
                  size: R.sp(48),
                ),
              ),
            ),
            SizedBox(height: R.h(20)),
            Text(
              'Pickup Complete!',
              style: TextStyle(
                fontSize: R.sp(24),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                          color: const Color(0xFF1F2937),
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
                      color: const Color(0xFF1F2937),
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
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            SizedBox(height: R.h(16)),

            // Next Destination Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      color: Colors.grey[200], // Placeholder color
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
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: R.w(12), vertical: R.h(6)),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7), // Light green
                                borderRadius: BorderRadius.circular(R.r(20)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '8 mins', // Placeholder
                                    style: TextStyle(
                                      fontSize: R.sp(12),
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    '1.2 km', // Placeholder
                                    style: TextStyle(
                                      fontSize: R.sp(10),
                                      color: const Color(0xFF4B5563),
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
                                size: R.sp(14), color: const Color(0xFF6B7280)),
                            SizedBox(width: R.w(4)),
                            Expanded(
                              child: Text(
                                order.deliveryAddress?.addressLine1 ??
                                    'Delivery Address',
                                style: TextStyle(
                                  fontSize: R.sp(14),
                                  color: const Color(0xFF6B7280),
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
                            color: const Color(0xFFF3F4F6),
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
                                    color: Color(0xFF6B7280),
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
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: R.h(16)),

            // View Items List
            TextButton.icon(
              onPressed: () {
                // TODO: Show items bottom sheet or dialog
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
}
