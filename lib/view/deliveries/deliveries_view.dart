import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/widget/filter_deliveries_sheet.dart';
import '../../utils/responsive.dart';

class DeliveriesView extends StatefulWidget {
  const DeliveriesView({super.key});

  @override
  State<DeliveriesView> createState() => _DeliveriesViewState();
}

class _DeliveriesViewState extends State<DeliveriesView> {
  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    // Placeholder for future implementation if needed
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
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
        child: RefreshIndicator(
          onRefresh: _fetchOrders,
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: R.w(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: R.h(16)),
                _searchBar(context),
                SizedBox(height: R.h(16)),
                _filterChips(),
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
                        textColor: Colors.green,
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
                        textColor: Colors.green,
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
                        textColor: Colors.green,
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

                SizedBox(height: R.h(20)),
              ],
            ),
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
        color: const Color(0xffe2e8f0),
        borderRadius: BorderRadius.circular(R.r(12)),
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
        margin: EdgeInsets.all(R.w(1)),
        padding: EdgeInsets.symmetric(vertical: R.h(10)),
        decoration: BoxDecoration(
          color: active ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(R.r(10)),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
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
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(6), vertical: R.h(2)),
                decoration: BoxDecoration(
                  color: const Color(0xffdcfce7),
                  borderRadius: BorderRadius.circular(R.r(10)),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: R.sp(11),
                    color: const Color(0xff15803d),
                    fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(R.r(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(R.r(22)),
                  bottomLeft: Radius.circular(R.r(22)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: R.w(12)),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: R.r(24),
                      backgroundColor: AppColors.primaryGreen,
                      child: Icon(
                        RemixIcons.truck_line,
                        color: AppColors.white,
                        size: R.sp(22),
                      ),
                    ),
                    SizedBox(width: R.w(12)),
                    Expanded(
                      child: Text(
                        '#ORD-492',
                        style: TextStyle(
                          fontSize: R.sp(22),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.w(16),
                        vertical: R.h(8),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfff8fafc),
                        borderRadius: BorderRadius.circular(R.r(20)),
                        border: Border.all(color: const Color(0xfff1f5f9)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(
                              fontSize: R.sp(13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.headingText,
                            ),
                          ),
                          SizedBox(width: R.w(4)),
                          Icon(Icons.chevron_right,
                              size: R.sp(14), color: AppColors.bodyText),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: R.h(16)),
                Container(
                  height: R.h(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xfff1f5f9),
                    borderRadius: BorderRadius.circular(R.r(10)),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.7,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(R.r(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
  Widget _filterChips() {
    final filters = [
      {'label': 'All', 'active': true},
      {'label': 'Date', 'icon': RemixIcons.calendar_event_line},
      {'label': 'Type', 'icon': RemixIcons.shopping_bag_3_line},
      {'label': 'COD', 'icon': RemixIcons.money_dollar_circle_line},
      {'label': 'Status', 'icon': RemixIcons.filter_3_line},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isActive = f['active'] == true;
          return Container(
            margin: EdgeInsets.only(right: R.w(8)),
            padding: EdgeInsets.symmetric(
              horizontal: R.w(12),
              vertical: R.h(8),
            ),
            decoration: BoxDecoration(
              color: isActive ? AppColors.headingText : AppColors.white,
              borderRadius: BorderRadius.circular(R.r(20)),
              border: Border.all(
                color: isActive ? Colors.transparent : AppColors.divider,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (f['icon'] != null) ...[
                  Icon(
                    f['icon'] as IconData,
                    size: R.sp(16),
                    color: isActive ? AppColors.white : AppColors.bodyText,
                  ),
                  SizedBox(width: R.w(6)),
                ],
                Text(
                  f['label'] as String,
                  style: TextStyle(
                    color: isActive ? AppColors.white : AppColors.bodyText,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: R.sp(13),
                  ),
                ),
                if (f['icon'] != null && !isActive) ...[
                  SizedBox(width: R.w(2)),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: R.sp(14),
                    color: AppColors.bodyText,
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ================= SUMMARY CARD =================

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final Color textColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.bg,
    required this.iconColor,
    this.textColor = AppColors.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.w(14)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: R.w(32),
                width: R.w(32),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(R.r(8)),
                ),
                child: Icon(icon, color: iconColor, size: R.sp(16)),
              ),
              SizedBox(width: R.w(8)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xff16a34a),
                    fontSize: R.sp(11),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Text(
            value,
            style: TextStyle(
              fontSize: R.sp(24),
              fontWeight: FontWeight.w900,
              color: AppColors.headingText,
            ),
          ),
        ],
      ),
    );
  }
}
