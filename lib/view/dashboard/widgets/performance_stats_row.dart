import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view/performance/monthly_performance_view.dart';

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
            fontSize: R.sp(18),
            fontWeight: FontWeight.w800,
            color: AppColors.headingText,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: R.h(16)),
        Row(
          children: [
            // Card 1: Completed
            Expanded(
              child: Container(
                padding: EdgeInsets.all(R.w(16)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(R.r(24)), // High radius
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPLETED',
                      style: TextStyle(
                        fontSize: R.sp(11),
                        fontWeight: FontWeight.w700,
                        color: AppColors.bodyText.withValues(alpha: 0.7),
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: R.h(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$completed',
                          style: TextStyle(
                            fontSize: R.sp(28), // Reduced from 36
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingText,
                          ),
                        ),
                        Icon(
                          RemixIcons.checkbox_circle_line,
                          color: AppColors.primaryGreen,
                          size: R.sp(24),
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(8)),
                    Text(
                      '+2 from average', // Mock data as per design request, logic can be added later
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

            SizedBox(width: R.w(16)),

            // Card 2: On-Time
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MonthlyPerformanceView(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      EdgeInsets.fromLTRB(R.w(16), R.w(16), R.w(16), R.w(12)),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(R.r(24)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOGIN TIME',
                        style: TextStyle(
                          fontSize: R.sp(11),
                          fontWeight: FontWeight.w700,
                          color: AppColors.bodyText.withValues(alpha: 0.7),
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: R.h(8)),
                      // Using a Stack for the floating green circle effect if needed,
                      // or just a Row for simplicity first.
                      // Design has a big green circle with refresh icon hanging off the edge?
                      // Simulating the layout with standard Row for now to stay clean.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${loginHours.toStringAsFixed(1)}h', // Show login hours
                              style: TextStyle(
                                fontSize: R.sp(28), // Reduced from 36
                                fontWeight: FontWeight.w800,
                                color: AppColors.headingText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // The design has a large green circle button thing.
                          Container(
                            padding: EdgeInsets.all(R.w(10)),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryGreen, // Bright green
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              RemixIcons.time_line, // Changed to clock icon
                              color: AppColors.white,
                              size: R.sp(20),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: R.h(8)),
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
            ),
          ],
        ),
      ],
    );
  }
}
