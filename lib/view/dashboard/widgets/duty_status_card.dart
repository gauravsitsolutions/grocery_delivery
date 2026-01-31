import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class DutyStatusCard extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;

  const DutyStatusCard({
    super.key,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle Switch
          Container(
            width: R.w(52),
            height: R.h(32),
            padding: EdgeInsets.all(R.w(4)),
            decoration: BoxDecoration(
              color: isOnline ? const Color(0xFF00C853) : AppColors.softGreyBg,
              borderRadius: BorderRadius.circular(R.r(20)),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  isOnline ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: R.w(24),
                height: R.w(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: isOnline
                    ? Icon(
                        Icons.check,
                        size: R.sp(16),
                        color: const Color(0xFF00C853),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(width: R.w(12)),
          // Text Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.w800,
                  color: AppColors.headingText,
                  height: 1.1,
                ),
              ),
              Text(
                'DUTY MODE',
                style: TextStyle(
                  fontSize: R.sp(10),
                  color: AppColors.bodyText.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
