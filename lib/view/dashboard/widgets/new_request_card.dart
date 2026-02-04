import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class NewRequestCard extends StatefulWidget {
  final Order order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int countdownSeconds;

  const NewRequestCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onDecline,
    this.countdownSeconds = 45,
  });

  @override
  State<NewRequestCard> createState() => _NewRequestCardState();
}

class _NewRequestCardState extends State<NewRequestCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header Row (Title + Timer) - Outside the card

        // 2. The Card
        Container(
          margin: EdgeInsets.symmetric(horizontal: R.w(4)),
          padding: EdgeInsets.all(R.w(16)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(R.r(24)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
                color: AppColors.borderLight.withValues(alpha: 0.5), width: 1),
          ),
          child: Column(
            children: [
              // Top Section: Vendor Info & Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Logo
                  Container(
                    width: R.w(56),
                    height: R.w(56),
                    decoration: BoxDecoration(
                      color: AppColors.softGreyBg,
                      borderRadius: BorderRadius.circular(R.r(12)),
                      image: widget.order.vendor?.id != null
                          // We don't have a logo field in Vendor, so we use a placeholder or icon
                          // Wait, the error said 'logo' isn't defined for type 'Vendor'.
                          // Checking OrderModel, Vendor class has id, storeName, address, mobile. NO LOGO.
                          // I will use a placeholder icon.
                          ? null
                          : null,
                    ),
                    child: Icon(RemixIcons.store_2_fill,
                        color: AppColors.bodyText.withValues(alpha: 0.3),
                        size: R.sp(24)),
                  ),
                  SizedBox(width: R.w(16)),

                  // Vendor Name & Distance
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order.vendor?.storeName ?? 'Fresh Mart',
                          style: TextStyle(
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: R.h(4)),
                        Row(
                          children: [
                            Icon(RemixIcons.map_pin_fill,
                                size: R.sp(14),
                                color:
                                    AppColors.bodyText.withValues(alpha: 0.5)),
                            SizedBox(width: R.w(4)),
                            Text(
                              '${widget.order.distance ?? "2.5"} km away',
                              style: TextStyle(
                                fontSize: R.sp(12),
                                color:
                                    AppColors.bodyText.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price & Items
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${(double.tryParse(widget.order.totalAmount) ?? 0.0).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: R.sp(18),
                          fontWeight: FontWeight.w900,
                          color: AppColors.headingText,
                        ),
                      ),
                      SizedBox(height: R.h(4)),
                      Text(
                        '${widget.order.orderItems.length} items',
                        style: TextStyle(
                          fontSize: R.sp(12),
                          color: AppColors.bodyText.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: R.h(24)),

              // Bottom Section: Buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onDecline,
                      child: Container(
                        height: R.h(50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.ghostButtonBg,
                          borderRadius: BorderRadius.circular(R.r(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(RemixIcons.close_line,
                                size: R.sp(18),
                                color: AppColors.headingText
                                    .withValues(alpha: 0.8)),
                            SizedBox(width: R.w(8)),
                            Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: R.sp(14),
                                fontWeight: FontWeight.w700,
                                color: AppColors.headingText
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: R.w(16)),
                  Expanded(
                    child: GestureDetector(
                      onTap: widget.onAccept,
                      child: Container(
                        height: R.h(50),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(R.r(16)),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryGreen.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(RemixIcons.check_line,
                                size: R.sp(18), color: Colors.white),
                            SizedBox(width: R.w(8)),
                            Text(
                              'Accept',
                              style: TextStyle(
                                fontSize: R.sp(14),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
