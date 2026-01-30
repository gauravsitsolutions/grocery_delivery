import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/widgets/weekly_milestone_card.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/widgets/waiting_for_orders.dart';

class DashboardWaitingState extends StatelessWidget {
  final bool isGoalMet;
  final int completedToday;
  final int dailyGoal;
  final bool isOnline; // Added parameter
  final VoidCallback? onToggle;

  const DashboardWaitingState({
    super.key,
    this.isGoalMet = false,
    this.completedToday = 8, // Default value for now
    this.dailyGoal = 12, // Default value for now
    this.isOnline = true, // Default to true
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Info Banner
        if (!isGoalMet)
          Container(
            padding: EdgeInsets.all(R.w(12)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(R.r(12)),
              border: Border.all(
                  color: AppColors.borderLight.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(R.w(8)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5), // Light Orange
                    shape: BoxShape.circle,
                  ),
                  child: Icon(RemixIcons.information_fill,
                      color: const Color(0xFFFF9800), size: R.sp(18)),
                ),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No new orders found.',
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingText,
                        ),
                      ),
                      Text(
                        'We will notify you as soon as a task is assigned.',
                        style: TextStyle(
                          fontSize: R.sp(12),
                          color: AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (!isGoalMet) SizedBox(height: R.h(20)),

        // 2. Weekly Milestone OR Goal Reached Card
        WeeklyMilestoneCard(
          completed: completedToday,
          goal: dailyGoal,
        ),

        SizedBox(height: R.h(40)),

        // 4. Waiting Indicator (Ripple)
        SizedBox(height: R.h(40)),

        // 4. Waiting Indicator (Ripple)
        WaitingForOrders(
          isOnline: isOnline,
          onToggle: onToggle,
        ),

        SizedBox(height: R.h(30)),

        SizedBox(height: R.h(40)),

        SizedBox(height: R.h(40)), // Bottom padding
      ],
    );
  }
}
