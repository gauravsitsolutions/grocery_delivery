import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class OrderRejectedFeedbackView extends StatelessWidget {
  final int orderId;
  final String reason;

  const OrderRejectedFeedbackView({
    super.key,
    required this.orderId,
    this.reason = 'Vehicle Issue',
  });

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor:
          AppColors.white, // In the image it looks very clean white
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(RemixIcons.close_line, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Feedback',
          style: TextStyle(
            color: AppColors.headingText,
            fontSize: R.sp(18),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.w(24)),
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Rejection Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: R.w(140),
                  height: R.w(140),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: R.w(110),
                  height: R.w(110),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: R.w(80),
                  height: R.w(80),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    RemixIcons.close_line,
                    color: AppColors.error,
                    size: R.sp(44),
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(32)),
            // Title
            Text(
              'Order Rejected',
              style: TextStyle(
                fontSize: R.sp(26),
                fontWeight: FontWeight.w800,
                color: AppColors.headingText,
              ),
            ),
            SizedBox(height: R.h(8)),
            // Order ID
            Text(
              '#ORD-$orderId',
              style: TextStyle(
                fontSize: R.sp(18),
                color: AppColors.bodyText.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: R.h(28)),
            // Reason Pill
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(10)),
              decoration: BoxDecoration(
                color: const Color(0xFF121212), // Very dark black/grey pill
                borderRadius: BorderRadius.circular(R.r(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    RemixIcons.error_warning_fill,
                    color: AppColors.white,
                    size: R.sp(18),
                  ),
                  SizedBox(width: R.w(10)),
                  Text(
                    reason,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: R.sp(15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(36)),
            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(12)),
              child: Text(
                'This order has been returned to the pool.\nYou can now wait for new tasks.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.sp(16),
                  color: AppColors.bodyText.withValues(alpha: 0.8),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(flex: 3),
            // Bottom Button
            Container(
              width: double.infinity,
              height: R.h(60),
              margin: EdgeInsets.only(bottom: R.h(20)),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF00FF66), // Bright neon green from image
                  foregroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(30)),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    fontSize: R.sp(17),
                    fontWeight: FontWeight.w700,
                  ),
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
