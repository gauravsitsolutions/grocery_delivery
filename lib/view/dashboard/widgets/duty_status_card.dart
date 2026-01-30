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
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.w(6),
          vertical: R.h(6),
        ),
        decoration: BoxDecoration(
          color: isOnline ? const Color(0xFF00C853) : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(R.r(100)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(R.w(4)),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: isOnline
                  ? Icon(
                      Icons.check,
                      size: R.sp(14),
                      color: const Color(0xFF00C853),
                    )
                  : SizedBox(
                      width: R.w(14),
                      height: R.w(14),
                    ),
            ),
            SizedBox(width: R.w(8)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w800,
                    color: isOnline ? Colors.white : AppColors.headingText,
                    height: 1.1,
                  ),
                ),
                Text(
                  'DUTY MODE',
                  style: TextStyle(
                    fontSize: R.sp(8),
                    color: isOnline
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.bodyText,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(width: R.w(10)),
          ],
        ),
      ),
    );
  }
}
