import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_retry_button.dart';

enum IssueType { internet, server, empty, unauthorized }

class DashboardIssueCard extends StatelessWidget {
  final IssueType type;
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final bool isRetrying;

  const DashboardIssueCard({
    super.key,
    required this.type,
    this.title,
    required this.message,
    this.onRetry,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconBgColor;
    Color iconColor;
    String displayTitle = title ?? '';

    switch (type) {
      case IssueType.internet:
        icon = RemixIcons.wifi_off_line;
        iconBgColor = const Color(0xFFFFEBEE);
        iconColor = const Color(0xFFE53935);
        if (displayTitle.isEmpty) displayTitle = 'No Internet Connection';
        break;
      case IssueType.server:
        icon = RemixIcons.server_line;
        iconBgColor = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFFB8C00);
        if (displayTitle.isEmpty) displayTitle = 'Server Issue';
        break;
      case IssueType.unauthorized:
        icon = RemixIcons.user_forbid_line;
        iconBgColor = const Color(0xFFF3E5F5);
        iconColor = const Color(0xFF8E24AA);
        if (displayTitle.isEmpty) displayTitle = 'Session Expired';
        break;
      case IssueType.empty:
        icon = RemixIcons.inbox_line;
        iconBgColor = const Color(0xFFE8F5E9);
        iconColor = AppColors.primaryGreen;
        if (displayTitle.isEmpty) displayTitle = 'No Information';
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(R.w(16)),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: R.sp(32),
            ),
          ),
          SizedBox(height: R.h(20)),
          Text(
            displayTitle,
            style: TextStyle(
              fontSize: R.sp(20),
              fontWeight: FontWeight.w800,
              color: AppColors.headingText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: R.h(8)),
          Text(
            message,
            style: TextStyle(
              fontSize: R.sp(14),
              fontWeight: FontWeight.w500,
              color: AppColors.bodyText.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: R.h(24)),
            CustomRetryButton(
              onTap: onRetry!,
              isLoading: isRetrying,
            ),
          ],
        ],
      ),
    );
  }
}
