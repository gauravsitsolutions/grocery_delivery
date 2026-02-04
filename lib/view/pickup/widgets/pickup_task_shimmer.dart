import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class PickupTaskShimmer extends StatelessWidget {
  const PickupTaskShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Card Shimmer
            Container(
              width: double.infinity,
              height: R.h(350),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(24)),
              ),
            ),
            SizedBox(height: R.h(24)),

            // Item Checklist Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: R.w(150),
                  height: R.h(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(4)),
                  ),
                ),
                Container(
                  width: R.w(60),
                  height: R.h(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(4)),
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(16)),

            // Items Checklist Tiles
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                margin: EdgeInsets.only(bottom: R.h(12)),
                width: double.infinity,
                height: R.h(84),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(30)),
                ),
              ),
            ),
            SizedBox(height: R.h(24)),

            // Pickup Proof Header
            Container(
              width: R.w(120),
              height: R.h(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(4)),
              ),
            ),
            SizedBox(height: R.h(16)),

            // Pickup Proof Placeholder
            Container(
              width: double.infinity,
              height: R.h(140),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(40)),
              ),
            ),
            SizedBox(height: R.h(24)),
          ],
        ),
      ),
    );
  }
}
