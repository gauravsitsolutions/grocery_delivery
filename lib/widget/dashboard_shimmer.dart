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
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: R.w(16),
            vertical: R.h(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerHeader(),
              _shimmerDutyStatusCard(),
              SizedBox(height: R.h(16)),
              const DashboardContentShimmer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: EdgeInsets.fromLTRB(R.w(4), R.h(6), R.w(4), R.h(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Profile + Greeting
            Row(
              children: [
                Container(
                  width: R.w(44), // Profile radius * 2
                  height: R.w(44),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: R.w(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: R.w(80), height: R.h(12), color: Colors.white),
                    SizedBox(height: R.h(4)),
                    Container(
                        width: R.w(120), height: R.h(18), color: Colors.white),
                  ],
                ),
              ],
            ),
            // Right: Notification Bubble
            Container(
              width: R.w(42),
              height: R.w(42),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerDutyStatusCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: R.w(4), vertical: R.h(4)),
        height: R.h(60), // Approx height of DutyStatusCard
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(16)),
        ),
      ),
    );
  }
}

class DashboardContentShimmer extends StatelessWidget {
  const DashboardContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerStatsRow(),
        SizedBox(height: R.h(24)),
        _shimmerSectionHeader(),
        SizedBox(height: R.h(12)),
        _shimmerLargeCard(),
        SizedBox(height: R.h(24)),
        _shimmerSectionHeader(),
        SizedBox(height: R.h(12)),
        const OrderShimmer(),
        const OrderShimmer(),
      ],
    );
  }

  Widget _shimmerStatsRow() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: R.w(160), height: R.h(20), color: Colors.white), // Title
          SizedBox(height: R.h(16)),
          Row(
            children: List.generate(2, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      right: index == 1 ? 0 : R.w(16)), // Space between cards
                  height: R.h(120), // Approx height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(24)),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLargeCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: R.h(220),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(24)),
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
            Container(width: R.w(120), height: R.h(18), color: Colors.white),
            Container(width: R.w(60), height: R.h(14), color: Colors.white),
          ],
        ),
      ),
    );
  }
}
