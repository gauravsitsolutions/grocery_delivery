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
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: R.w(10), vertical: R.h(4)),
                    decoration: BoxDecoration(
                      color: AppColors.badgeGreenBg,
                      borderRadius: BorderRadius.circular(R.r(6)),
                    ),
                    child: Text(
                      'NEW REQUEST',
                      style: TextStyle(
                        fontSize: R.sp(10),
                        fontWeight: FontWeight.w800,
                        color: AppColors.badgeGreenText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(width: R.w(12)),
                  Text(
                    'ID: #${order.id}',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      color: AppColors.bodyText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(24)),
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
                      fontSize: R.sp(36),
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingText,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    'Estimated Earnings',
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: AppColors.bodyText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
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
                          size: R.sp(16), color: AppColors.primaryGreen),
                      SizedBox(width: R.w(4)),
                      Text(
                        '3.2 km', // Mock distance
                        style: TextStyle(
                          fontSize: R.sp(18),
                          fontWeight: FontWeight.w800,
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
                      color: AppColors.bodyText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(28)),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: R.h(56),
                  child: ElevatedButton(
                    onPressed: onDecline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ghostButtonBg,
                      foregroundColor: AppColors.ghostButtonText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(16)),
                      ),
                    ),
                    child: Text(
                      'Decline',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: R.h(56),
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(16)),
                      ),
                      shadowColor:
                          AppColors.primaryGreen.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'Accept Order',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w800,
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
