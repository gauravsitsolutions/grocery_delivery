import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class WaitingForOrders extends StatelessWidget {
  final bool isOnline;
  final VoidCallback? onToggle;

  const WaitingForOrders({
    super.key,
    required this.isOnline,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: AvatarGlow(
            glowColor: AppColors.primaryGreen,
            duration: const Duration(milliseconds: 2000),
            repeat: isOnline, // Use isOnline to toggle glow
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
        SizedBox(height: R.h(12)),
        Text(
          'Waiting for next order...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: R.sp(18), // Slightly smaller
            fontWeight: FontWeight.w800,
            color: AppColors.headingText,
          ),
        ),
        SizedBox(height: R.h(6)),
        Text(
          isOnline
              ? 'Auto-refresh active. Stay tuned!'
              : 'Go online to start receiving orders.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: R.sp(13), // Slightly smaller
            color: AppColors.bodyText,
          ),
        ),
        if (!isOnline && onToggle != null) ...[
          SizedBox(height: R.h(16)),
          SizedBox(
            width: R.w(180),
            height: R.h(46),
            child: ElevatedButton(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.r(14)),
                ),
                elevation: 0,
              ),
              child: Text(
                'Resume Duty',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: R.sp(16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
