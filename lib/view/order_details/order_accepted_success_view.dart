import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view/pickup/pickup_task_view.dart';
import 'package:animations/animations.dart';

class OrderAcceptedSuccessView extends StatefulWidget {
  final Order order;

  const OrderAcceptedSuccessView({super.key, required this.order});

  @override
  State<OrderAcceptedSuccessView> createState() =>
      _OrderAcceptedSuccessViewState();
}

class _OrderAcceptedSuccessViewState extends State<OrderAcceptedSuccessView> {
  @override
  void initState() {
    super.initState();
    // Auto-redirect after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToPickup();
      }
    });
  }

  void _navigateToPickup() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PickupTaskView(
          orderId: widget.order.id,
          orderNumber: widget.order.orderNumber,
          order: widget.order,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
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
                  'Order Accepted!',
                  style: TextStyle(
                    fontSize: R.sp(28),
                    fontWeight: FontWeight.w900,
                    color: AppColors.headingText,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: R.h(12)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(16), vertical: R.h(6)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(R.r(20)),
                  ),
                  child: Text(
                    '#${widget.order.orderNumber}',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                SizedBox(height: R.h(16)),
                Text(
                  'Heading to the store for pickup.',
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Order Card
            Container(
              margin: EdgeInsets.symmetric(horizontal: R.w(24)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(R.w(24)),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(R.w(12)),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Remix.store_2_fill,
                            size: R.sp(24),
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        SizedBox(width: R.w(16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.order.vendor?.storeName ?? "Warehouse",
                                style: TextStyle(
                                  fontSize: R.sp(18),
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.headingText,
                                ),
                              ),
                              SizedBox(height: R.h(4)),
                              Text(
                                "PICKUP POINT",
                                style: TextStyle(
                                  fontSize: R.sp(11),
                                  fontWeight: FontWeight.w700,
                                  color:
                                      AppColors.bodyText.withValues(alpha: 0.5),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Map Placeholder (Simulation)
                  Padding(
                    padding: EdgeInsets.fromLTRB(R.w(12), 0, R.w(12), R.w(12)),
                    child: Container(
                      height: R.h(160),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(R.r(24)),
                        color: Colors.grey[100],
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=800',
                          ),
                          fit: BoxFit.cover,
                          opacity: 0.6,
                        ),
                      ),
                      child: Center(
                        child: CircleAvatar(
                          radius: R.r(24),
                          backgroundColor: Colors.white,
                          child: Icon(
                            Remix.map_pin_user_fill,
                            color: AppColors.primaryGreen,
                            size: R.sp(24),
                          ),
                        ),
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: R.h(56),
                    child: ElevatedButton(
                      onPressed: _navigateToPickup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.r(28)),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Go to Pickup',
                            style: TextStyle(
                              fontSize: R.sp(16),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: R.w(8)),
                          Icon(Remix.arrow_right_line, size: R.sp(18)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: R.h(16)),
                  TextButton(
                    onPressed: () {
                      // Just close the success view and go back to dashboard
                      // or stay if it's already there.
                      // For now, let's just pop to show interest in details.
                      Navigator.pop(context);
                    },
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: R.sp(15),
                        fontWeight: FontWeight.w700,
                        color: AppColors.bodyText.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(24)),
          ],
        ),
      ),
    );
  }
}
