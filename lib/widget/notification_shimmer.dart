import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key});

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
          borderRadius: BorderRadius.circular(R.r(20)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: R.r(26),
              backgroundColor: Colors.white,
            ),
            SizedBox(width: R.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: R.h(14),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: R.w(20)),
                      Container(
                        width: R.w(40),
                        height: R.h(12),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(8)),
                  Container(
                    width: double.infinity,
                    height: R.h(14),
                    color: Colors.white,
                  ),
                  SizedBox(height: R.h(4)),
                  Container(
                    width: R.w(150),
                    height: R.h(14),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(width: R.w(12)),
            Container(
              width: R.w(20),
              height: R.w(20),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationListShimmer extends StatelessWidget {
  final int count;
  const NotificationListShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(R.w(16)),
      itemCount: count,
      itemBuilder: (context, index) => const NotificationShimmer(),
    );
  }
}
