import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/order_shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  final bool hasOrders;

  const DashboardShimmer({
    super.key,
    this.hasOrders = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerDutyStatusCard(),
        SizedBox(height: R.h(16)),
        DashboardContentShimmer(hasOrders: hasOrders),
      ],
    );
  }

  Widget _shimmerDutyStatusCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: R.w(4), vertical: R.h(4)),
        height: R.h(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(16)),
        ),
      ),
    );
  }
}

class DashboardContentShimmer extends StatelessWidget {
  final bool hasOrders;

  const DashboardContentShimmer({
    super.key,
    this.hasOrders = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasOrders) {
      // "No Orders" Shimmer - Match Waiting State
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match WeeklyMilestoneCard
          _shimmerMilestoneCard(),
          SizedBox(height: R.h(40)),
          // Match WaitingForOrders pulse/ripple circle
          Center(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: R.w(180),
                height: R.w(180),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(height: R.h(40)),
          _shimmerStatsRow(),
          SizedBox(height: R.h(40)),
        ],
      );
    }

    // "Orders Present" Shimmer - Match Active Dashboard
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmerSectionHeader('Current Task & Delivery'),
        SizedBox(height: R.h(12)),
        const CurrentTaskShimmer(),
        SizedBox(height: R.h(24)),
        _shimmerSectionHeader('New Order Request'),
        SizedBox(height: R.h(12)),
        const OrderShimmer(),
        SizedBox(height: R.h(24)),
        _shimmerSectionHeader('Nearby Available'),
        SizedBox(height: R.h(12)),
        const AvailableOrderShimmer(),
        SizedBox(height: R.h(24)),
        _shimmerStatsRow(),
        SizedBox(height: R.h(40)),
      ],
    );
  }

  Widget _shimmerMilestoneCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: R.h(180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(32)),
        ),
      ),
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
              width: R.w(200), height: R.h(22), color: Colors.white), // Title
          SizedBox(height: R.h(20)),
          Row(
            children: List.generate(2, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      right: index == 1 ? 0 : R.w(16)), // Space between cards
                  height: R.h(140),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        R.r(45)), // Matches performance cards
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _shimmerSectionHeader(String title) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: R.w(200),
        height: R.h(22),
        color: Colors.white,
      ),
    );
  }
}
