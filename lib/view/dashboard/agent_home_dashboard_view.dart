import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_toggle_button.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AgentDashboardView extends StatefulWidget {
  const AgentDashboardView({super.key});

  @override
  State<AgentDashboardView> createState() => _AgentDashboardViewState();
}

class _AgentDashboardViewState extends State<AgentDashboardView> {
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: R.w(16),
            vertical: R.h(12),
          ),
            child: ResponsiveRowColumn(
              layout: ResponsiveBreakpoints.of(context).isMobile
                  ? ResponsiveRowColumnType.COLUMN
                  : ResponsiveRowColumnType.ROW,
              rowCrossAxisAlignment: CrossAxisAlignment.start,
              rowSpacing: 24,
              children: [
                // Left Column (Status, Go Online, Current Task)
                ResponsiveRowColumnItem(
                  rowFlex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Section
                      Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: R.r(22),
                                backgroundColor: AppColors.borderLight,
                                child: Icon(Icons.person, size: R.sp(20)),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: R.r(6),
                                  backgroundColor: isOnline
                                      ? AppColors.primaryGreen
                                      : AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: R.w(12)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STATUS',
                                style: TextStyle(
                                  fontSize: R.sp(12),
                                  color: AppColors.bodyText,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    isOnline
                                        ? 'You are Online'
                                        : 'You are Offline',
                                    style: TextStyle(
                                      fontSize: R.sp(18),
                                      fontWeight: FontWeight.w700,
                                      color: isOnline
                                          ? AppColors.black
                                          : AppColors.bodyText,
                                    ),
                                  ),
                                  SizedBox(width: R.w(6)),
                                  Icon(
                                    Icons.circle,
                                    size: R.sp(10),
                                    color: isOnline
                                        ? AppColors.primaryGreen
                                        : AppColors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (ResponsiveBreakpoints.of(context).isMobile) ...[
                            const Spacer(),
                            CircleAvatar(
                              radius: R.r(25),
                              backgroundColor: AppColors.white,
                              child: Icon(
                                RemixIcons.notification_2_line,
                                size: R.sp(22),
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: R.h(16)),

                      // Go Online
                      Container(
                        padding: EdgeInsets.all(R.w(14)),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(R.r(18)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppColors.primaryGreen.withValues(alpha: 0.15),
                              child: Icon(Icons.flash_on,
                                  size: R.sp(18),
                                  color: AppColors.primaryGreen),
                            ),
                            SizedBox(width: R.w(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Go Online',
                                    style: TextStyle(
                                      fontSize: R.sp(16),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Start receiving orders',
                                    style: TextStyle(
                                      fontSize: R.sp(14),
                                      color: AppColors.bodyText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RemixIconToggle(
                              value: isOnline,
                              onChanged: (val) {
                                setState(() => isOnline = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: R.h(24)),

                      // Current Task
                      Text(
                        'Current Task & Delivery',
                        style: TextStyle(
                          fontSize: R.sp(20),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: R.h(12)),
                      Opacity(
                        opacity: isOnline ? 1 : 0.35,
                        child: AbsorbPointer(
                          absorbing: !isOnline,
                          child: _currentTaskCard(),
                        ),
                      ),

                      // Desktop Notification Icon placement if needed
                      if (!ResponsiveBreakpoints.of(context).isMobile) ...[
                        SizedBox(height: R.h(24)),
                        // Maybe move other things here or keep empty
                      ]
                    ],
                  ),
                ),
                // Right Column (New Order, Queue, Available)
                ResponsiveRowColumnItem(
                  rowFlex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Desktop header/spacer compensation if needed
                      if (!ResponsiveBreakpoints.of(context).isMobile)
                        SizedBox(height: R.h(0)), // Adjust alignment

                      // New Order
                      Opacity(
                        opacity: isOnline ? 1 : 0.35,
                        child: AbsorbPointer(
                          absorbing: !isOnline,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'New Order Request',
                                    style: TextStyle(
                                      fontSize: R.sp(20),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '00:23',
                                    style: TextStyle(
                                      fontSize: R.sp(16),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: R.h(12)),
                              _orderCard(
                                title: 'Costco',
                                price: '₹ 32.75',
                                meta: '2.1 mi away • 15 items',
                                acceptText: 'Accept',
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: R.h(24)),

                      // Delivery Queue
                      Opacity(
                        opacity: isOnline ? 1 : 0.35,
                        child: AbsorbPointer(
                          absorbing: !isOnline,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Delivery Queue',
                                    style: TextStyle(
                                      fontSize: R.sp(20),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '2 more',
                                    style: TextStyle(
                                      fontSize: R.sp(14),
                                      color: AppColors.bodyText,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: R.h(12)),
                              _queueCard('CVS Pharmacy', '₹ 8.25', 'Next Up'),
                              _queueCard(
                                  "Trader Joe's", '₹ 22.00', '#2 in queue'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: R.h(24)),

                      // Available
                      Opacity(
                        opacity: isOnline ? 1 : 0.35,
                        child: AbsorbPointer(
                          absorbing: !isOnline,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Available Orders',
                                    style: TextStyle(
                                      fontSize: R.sp(20),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'See all',
                                    style: TextStyle(
                                      fontSize: R.sp(14),
                                      color: AppColors.bodyText,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: R.h(12)),
                              _orderCard(
                                title: 'Safeway',
                                price: '₹ 18.50',
                                meta: '3.5 mi away • 8 items',
                                acceptText: 'Accept Order',
                              ),
                              _orderCard(
                                title: 'Target',
                                price: '₹ 25.10',
                                meta: '1.2 mi away • 21 items',
                                acceptText: 'Accept Order',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  // Current Task Card

  Widget _currentTaskCard() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: R.w(42),
                width: R.w(42),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(R.r(10)),
                  color: AppColors.borderLight,
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Text(
                  'Whole Foods Market',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '₹ 14.50',
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          Container(
            padding: EdgeInsets.all(R.w(14)),
            decoration: BoxDecoration(
              color: AppColors.softGreenBg,
              borderRadius: BorderRadius.circular(R.r(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dropoff by 4:45 PM',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(height: R.h(4)),
                      Text(
                        '123 Maple Street (Apt 4B)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: R.sp(15),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: R.w(8)),
                CircleAvatar(
                  radius: R.r(22),
                  backgroundColor: AppColors.white,
                  child: Icon(RemixIcons.chat_3_line,
                      size: R.sp(18), color: AppColors.black),
                ),
                SizedBox(width: R.w(10)),
                CircleAvatar(
                  radius: R.r(22),
                  backgroundColor: AppColors.white,
                  child: Icon(RemixIcons.phone_line,
                      size: R.sp(18), color: AppColors.black),
                ),
              ],
            ),
          ),
          SizedBox(height: R.h(16)),
          SizedBox(
            width: double.infinity,
            height: R.h(48),
            child: ElevatedButton(
              onPressed: isOnline ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isOnline ? AppColors.primaryGreen : AppColors.borderLight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Navigate to Dropoff',
                    style: TextStyle(
                      fontSize: R.sp(15),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(width: R.w(8)),
                  Icon(
                    Icons.navigation,
                    size: R.sp(18),
                    color: AppColors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Queue Card

  Widget _queueCard(String title, String price, String badge) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(12)),
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(18)),
      ),
      child: Row(
        children: [
          Container(
            height: R.w(40),
            width: R.w(40),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(R.r(10)),
            ),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: R.sp(16),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: R.h(6)),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(4)),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(R.r(12)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: R.sp(12),
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Order Card

  Widget _orderCard({
    required String title,
    required String price,
    required String meta,
    required String acceptText,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(12)),
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: R.w(40),
                width: R.w(40),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(R.r(10)),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.sp(14),
                        color: AppColors.bodyText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isOnline ? () {} : null,
                  icon: Icon(Icons.close, size: R.sp(18)),
                  label: Text(
                    'Reject',
                    style: TextStyle(fontSize: R.sp(14)),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isOnline
                      ? () {
                          Navigator.of(context, rootNavigator: true)
                              .pushNamed(AppRoutes.customer_info);
                        }
                      : null,
                  icon: Icon(Icons.check, size: R.sp(18)),
                  label: Text(
                    acceptText,
                    style: TextStyle(
                        fontSize: R.sp(14), fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
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
