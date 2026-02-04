import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class PerformanceStatsRow extends StatelessWidget {
  final int pending;
  final int completed;
  final int cancelled;
  final double loginHours;
  final int? dailyGoal;

  const PerformanceStatsRow({
    super.key,
    required this.pending,
    required this.completed,
    required this.cancelled,
    this.loginHours = 0.0,
    this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Performance Today",
          style: TextStyle(
            fontSize: R.sp(20), // Slightly smaller
            fontWeight: FontWeight.w900,
            color: AppColors.headingText,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: R.h(16)), // Reduced from 20
        Row(
          children: [
            // Card 1: Completed
            Expanded(
              child: Container(
                padding: EdgeInsets.all(R.w(16)), // Tightened padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(24)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPLETED',
                      style: TextStyle(
                        fontSize: R.sp(12),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF71717A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: R.h(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              completed.toString(),
                              style: TextStyle(
                                fontSize: R.sp(32),
                                fontWeight: FontWeight.w900,
                                color: AppColors.headingText,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: R.w(8)),
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
                            size: R.sp(16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      'Great job!',
                      style: TextStyle(
                        fontSize: R.sp(11),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: R.w(12)),

            // Card 2: Login Hours
            Expanded(
              child: Container(
                padding: EdgeInsets.all(R.w(16)), // Tightened padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(24)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOGIN HOURS',
                      style: TextStyle(
                        fontSize: R.sp(12),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF71717A),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: R.h(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${loginHours.toStringAsFixed(1)}h',
                              style: TextStyle(
                                fontSize: R.sp(32),
                                fontWeight: FontWeight.w900,
                                color: AppColors.headingText,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: R.w(8)),
                        Icon(
                          RemixIcons.time_line,
                          color: AppColors.primaryGreen,
                          size: R.sp(20),
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      'Active Today',
                      style: TextStyle(
                        fontSize: R.sp(11),
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
