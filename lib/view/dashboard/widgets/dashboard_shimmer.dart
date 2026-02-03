import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Shimmer
            Row(
              children: [
                _buildShimmerCircle(size: R.w(50)),
                SizedBox(width: R.w(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerContainer(height: R.h(16), width: R.w(120)),
                    SizedBox(height: R.h(8)),
                    _buildShimmerContainer(height: R.h(12), width: R.w(80)),
                  ],
                ),
                const Spacer(),
                _buildShimmerContainer(
                    height: R.h(40), width: R.w(100), borderRadius: R.r(20)),
              ],
            ),

            SizedBox(height: R.h(24)),

            // 2. Current Task Placeholder (Matched to _currentTaskCard)
            _buildShimmerContainer(
              height: R.h(180),
              width: double.infinity,
              borderRadius: R.r(20),
            ),

            SizedBox(height: R.h(32)),

            // 3. Section Header Placeholder ("My Queue")
            _buildShimmerContainer(height: R.h(20), width: R.w(150)),
            SizedBox(height: R.h(16)),

            // 4. Queue Item Placeholders
            Column(
              children: List.generate(
                  2,
                  (index) => Padding(
                        padding: EdgeInsets.only(bottom: R.h(12)),
                        child: _buildShimmerContainer(
                          height: R.h(100),
                          width: double.infinity,
                          borderRadius: R.r(16),
                        ),
                      )),
            ),

            SizedBox(height: R.h(32)),

            // 5. Performance Today Section Placeholder
            _buildShimmerContainer(height: R.h(28), width: R.w(180)),
            SizedBox(height: R.h(20)),
            Row(
              children: [
                Expanded(
                  child: _buildShimmerContainer(
                    height: R.h(160),
                    width: double.infinity,
                    borderRadius: R.r(45),
                  ),
                ),
                SizedBox(width: R.w(16)),
                Expanded(
                  child: _buildShimmerContainer(
                    height: R.h(160),
                    width: double.infinity,
                    borderRadius: R.r(45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer({
    required double height,
    required double width,
    double borderRadius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  Widget _buildShimmerCircle({required double size}) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: size,
        width: size,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
