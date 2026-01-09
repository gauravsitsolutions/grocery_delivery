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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: R.w(16),
            vertical: R.h(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Header Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: R.r(22), backgroundColor: Colors.white),
                    SizedBox(width: R.w(12)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: R.w(60),
                            height: R.h(10),
                            color: Colors.white),
                        SizedBox(height: R.h(6)),
                        Container(
                            width: R.w(120),
                            height: R.h(18),
                            color: Colors.white),
                      ],
                    ),
                    const Spacer(),
                    Container(
                        width: R.w(50), height: R.h(24), color: Colors.white),
                  ],
                ),
              ),
              SizedBox(height: R.h(24)),

              // Current Task / New Order Header Shimmer
              _shimmerHeader(),
              SizedBox(height: R.h(12)),
              const OrderShimmer(),

              SizedBox(height: R.h(24)),

              // Queue Header Shimmer
              _shimmerHeader(),
              SizedBox(height: R.h(12)),
              const OrderShimmer(),

              SizedBox(height: R.h(24)),

              // Available Header Shimmer
              _shimmerHeader(),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: R.w(120), height: R.h(18), color: Colors.white),
          Container(width: R.w(60), height: R.h(14), color: Colors.white),
        ],
      ),
    );
  }
}
