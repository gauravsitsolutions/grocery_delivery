import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';

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
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(24), vertical: R.h(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Rejection Icon
              AvatarGlow(
                startDelay: const Duration(milliseconds: 100),
                glowColor: AppColors.error,
                glowShape: BoxShape.circle,
                animate: true,
                curve: Curves.fastOutSlowIn,
                child: Material(
                  elevation: 8.0,
                  shape: const CircleBorder(),
                  color: AppColors.white,
                  child: Container(
                    width: R.w(100),
                    height: R.w(100),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Container(
                        width: R.w(70),
                        height: R.w(70),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.error),
                        child: Icon(
                          RemixIcons.close_line,
                          color: AppColors.white,
                          size: R.sp(40),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(40)),

              // Title
              Text(
                'Order Rejected',
                style: TextStyle(
                  fontSize: R.sp(28),
                  fontWeight: FontWeight.w800,
                  color: AppColors.headingText,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: R.h(8)),

              // Order ID
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(R.r(8)),
                ),
                child: Text(
                  'Order #$orderId',
                  style: TextStyle(
                    fontSize: R.sp(16),
                    color: AppColors.bodyText.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: R.h(32)),

              // Reason Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(R.w(20)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(R.r(20)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.borderLight.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Reason for Rejection',
                      style: TextStyle(
                        fontSize: R.sp(14),
                        color: AppColors.bodyText.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: R.h(12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          RemixIcons.error_warning_fill,
                          color: AppColors.error,
                          size: R.sp(20),
                        ),
                        SizedBox(width: R.w(8)),
                        Flexible(
                          child: Text(
                            reason,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: R.sp(18),
                              color: AppColors.headingText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.h(32)),

              // Description
              Text(
                'This order has been returned to the pool.\nYou can now look for other available orders.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.sp(15),
                  color: AppColors.bodyText.withValues(alpha: 0.6),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Back Button
              SizedBox(
                width: double.infinity,
                height: R.h(56),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.bottomNav,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(16)),
                    ),
                  ),
                  child: Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(16)),
            ],
          ),
        ),
      ),
    );
  }
}
