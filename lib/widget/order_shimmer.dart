import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

// Default Shimmer for NewRequestCard
class OrderShimmer extends StatelessWidget {
  const OrderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: R.w(4), vertical: R.h(8)),
        padding: EdgeInsets.all(R.w(20)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(32)),
        ),
        child: Column(
          children: [
            // Top Row (ID & Timer)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: R.w(80), height: R.h(14), color: Colors.white),
                Container(width: R.w(40), height: R.h(14), color: Colors.white),
              ],
            ),
            SizedBox(height: R.h(20)),
            // Middle section (Earnings & Distance)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: R.w(100), height: R.h(32), color: Colors.white),
                    SizedBox(height: R.h(4)),
                    Container(
                        width: R.w(120), height: R.h(12), color: Colors.white),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        width: R.w(80), height: R.h(18), color: Colors.white),
                    SizedBox(height: R.h(4)),
                    Container(
                        width: R.w(100), height: R.h(12), color: Colors.white),
                  ],
                ),
              ],
            ),
            SizedBox(height: R.h(24)),
            // Bottom Action buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: R.h(56),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(16)),
                    ),
                  ),
                ),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Container(
                    height: R.h(56),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(16)),
                    ),
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

// Shimmer for CurrentTaskCard
class CurrentTaskShimmer extends StatelessWidget {
  const CurrentTaskShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(16)),
        padding: EdgeInsets.all(R.w(16)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(16)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: R.w(50),
                  height: R.w(50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(8)),
                  ),
                ),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: R.w(150),
                          height: R.h(18),
                          color: Colors.white),
                      SizedBox(height: R.h(8)),
                      Container(
                          width: R.w(100),
                          height: R.h(14),
                          color: Colors.white),
                    ],
                  ),
                ),
                Container(width: R.w(60), height: R.h(18), color: Colors.white),
              ],
            ),
            SizedBox(height: R.h(16)),
            Container(
              height: R.h(60),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(12)),
              ),
            ),
            SizedBox(height: R.h(16)),
            Container(
              height: R.h(56),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer for AvailableOrderItem
class AvailableOrderShimmer extends StatelessWidget {
  const AvailableOrderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(12)),
        padding: EdgeInsets.all(R.w(16)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(24)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: R.w(140), height: R.h(17), color: Colors.white),
                  SizedBox(height: R.h(8)),
                  Container(
                      width: R.w(180), height: R.h(14), color: Colors.white),
                  SizedBox(height: R.h(12)),
                  Row(
                    children: [
                      Container(
                          width: R.w(80),
                          height: R.h(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(R.r(8)),
                          )),
                      SizedBox(width: R.w(8)),
                      Container(
                          width: R.w(80),
                          height: R.h(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(R.r(8)),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: R.w(16)),
            Container(
              width: R.w(70),
              height: R.h(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer for MyQueueItem
class MyQueueShimmer extends StatelessWidget {
  const MyQueueShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(12)),
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: R.w(46), // Approx 22 + 12*2 padding
              height: R.w(46),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: R.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: R.w(140), height: R.h(17), color: Colors.white),
                  SizedBox(height: R.h(8)),
                  Container(
                      width: R.w(100), height: R.h(13), color: Colors.white),
                ],
              ),
            ),
            Container(
              width: R.w(50),
              height: R.h(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListShimmer extends StatelessWidget {
  final int count;
  const ListShimmer({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => const OrderShimmer(),
    );
  }
}
