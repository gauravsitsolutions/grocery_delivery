import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/view/notification_settings/notification_settings_view.dart';
import '../../../constant/app_color.dart';
import '../../../utils/responsive.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  int selectedTab = 0;

  final tabs = ['All', 'Orders', 'Updates', 'System'];

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: _appBar(),
      body: Column(
        children: [
          _tabs(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(R.w(16)),
              children: [
                _sectionHeader('NEW & UNREAD', action: 'Clear all'),
                SizedBox(height: R.h(12)),
                _newOrderCard(),
                SizedBox(height: R.h(12)),
                _notificationCard(
                  icon: Icons.map,
                  iconBg: const Color(0xFFEAF1FF),
                  iconColor: Colors.blue,
                  title: 'Route Updated',
                  time: '10m ago',
                  message:
                      'Customer added a note: "Gate code is 4455, please leave at front door."',
                  unread: true,
                ),
                SizedBox(height: R.h(12)),
                _notificationCard(
                  icon: Icons.attach_money,
                  iconBg: const Color(0xFFFFF6E0),
                  iconColor: Colors.orange,
                  title: 'Peak Pay Active 🔥',
                  time: '2h ago',
                  message:
                      'Earn an extra \$2.00 per delivery in Downtown zone between 5 PM and 8 PM tonight.',
                  unread: true,
                ),
                SizedBox(height: R.h(24)),
                _sectionHeader('EARLIER'),
                SizedBox(height: R.h(12)),
                _notificationCard(
                  icon: Icons.check_circle,
                  iconBg: const Color(0xFFEFF3F8),
                  iconColor: Colors.grey,
                  title: 'Order #8829 Completed',
                  time: 'Yesterday',
                  message:
                      'Successfully delivered to 123 Main St. Total payout: \$18.25',
                ),
                SizedBox(height: R.h(12)),
                _notificationCard(
                  icon: Icons.info,
                  iconBg: const Color(0xFFEFF3F8),
                  iconColor: Colors.grey,
                  title: 'App Update v2.4',
                  time: '2d ago',
                  message:
                      'New features for improved GPS tracking are now live. Check the help center for details.',
                ),
                SizedBox(height: R.h(40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= APP BAR =================

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldBg,
      elevation: 0,
      centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
      title: Text(
        'Notifications',
        style: TextStyle(
          fontSize: R.sp(20),
          fontWeight: FontWeight.w800,
          color: AppColors.headingText,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(RemixIcons.mail_check_line, size: R.sp(22)),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(RemixIcons.settings_3_line, size: R.sp(22)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsView(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ================= TABS =================

  Widget _tabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(R.w(16), R.h(8), R.w(16), R.h(12)),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = selectedTab == i;
          return Padding(
            padding: EdgeInsets.only(right: R.w(10)),
            child: ChoiceChip(
              label: Row(
                children: [
                  Text(
                    tabs[i],
                    style: TextStyle(fontSize: R.sp(14)),
                  ),
                  if (i == 1)
                    Container(
                      margin: EdgeInsets.only(left: R.w(6)),
                      padding: EdgeInsets.all(R.w(6)),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: R.sp(12),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              selected: selected,
              onSelected: (_) => setState(() => selectedTab = i),
              selectedColor: AppColors.primaryGreen,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.headingText,
                fontWeight: FontWeight.w700,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color:
                      selected ? AppColors.primaryGreen : AppColors.borderLight,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ================= SECTION HEADER =================

  Widget _sectionHeader(String title, {String? action}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.bodyText,
            fontSize: R.sp(13),
          ),
        ),
        const Spacer(),
        if (action != null)
          Text(
            action,
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
              fontSize: R.sp(13),
            ),
          ),
      ],
    );
  }

  // ================= NEW ORDER CARD =================

  Widget _newOrderCard() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
        border: Border.all(color: AppColors.primaryGreen),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: .15),
            blurRadius: R.r(12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _icon(Icons.shopping_bag, AppColors.primaryGreen),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Text(
                  'New Order Request',
                  style: TextStyle(
                    fontSize: R.sp(18),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Just now',
                style: TextStyle(
                  color: AppColors.bodyText,
                  fontSize: R.sp(13),
                ),
              ),
              SizedBox(width: R.w(8)),
              const CircleAvatar(radius: 5, backgroundColor: Colors.green),
            ],
          ),
          SizedBox(height: R.h(8)),
          Text(
            '\$15.50 • 5.2 mi',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
              fontSize: R.sp(14),
            ),
          ),
          SizedBox(height: R.h(8)),
          Text(
            'Pickup at Whole Foods Market. Large order including frozen items.',
            style: TextStyle(
              color: AppColors.bodyText,
              fontSize: R.sp(14),
            ),
          ),
          SizedBox(height: R.h(16)),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  'Accept',
                  AppColors.primaryGreen,
                  Colors.white,
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: _actionButton(
                  'Decline',
                  AppColors.borderLight,
                  AppColors.headingText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= NORMAL NOTIFICATION =================

  Widget _notificationCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String time,
    required String message,
    bool unread = false,
  }) {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: R.r(12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _icon(icon, iconColor, bg: iconBg),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(15),
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: AppColors.bodyText,
                        fontSize: R.sp(12),
                      ),
                    ),
                    if (unread)
                      Container(
                        margin: EdgeInsets.only(left: R.w(8)),
                        width: R.w(10),
                        height: R.w(10),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: R.h(6)),
                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: R.sp(14),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: R.sp(20)),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _icon(IconData icon, Color color, {Color? bg}) {
    return CircleAvatar(
      radius: R.r(26),
      backgroundColor: bg ?? color.withValues(alpha: .15),
      child: Icon(icon, color: color, size: R.sp(20)),
    );
  }

  Widget _actionButton(String text, Color bg, Color color) {
    return SizedBox(
      height: R.h(48),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(R.r(14)),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: R.sp(16),
          ),
        ),
      ),
    );
  }
}
