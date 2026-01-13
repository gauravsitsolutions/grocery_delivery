import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:avatar_glow/avatar_glow.dart';

class DashboardWaitingState extends StatelessWidget {
  final bool isGoalMet;
  final int completedToday;
  final int dailyGoal;
  final int onTimePercentage;

  const DashboardWaitingState({
    super.key,
    this.isGoalMet = false,
    this.completedToday = 8, // Default value for now
    this.dailyGoal = 12, // Default value for now
    this.onTimePercentage = 95, // Default value
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
        if (isGoalMet)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(R.w(20)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                  Color(0xFF43A047)
                ],
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
                            '$completedToday/$dailyGoal Deliveries completed today',
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
          )
        else
          Container(
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
                      '$completedToday/$dailyGoal',
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
                      widthFactor: (completedToday / dailyGoal).clamp(0.0, 1.0),
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
                      '${dailyGoal - completedToday} more to reach today\'s target',
                      style: TextStyle(
                          fontSize: R.sp(12),
                          fontWeight: FontWeight.w600,
                          color: AppColors.headingText),
                    ),
                    Text(
                      '${dailyGoal > 0 ? ((completedToday / dailyGoal) * 100).toInt() : 0}%',
                      style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen),
                    ),
                  ],
                ),
              ],
            ),
          ),

        SizedBox(height: R.h(40)),

        // 3. Waiting Indicator (Ripple)
        Center(
          child: AvatarGlow(
            glowColor: AppColors.primaryGreen,
            duration: const Duration(milliseconds: 2000),
            repeat: true,
            startDelay: const Duration(milliseconds: 1000),
            glowRadiusFactor: 0.5, // Controls size relative to child
            curve: Curves.easeOutQuad,
            child: Container(
              width: R.w(90),
              height: R.w(90),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(RemixIcons.motorbike_fill,
                  size: R.sp(40), color: AppColors.primaryGreen),
            ),
          ),
        ),
        SizedBox(height: R.h(30)),
        Text(
          'Waiting for next order...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: R.sp(20),
            fontWeight: FontWeight.w800,
            color: AppColors.headingText,
          ),
        ),
        SizedBox(height: R.h(8)),
        Text(
          'Auto-refresh active. Stay tuned!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: R.sp(14),
            color: AppColors.bodyText,
          ),
        ),

        SizedBox(height: R.h(40)),

        // 4. Performance Today
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Performance Today',
            style: TextStyle(
              fontSize: R.sp(18),
              fontWeight: FontWeight.w700,
              color: AppColors.headingText,
            ),
          ),
        ),
        SizedBox(height: R.h(16)),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'COMPLETED',
                value: '$completedToday',
                footer: isGoalMet ? 'Daily Goal Met! ✨' : '+2 from average',
                footerColor: AppColors.primaryGreen,
                icon: RemixIcons.checkbox_circle_line,
              ),
            ),
            SizedBox(width: R.w(16)),
            Expanded(
              child: _buildStatCard(
                label: 'ON-TIME',
                value: '$onTimePercentage%',
                footer: isGoalMet ? 'Perfect Streak' : 'Elite Status',
                footerColor: AppColors.primaryGreen,
                icon: null, // Custom implementation for button
                showButton: true,
              ),
            ),
          ],
        ),
        SizedBox(height: R.h(100)), // Bottom padding
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String footer,
    required Color footerColor,
    IconData? icon,
    bool showButton = false,
  }) {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText.withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: R.h(12)),
              Text(
                value,
                style: TextStyle(
                  fontSize: R.sp(36),
                  fontWeight: FontWeight.w800,
                  color: AppColors.headingText,
                ),
              ),
              SizedBox(height: R.h(12)),
              Text(
                footer,
                style: TextStyle(
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w700,
                  color: footerColor,
                ),
              ),
            ],
          ),
          if (icon != null)
            Positioned(
              right: 0,
              top: R.h(40),
              child: Icon(icon, color: AppColors.primaryGreen, size: R.sp(28)),
            ),
          if (showButton)
            Positioned(
              right: -8,
              bottom: -8,
              child: Container(
                width: R.w(48),
                height: R.w(48),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Icon(RemixIcons.refresh_line,
                    color: AppColors.white, size: R.sp(24)),
              ),
            ),
        ],
      ),
    );
  }
}
