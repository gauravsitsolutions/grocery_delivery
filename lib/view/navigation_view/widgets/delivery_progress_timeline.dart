import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class DeliveryProgressTimeline extends StatelessWidget {
  final String pickedUpTime;
  final bool isReachedLocation;

  const DeliveryProgressTimeline({
    super.key,
    required this.pickedUpTime,
    this.isReachedLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.w(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            icon: Icons.check_circle,
            iconColor: Colors.green.withValues(alpha: 0.2),
            innerIconColor: Colors.green,
            title: 'Order Picked Up',
            subtitle: pickedUpTime,
            isCompleted: true,
            showLine: true,
          ),
          _buildTimelineItem(
            icon: Icons.local_shipping,
            iconColor: isReachedLocation
                ? Colors.green.withValues(alpha: 0.2)
                : const Color(0xFF00FF85).withValues(alpha: 0.2),
            innerIconColor:
                isReachedLocation ? Colors.green : const Color(0xFF00FF85),
            title: 'Reached Location',
            subtitle: isReachedLocation ? 'Arrived' : 'Pending Confirmation',
            subtitleColor: isReachedLocation ? Colors.green : Colors.green[600],
            isCompleted: isReachedLocation,
            showLine: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required Color innerIconColor,
    required String title,
    required String subtitle,
    Color? subtitleColor,
    required bool isCompleted,
    required bool showLine,
    bool isLast = false,
  }) {
    return SizedBox(
      height: isLast ? null : R.h(70),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: R.w(40),
                height: R.w(40),
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: innerIconColor, size: R.sp(20)),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: innerIconColor.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          SizedBox(width: R.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w500,
                    color: subtitleColor ?? Colors.grey[600],
                    fontStyle: subtitleColor != null ? FontStyle.italic : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
