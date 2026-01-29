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
              SizedBox(height: R.h(12)),
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
        padding: EdgeInsets.fromLTRB(R.w(4), R.h(6), R.w(4), R.h(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: R.w(58),
                  height: R.h(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                SizedBox(width: R.w(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: R.w(50), height: R.h(14), color: Colors.white),
                    SizedBox(height: R.h(4)),
                    Container(
                        width: R.w(70), height: R.h(10), color: Colors.white),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: R.w(100),
                  height: R.h(38),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                SizedBox(width: R.w(12)),
                Container(
                  width: R.w(40),
                  height: R.w(40),
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

  Widget _shimmerStatsRow() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: R.w(34),
                height: R.w(34),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: R.w(8)),
              Container(width: R.w(140), height: R.h(16), color: Colors.white),
            ],
          ),
          SizedBox(height: R.h(12)),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == 2 ? 0 : R.w(12)),
                  height: R.h(100),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(16)),
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
