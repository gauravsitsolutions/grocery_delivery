import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class OrderShimmer extends StatelessWidget {
  const OrderShimmer({super.key});

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
          borderRadius: BorderRadius.circular(R.r(18)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: R.w(40),
                  width: R.w(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(10)),
                  ),
                ),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: R.h(14),
                        color: Colors.white,
                      ),
                      SizedBox(height: R.h(8)),
                      Container(
                        width: R.w(100),
                        height: R.h(14),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: R.w(12)),
                Container(
                  width: R.w(50),
                  height: R.h(16),
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: R.h(16)),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: R.h(45),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                  ),
                ),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Container(
                    height: R.h(45),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(12)),
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
