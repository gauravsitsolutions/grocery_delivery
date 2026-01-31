import 'dart:async';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class NewRequestCard extends StatefulWidget {
  final Order order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int countdownSeconds;

  const NewRequestCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onDecline,
    this.countdownSeconds = 45,
  });

  @override
  State<NewRequestCard> createState() => _NewRequestCardState();
}

class _NewRequestCardState extends State<NewRequestCard>
    with SingleTickerProviderStateMixin {
  late int _remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.countdownSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer?.cancel();
            // Automatically decline? Or just show 0?
            // For now, let's just stop at 0 to avoid unintended side effects without user confirmation
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: R.w(4), vertical: R.h(8)),
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(32)),
        border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'ID: #ORD-${widget.order.id}',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      color: AppColors.bodyText.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(RemixIcons.timer_fill,
                      size: R.sp(16), color: Colors.orange),
                  SizedBox(width: R.w(4)),
                  Text(
                    '${_remainingTime}s',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w800,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${(double.tryParse(widget.order.totalAmount) ?? 0.0).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: R.sp(32),
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: R.h(2)),
                  Text(
                    'Estimated Earnings',
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: AppColors.bodyText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(RemixIcons.navigation_fill,
                          size: R.sp(16),
                          color: AppColors.bodyText.withValues(alpha: 0.3)),
                      SizedBox(width: R.w(4)),
                      Text(
                        '3.2 km', // Mock distance
                        style: TextStyle(
                          fontSize: R.sp(18),
                          fontWeight: FontWeight.w800,
                          color: AppColors.headingText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(2)),
                  Text(
                    'Total Distance',
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: AppColors.bodyText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(24)),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onDecline,
                  child: Container(
                    height: R.h(56),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.ghostButtonBg,
                      borderRadius: BorderRadius.circular(R.r(16)),
                    ),
                    child: Text(
                      'Decline',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w800,
                        color: AppColors.ghostButtonText,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onAccept,
                  child: Container(
                    height: R.h(56),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(R.r(16)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Accept Order',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
