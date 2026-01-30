import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class WeeklyMilestoneCard extends StatelessWidget {
  final int completed;
  final int goal;

  const WeeklyMilestoneCard({
    super.key,
    required this.completed,
    required this.goal,
  });

  bool get isGoalMet => completed >= goal;

  @override
  Widget build(BuildContext context) {
    if (isGoalMet) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(R.w(20)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(R.r(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Decorations
            Positioned(
                top: -10,
                right: -10,
                child: Icon(Icons.star,
                    color: Colors.white.withValues(alpha: 0.1), size: 60)),
            Positioned(
                bottom: 20,
                left: 20,
                child: Icon(Icons.celebration,
                    color: Colors.white.withValues(alpha: 0.05), size: 80)),

            Column(
              children: [
                // Top Rated Badge
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: R.w(12), vertical: R.h(6)),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(R.r(20)),
                      border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(RemixIcons.vip_crown_fill,
                            size: R.sp(14), color: AppColors.white),
                        SizedBox(width: R.w(4)),
                        Text(
                          'TOP RATED',
                          style: TextStyle(
                            fontSize: R.sp(10),
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Trophy Content
                SizedBox(height: R.h(10)),
                Icon(RemixIcons.trophy_fill,
                    size: R.sp(56),
                    color: const Color(0xFFFFD700)), // Gold trophy
                SizedBox(height: R.h(12)),
                Text(
                  'GOAL REACHED!',
                  style: TextStyle(
                    fontSize: R.sp(24),
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.h(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(12), vertical: R.h(4)),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(R.r(8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RemixIcons.checkbox_circle_fill,
                          size: R.sp(14), color: AppColors.white),
                      SizedBox(width: R.w(6)),
                      Text(
                        '$completed/$goal Deliveries completed today',
                        style: TextStyle(
                          fontSize: R.sp(13),
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: R.h(10)),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(R.w(20)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DAILY GOAL',
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.headingText,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(10), vertical: R.h(4)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(R.r(20)),
                    border: Border.all(color: AppColors.primaryGreen),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RemixIcons.star_fill,
                          size: R.sp(12), color: AppColors.primaryGreen),
                      SizedBox(width: R.w(4)),
                      Text(
                        'ON TRACK',
                        style: TextStyle(
                          fontSize: R.sp(10),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(12)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$completed/$goal',
                  style: TextStyle(
                    fontSize: R.sp(32),
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(width: R.w(8)),
                Text(
                  'Deliveries completed',
                  style: TextStyle(
                    fontSize: R.sp(14),
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(16)),
            // Progress Bar
            Stack(
              children: [
                Container(
                  height: R.h(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(R.r(10)),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor:
                      (goal > 0 ? completed / goal : 0.0).clamp(0.0, 1.0),
                  child: Container(
                    height: R.h(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(R.r(10)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal - completed} more to reach today\'s target',
                  style: TextStyle(
                      fontSize: R.sp(12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.headingText),
                ),
                Text(
                  '${goal > 0 ? ((completed / goal) * 100).toInt() : 0}%',
                  style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
