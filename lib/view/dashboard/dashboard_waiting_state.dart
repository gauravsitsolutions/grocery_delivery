import 'package:flutter/material.dart';
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
        // 1. Weekly Milestone (Non-clickable)
        WeeklyMilestoneCard(
          completed: completedToday,
          goal: dailyGoal,
        ),

        SizedBox(height: R.h(16)),

        // 2. Waiting Indicator (Ripple)
        WaitingForOrders(
          isOnline: isOnline,
          onToggle: onToggle,
        ),

        SizedBox(height: R.h(16)), // Bottom padding
      ],
    );
  }
}
