import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class NewRequestCard extends StatelessWidget {
  final Order order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int countdownSeconds;

  const NewRequestCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onDecline,
    this.countdownSeconds = 45, // Default mock value if not provided
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: R.w(4), vertical: R.h(8)),
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: "NEW REQUEST" Badge + Order ID + Timer
          // Using a column on very small screens if needed, but Row is standard here.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: R.w(12), vertical: R.h(6)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // Light Green
                      borderRadius: BorderRadius.circular(R.r(8)),
                    ),
                    child: Text(
                      'NEW REQUEST',
                      style: TextStyle(
                        fontSize: R.sp(12),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: R.w(10)),
                  Text(
                    'ID: #${order.id}', // Using ID as mock order number
                    style: TextStyle(
                      fontSize: R.sp(14),
                      color: AppColors.bodyText.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Timer removed as per request
            ],
          ),

          SizedBox(height: R.h(20)),

          // 2. Main Info: Price vs Distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${(double.tryParse(order.totalAmount) ?? 0.0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: R.sp(32),
                      fontWeight: FontWeight.w800,
                      color: AppColors.headingText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    'Estimated Earnings',
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: AppColors.bodyText.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(RemixIcons.navigation_fill,
                          size: R.sp(16),
                          color: AppColors.bodyText.withValues(alpha: 0.8)),
                      SizedBox(width: R.w(4)),
                      Text(
                        '3.2 km', // Mock distance for now, or pass in
                        style: TextStyle(
                          fontSize: R.sp(18),
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    'Total Distance',
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: AppColors.bodyText.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: R.h(24)),

          // 3. Action Buttons
          Row(
            children: [
              // Decline Button
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: R.h(52),
                  child: ElevatedButton(
                    onPressed: onDecline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F4F9),
                      foregroundColor: const Color(0xFF64748B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(16)),
                      ),
                    ),
                    child: Text(
                      'Decline',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              // Accept Button
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: R.h(52),
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shadowColor:
                          AppColors.primaryGreen.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(16)),
                      ),
                    ),
                    child: Text(
                      'Accept Order',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w700,
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
}
