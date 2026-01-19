import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/order_shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: R.w(16),
            vertical: R.h(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. New Header Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Padding(
                  // Matches _dashboardHeader padding in view
                  padding: EdgeInsets.fromLTRB(R.w(4), R.h(6), R.w(4), R.h(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Toggle + Text
                      Row(
                        children: [
                          Container(
                            width: R.w(58),
                            height: R.h(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          SizedBox(width: R.w(12)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: R.w(50),
                                  height: R.h(14),
                                  color: Colors.white),
                              SizedBox(height: R.h(4)),
                              Container(
                                  width: R.w(70),
                                  height: R.h(10),
                                  color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                      // Right: Timer + Notification
                      Row(
                        children: [
                          // Timer Pill (Approx 16+18+6+50+16 width, 10+18+10 height)
                          Container(
                            width: R.w(100),
                            height: R.h(38),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          SizedBox(width: R.w(12)),
                          // Notification
                          Container(
                            width: R.w(40),
                            height: R.w(40),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: R.h(12)),

              // 2. New Request Card Shimmer (Large/Special)
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: R.h(200),
                  // Matches _newRequestCard margin
                  margin: EdgeInsets.symmetric(horizontal: R.w(4)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(24)),
                    border: Border.all(color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: R.h(24)),

              // 3. Section Header items
              _shimmerSectionHeader(),
              SizedBox(height: R.h(12)),
              const OrderShimmer(),

              SizedBox(height: R.h(24)),

              _shimmerSectionHeader(),
              SizedBox(height: R.h(12)),
              const OrderShimmer(),
              const OrderShimmer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerSectionHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.w(4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: R.w(100), height: R.h(16), color: Colors.white),
            Container(width: R.w(60), height: R.h(12), color: Colors.white),
          ],
        ),
      ),
    );
  }
}
