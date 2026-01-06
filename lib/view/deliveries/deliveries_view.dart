import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/widget/filter_deliveries_sheet.dart';
import '../../utils/responsive.dart';

class DeliveriesView extends StatelessWidget {
  const DeliveriesView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context); // ✅ required once per screen

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Deliveries',
          style: TextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w700,
            fontSize: R.sp(18),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: R.w(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: R.h(16)),

              _searchBar(context),
              SizedBox(height: R.h(20)),

              // SUMMARY
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Completed',
                      value: '12',
                      icon: RemixIcons.checkbox_circle_fill,
                      bg: AppColors.summaryBlueBg,
                      iconColor: AppColors.summaryBlueIcon,
                    ),
                  ),
                  SizedBox(width: R.w(12)),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Distance',
                      value: '24km',
                      icon: RemixIcons.map_pin_fill,
                      bg: AppColors.summaryOrangeBg,
                      iconColor: AppColors.summaryOrangeIcon,
                    ),
                  ),
                  SizedBox(width: R.w(12)),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Avg Time',
                      value: '28m',
                      icon: RemixIcons.timer_fill,
                      bg: AppColors.summaryPurpleBg,
                      iconColor: AppColors.summaryPurpleIcon,
                    ),
                  ),
                ],
              ),

              SizedBox(height: R.h(20)),
              _statusSwitch(),

              SizedBox(height: R.h(22)),
              _sectionLabel('IN PROGRESS'),
              SizedBox(height: R.h(10)),
              _inProgressCard(),

              SizedBox(height: R.h(26)),
              _sectionLabel('UP NEXT'),
              SizedBox(height: R.h(10)),

              _upNextCard(
                orderId: '#ORD-488',
                distance: '1.1km away',
                title: 'Drop off by 3:30 PM',
                subtitle: 'Target • 5 Items',
                icon: RemixIcons.store_2_fill,
                bg: AppColors.summaryOrangeBg,
                iconColor: AppColors.summaryOrangeIcon,
              ),
              SizedBox(height: R.h(12)),
              _upNextCard(
                orderId: '#ORD-501',
                distance: '3.4km away',
                title: 'Pick up by 4:15 PM',
                subtitle: 'Electronics Store • 1 Item',
                icon: RemixIcons.archive_2_fill,
                bg: AppColors.summaryBlueBg,
                iconColor: AppColors.summaryBlueIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= SEARCH =================

  Widget _searchBar(BuildContext context) {
    return Container(
      height: R.h(54),
      padding: EdgeInsets.symmetric(horizontal: R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(28)),
      ),
      child: Row(
        children: [
          Icon(RemixIcons.search_line,
              color: AppColors.bodyText, size: R.sp(20)),
          SizedBox(width: R.w(10)),
          Expanded(
            child: Text(
              'Search Order ID, name...',
              style: TextStyle(
                color: AppColors.bodyText,
                fontSize: R.sp(15),
              ),
            ),
          ),
          Container(
            width: 1,
            height: R.h(24),
            color: AppColors.divider,
          ),
          SizedBox(width: R.w(12)),
          IconButton(
            icon: Icon(
              RemixIcons.equalizer_line,
              color: AppColors.headingText,
              size: R.sp(20),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.transparent,
                builder: (_) => const FilterDeliveriesSheet(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= STATUS SWITCH =================

  Widget _statusSwitch() {
    return Container(
      padding: EdgeInsets.all(R.w(4)),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(R.r(14)),
      ),
      child: Row(
        children: [
          _statusTab('Pending', count: '3', active: true),
          _statusTab('Delivered'),
          _statusTab('Cancelled'),
        ],
      ),
    );
  }

  Widget _statusTab(String label, {String? count, bool active = false}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: R.h(12)),
        decoration: BoxDecoration(
          color: active ? AppColors.white : AppColors.transparent,
          borderRadius: BorderRadius.circular(R.r(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: R.sp(14),
              ),
            ),
            if (count != null) ...[
              SizedBox(width: R.w(6)),
              CircleAvatar(
                radius: R.r(10),
                backgroundColor: AppColors.primaryGreen,
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: R.sp(12),
                    color: AppColors.white,
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  // ================= CARDS =================

  Widget _inProgressCard() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(18)),
        border: const Border(
          left: BorderSide(color: AppColors.primaryGreen, width: 4),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: R.r(22),
                backgroundColor: AppColors.primaryGreen,
                child: Icon(
                  RemixIcons.truck_line,
                  color: AppColors.white,
                  size: R.sp(20),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Text(
                  '#ORD-492',
                  style: TextStyle(
                    fontSize: R.sp(20),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.w(14),
                  vertical: R.h(8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.softGreyBg,
                  borderRadius: BorderRadius.circular(R.r(20)),
                ),
                child: Text(
                  'Details',
                  style: TextStyle(fontSize: R.sp(13)),
                ),
              )
            ],
          ),
          SizedBox(height: R.h(16)),
          ClipRRect(
            borderRadius: BorderRadius.circular(R.r(10)),
            child: LinearProgressIndicator(
              value: 0.7,
              minHeight: R.h(8),
              backgroundColor: AppColors.progressBg,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _upNextCard({
    required String orderId,
    required String distance,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bg,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(18)),
      ),
      child: Row(
        children: [
          Container(
            height: R.w(52),
            width: R.w(52),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(R.r(14)),
            ),
            child: Icon(icon, color: iconColor, size: R.sp(22)),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      orderId,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: R.sp(14),
                      ),
                    ),
                    SizedBox(width: R.w(8)),
                    Text(
                      distance,
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: R.sp(13),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.h(4)),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: R.sp(15),
                  ),
                ),
                SizedBox(height: R.h(2)),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: R.sp(13),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.bodyText,
            size: R.sp(20),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.bodyText,
          fontSize: R.sp(13),
        ),
      );
}

// ================= SUMMARY CARD =================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color bg;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.w(14)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: R.w(36),
            width: R.w(36),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(R.r(10)),
            ),
            child: Icon(icon, color: iconColor, size: R.sp(20)),
          ),
          SizedBox(height: R.h(12)),
          Text(
            title,
            style: TextStyle(
              color: AppColors.bodyText,
              fontSize: R.sp(13),
            ),
          ),
          SizedBox(height: R.h(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: R.sp(22),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
