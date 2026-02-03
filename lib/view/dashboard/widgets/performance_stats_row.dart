import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class PerformanceStatsRow extends StatelessWidget {
  final int pending;
  final int completed;
  final int cancelled;
  final double loginHours;

  const PerformanceStatsRow({
    super.key,
    required this.pending,
    required this.completed,
    required this.cancelled,
    this.loginHours = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Performance Today",
          style: TextStyle(
            fontSize: R.sp(22),
            fontWeight: FontWeight.w900,
            color: AppColors.headingText,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: R.h(20)),
        Row(
          children: [
            // Card 1: Completed
            Expanded(
              child: Container(
                padding:
                    EdgeInsets.fromLTRB(R.w(20), R.w(24), R.w(20), R.w(20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      R.r(45)), // Very high radius as per image
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPLETED',
                      style: TextStyle(
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF71717A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: R.h(12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$completed',
                          style: TextStyle(
                            fontSize: R.sp(42),
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingText,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(R.w(4)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primaryGreen, width: 2),
                          ),
                          child: Icon(
                            Icons.check,
                            color: AppColors.primaryGreen,
                            size: R.sp(18),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(12)),
                    Text(
                      'Great job!',
                      style: TextStyle(
                        fontSize: R.sp(13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: R.w(16)),

            // Card 2: Login Hours
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                    EdgeInsets.fromLTRB(R.w(20), R.w(24), R.w(20), R.w(20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(45)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOGIN HOURS',
                      style: TextStyle(
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF71717A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: R.h(12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${loginHours.toStringAsFixed(1)}h',
                          style: TextStyle(
                            fontSize: R.sp(42),
                            fontWeight: FontWeight.w900,
                            color: AppColors.headingText,
                          ),
                        ),
                        Icon(
                          RemixIcons.time_line,
                          color: AppColors.primaryGreen,
                          size: R.sp(24),
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(12)),
                    Text(
                      'Active Today',
                      style: TextStyle(
                        fontSize: R.sp(13),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
