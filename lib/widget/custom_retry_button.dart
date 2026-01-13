import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class CustomRetryButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const CustomRetryButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.w(20),
          vertical: R.h(12),
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(R.r(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: R.w(20),
                height: R.w(20),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                RemixIcons.refresh_line,
                color: AppColors.white,
                size: R.sp(20),
              ),
            SizedBox(width: R.w(8)),
            Text(
              'Retry',
              style: TextStyle(
                color: AppColors.white,
                fontSize: R.sp(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
