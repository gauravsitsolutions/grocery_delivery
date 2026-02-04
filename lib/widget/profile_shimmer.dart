import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        R.w(16),
        R.h(16),
        R.w(16),
        R.h(24),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            // Header Shimmer
            Center(
              child: Column(
                children: [
                  Container(
                    width: R.w(104),
                    height: R.w(104),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: R.h(16)),
                  Container(
                      width: R.w(150), height: R.h(20), color: Colors.white),
                  SizedBox(height: R.h(8)),
                  Container(
                      width: R.w(100), height: R.h(14), color: Colors.white),
                ],
              ),
            ),
            SizedBox(height: R.h(28)),

            SizedBox(height: R.h(28)),
            // Stats Row Shimmer
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: R.h(80),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(16)),
                    ),
                  ),
                ),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Container(
                    height: R.h(80),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(R.r(16)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(24)),

            // Graph / Container Shimmer
            Container(
              height: R.h(200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(24)),
              ),
            ),
            SizedBox(height: R.h(32)),

            // Info Section Shimmer
            _shimmerSection(),
            SizedBox(height: R.h(28)),
            _shimmerSection(),
          ],
        ),
      ),
    );
  }

  Widget _shimmerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: R.w(120), height: R.h(18), color: Colors.white),
        SizedBox(height: R.h(16)),
        ...List.generate(
            3,
            (index) => Padding(
                  padding: EdgeInsets.only(bottom: R.h(12)),
                  child: Row(
                    children: [
                      Container(
                          width: R.w(24), height: R.w(24), color: Colors.white),
                      SizedBox(width: R.w(12)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: R.w(100),
                              height: R.h(12),
                              color: Colors.white),
                          SizedBox(height: R.h(4)),
                          Container(
                              width: R.w(140),
                              height: R.h(14),
                              color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                )),
      ],
    );
  }
}
