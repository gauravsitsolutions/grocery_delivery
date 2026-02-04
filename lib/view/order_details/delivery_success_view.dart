import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/agent_bottom_nav_item.dart';
import 'package:animations/animations.dart';

class DeliverySuccessView extends StatelessWidget {
  final Order order;

  const DeliverySuccessView({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Header Section with Animated Check
            Column(
              children: [
                AvatarGlow(
                  glowColor: AppColors.primaryGreen,
                  glowRadiusFactor: 0.4,
                  duration: const Duration(milliseconds: 2000),
                  repeat: true,
                  child: Container(
                    width: R.w(100),
                    height: R.w(100),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x4010C971),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: R.w(50),
                        height: R.w(50),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Remix.check_line,
                          color: AppColors.primaryGreen,
                          size: R.sp(32),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: R.h(32)),
                Text(
                  'Delivery Successful!',
                  style: TextStyle(
                    fontSize: R.sp(24),
                    fontWeight: FontWeight.w800,
                    color: AppColors.headingText,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: R.h(8)),
                Text(
                  'Great job!',
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w500,
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Order Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: R.w(24)),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(R.r(24)),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(R.w(24)),
                    child: Column(
                      children: [
                        Text(
                          'COMPLETED TASK',
                          style: TextStyle(
                            fontSize: R.sp(11),
                            fontWeight: FontWeight.w700,
                            color: AppColors.bodyText.withValues(alpha: 0.5),
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: R.h(8)),
                        Text(
                          'Order #${order.orderNumber}',
                          style: TextStyle(
                            fontSize: R.sp(20),
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingText,
                          ),
                        ),
                        if (order.user != null) ...[
                          SizedBox(height: R.h(12)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Remix.user_smile_fill,
                                size: R.sp(16),
                                color: AppColors.bodyText,
                              ),
                              SizedBox(width: R.w(6)),
                              Text(
                                order.user!.fullName,
                                style: TextStyle(
                                  fontSize: R.sp(14),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.bodyText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                  // Map Placeholder (Simulation)
                  Container(
                    height: R.h(120),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(R.r(23))),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/map_placeholder.png'),
                        fit: BoxFit.cover,
                        opacity: 0.1,
                      ),
                      color: Colors.grey[50],
                    ),
                    child: Center(
                      child: Icon(
                        Remix.map_pin_time_line,
                        color: Colors.grey[400],
                        size: R.sp(32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),

            // Bottom Action
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(24)),
              child: SizedBox(
                width: double.infinity,
                height: R.h(48),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AgentBottomNavView(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.headingText, // Dark button
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(16)),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next Order',
                        style: TextStyle(
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: R.w(8)),
                      Icon(Remix.arrow_right_line, size: R.sp(18)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: R.h(8)),
            Text(
              'Scanning for available tasks...',
              style: TextStyle(
                fontSize: R.sp(12),
                color: AppColors.bodyText.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: R.h(12)),
          ],
        ),
      ),
    );
  }
}
