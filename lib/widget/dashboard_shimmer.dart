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
        DashboardContentShimmer(hasOrders: hasOrders),
      ],
    );
  }

  // ... _shimmerDutyStatusCard implementation remains unused or can be deleted ...
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
          // Match Info Banner which appears in Waiting State
          _shimmerInfoBanner(),
          SizedBox(height: R.h(16)), // Margin of banner

          Padding(
            padding: EdgeInsets.only(top: R.h(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Match WeeklyMilestoneCard
                _shimmerMilestoneCard(),
                SizedBox(height: R.h(40)),
                // Match WaitingForOrders pulse/ripple circle
                // Match WaitingForOrders widget
                Center(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      children: [
                        Container(
                          width: R.w(90),
                          height: R.w(90),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(height: R.h(30)),
                        Container(
                            width: R.w(220),
                            height: R.h(24),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(R.r(4)))),
                        SizedBox(height: R.h(8)),
                        Container(
                            width: R.w(180),
                            height: R.h(14),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(R.r(4)))),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: R.h(40)),
              ],
            ),
          ),
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
        height: R.h(160), // Matched to ~156
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(24)), // Matched
        ),
      ),
    );
  }

  Widget _shimmerInfoBanner() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: R.h(80),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(12)),
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
