import 'package:flutter/cupertino.dart';
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: R.w(20),
        vertical: R.h(16),
      ),
      decoration: BoxDecoration(
        // Use a pale green for online, light grey or white for offline
        color: isOnline ? const Color(0xFFE8F5E9) : AppColors.white,
        borderRadius:
            BorderRadius.circular(R.r(40)), // High radius for pill shape
        border: Border.all(
          color: isOnline
              ? AppColors.primaryGreen.withValues(alpha: 0.2)
              : AppColors.borderLight,
        ),
        boxShadow: [
          if (!isOnline)
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Use a dot indicator
              Container(
                width: R.w(8),
                height: R.w(8),
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0xFF00C853) : AppColors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: R.w(10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${isOnline ? 'Online' : 'Offline'}',
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingText,
                    ),
                  ),
                  Text(
                    isOnline
                        ? 'Ready for delivery'
                        : 'You are offline', // Matching design
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: isOnline
                          ? AppColors.primaryGreen
                          : AppColors.bodyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Custom Cupertino Switch for the premium toggle look
          Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: isOnline,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
