import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class PerformanceStatsRow extends StatelessWidget {
  final int pending;
  final int completed;
  final int cancelled;

  const PerformanceStatsRow({
    super.key,
    required this.pending,
    required this.completed,
    required this.cancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Performance",
          style: TextStyle(
            fontSize: R.sp(16),
            fontWeight: FontWeight.w800,
            color: AppColors.headingText,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: R.h(12)),
        Row(
          children: [
            Expanded(child: _statCard('Pending', pending, Colors.orange)),
            SizedBox(width: R.w(12)),
            Expanded(
                child:
                    _statCard('Completed', completed, AppColors.primaryGreen)),
            SizedBox(width: R.w(12)),
            Expanded(child: _statCard('Cancelled', cancelled, AppColors.error)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, int count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: R.h(12), horizontal: R.w(8)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: R.sp(20),
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: R.h(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: R.sp(12),
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
