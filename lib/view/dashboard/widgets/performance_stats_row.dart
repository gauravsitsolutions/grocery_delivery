import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class PerformanceStatsRow extends StatelessWidget {
  final int pending;
  final int completed;
  final int cancelled;
  final double earnings; // Added

  const PerformanceStatsRow({
    super.key,
    required this.pending,
    required this.completed,
    required this.cancelled,
    this.earnings =
        0.0, // Default for backward compatibility if needed, but we'll update call sites
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(R.w(8)),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: AppColors.primaryGreen,
                size: R.sp(18),
              ),
            ),
            SizedBox(width: R.w(8)),
            Text(
              "Today's Performance",
              style: TextStyle(
                fontSize: R.sp(16),
                fontWeight: FontWeight.w700,
                color: AppColors.headingText,
              ),
            ),
          ],
        ),
        SizedBox(height: R.h(12)),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                  child: _statCard(
                      'Earnings',
                      '₹${earnings.toStringAsFixed(0)}',
                      Remix.money_rupee_circle_line)),
              SizedBox(width: R.w(12)),
              Expanded(
                  child: _statCard(
                      'Completed', '$completed', Remix.checkbox_circle_line)),
              SizedBox(width: R.w(12)),
              Expanded(
                  child: _statCard(
                      'Pending',
                      '$pending',
                      Remix
                          .time_line)), // Swapped Pending/Cancelled for space if needed, or just added
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.fromLTRB(R.w(6), R.h(12), R.w(6), R.h(8)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(R.w(8)),
            decoration: BoxDecoration(
              color: AppColors.softGreenBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreen,
              size: R.sp(18),
            ),
          ),
          SizedBox(height: R.h(6)),
          Text(
            value,
            style: TextStyle(
              fontSize: R.sp(20),
              fontWeight: FontWeight.w800,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: R.h(2)),
          Text(
            label,
            style: TextStyle(
              fontSize: R.sp(11),
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
