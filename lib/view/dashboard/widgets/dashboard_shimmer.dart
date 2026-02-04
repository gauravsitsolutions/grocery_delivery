import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/order_shimmer.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';

class DashboardShimmer extends StatelessWidget {
  final bool hasOrders;
  final bool showCurrentTask;
  final bool showQueue;
  final bool showNewRequests;
  final bool showAvailableOrders;

  const DashboardShimmer({
    super.key,
    this.hasOrders = true,
    this.showCurrentTask = true,
    this.showQueue = true,
    this.showNewRequests = true,
    this.showAvailableOrders = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DashboardContentShimmer(
        hasOrders: hasOrders,
        showCurrentTask: showCurrentTask,
        showQueue: showQueue,
        showNewRequests: showNewRequests,
        showAvailableOrders: showAvailableOrders,
      ),
    );
  }
}

class DashboardContentShimmer extends StatelessWidget {
  final bool hasOrders;
  final bool showCurrentTask;
  final bool showQueue;
  final bool showNewRequests;
  final bool showAvailableOrders;

  const DashboardContentShimmer({
    super.key,
    this.hasOrders = true,
    this.showCurrentTask = true,
    this.showQueue = true,
    this.showNewRequests = true,
    this.showAvailableOrders = true,
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
          // Add Performance Stats - always shown
          _shimmerStatsRow(),
          SizedBox(height: R.h(40)),
        ],
      );
    }

    // "Orders Present" Shimmer - Match Active Dashboard
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // New Requests Section
        if (showNewRequests) ...[
          _shimmerSectionHeader('New Order Request'),
          SizedBox(height: R.h(12)),
          const OrderShimmer(), // 1st Card
          SizedBox(height: R.h(12)),
          const OrderShimmer(), // 2nd Card (User requested "two")
          SizedBox(height: R.h(24)),
        ],

        // My Queue Section (Includes Current Task)
        if (showCurrentTask || showQueue) ...[
          _shimmerSectionHeader('My Queue'),
          SizedBox(height: R.h(12)),
          const MyQueueShimmer(),
          SizedBox(height: R.h(12)),
          // Always show at least two shimmer items if queue is present
          const MyQueueShimmer(),
          SizedBox(height: R.h(24)),
        ],

        // Available Orders Section
        if (showAvailableOrders) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerSectionHeader('Available Orders'),
              Container(
                  width: R.w(60),
                  height: R.h(16),
                  color: Colors.white), // View All
            ],
          ),
          SizedBox(height: R.h(12)),
          const AvailableOrderShimmer(),
          SizedBox(height: R.h(12)),
          const AvailableOrderShimmer(),
          SizedBox(height: R.h(24)),
        ],

        // Performance Stats
        _shimmerStatsRow(),
        SizedBox(height: R.h(40)),
      ],
    );
  }

  Widget _shimmerMilestoneCard() {
    return Container(
      width: double.infinity,
      height: R.h(160),
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row (Goal Label + Badge)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: R.w(80), height: R.h(12), color: Colors.white),
                Container(
                    width: R.w(70),
                    height: R.h(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(R.r(20)))),
              ],
            ),
            SizedBox(height: R.h(12)),
            // Big Counter Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(width: R.w(60), height: R.h(32), color: Colors.white),
                SizedBox(width: R.w(8)),
                Container(
                    width: R.w(120), height: R.h(14), color: Colors.white),
              ],
            ),
            SizedBox(height: R.h(16)),
            // Progress Bar
            Container(
                width: double.infinity,
                height: R.h(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(10)))),
            SizedBox(height: R.h(12)),
            // Bottom Row (Remaining + %)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: R.w(150), height: R.h(12), color: Colors.white),
                Container(width: R.w(30), height: R.h(12), color: Colors.white),
              ],
            )
          ],
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
          // Shimmer placeholder for "Performance Today" title
          Container(width: R.w(200), height: R.h(22), color: Colors.white),
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

class DashboardHeaderShimmer extends StatelessWidget {
  const DashboardHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(24)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Duty Status Card Shimmer (Left)
            Container(
              width: R.w(140),
              height: R.h(46), // Approx height of duty card
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(100)),
              ),
            ),

            // Right Side (Timer + Notification)
            Row(
              children: [
                // Timer Shimmer
                Container(
                  width: R.w(100),
                  height: R.h(36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(100)),
                  ),
                ),
                SizedBox(width: R.w(8)),
                // Notification Icon Shimmer
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
          ],
        ),
      ),
    );
  }
}
