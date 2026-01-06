import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_toggle_button.dart';
import '../../constant/app_color.dart';
import '../../utils/responsive.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  bool newOrderAlerts = true;
  bool deliveryUpdates = true;
  bool chatMessages = true;

  bool promotionalOffers = false;
  bool appUpdates = true;
  bool isOnline = true;

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: const BackButton(color: AppColors.headingText),
        centerTitle: true,
        title: Text(
          'Notification Settings',
          style: TextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w700,
            fontSize: R.sp(18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          R.w(16),
          R.h(8),
          R.w(16),
          R.h(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('PUSH NOTIFICATIONS'),
            SizedBox(height: R.h(12)),
            _settingsCard(
              children: [
                _settingTile(
                  icon: Icons.shopping_bag,
                  title: 'New Order Alerts',
                  subtitle: 'Receive alerts for new delivery jobs',
                  value: newOrderAlerts,
                  onChanged: (v) => setState(() => newOrderAlerts = v),
                ),
                _divider(),
                _settingTile(
                  icon: Icons.local_shipping,
                  title: 'Delivery Updates',
                  subtitle: 'Order status changes and info',
                  value: deliveryUpdates,
                  onChanged: (v) => setState(() => deliveryUpdates = v),
                ),
                _divider(),
                _settingTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat Messages',
                  subtitle: 'Messages from customers or support',
                  value: chatMessages,
                  onChanged: (v) => setState(() => chatMessages = v),
                ),
              ],
            ),
            SizedBox(height: R.h(28)),
            _sectionTitle('OTHER'),
            SizedBox(height: R.h(12)),
            _settingsCard(
              children: [
                _settingTile(
                  icon: Icons.campaign,
                  title: 'Promotional Offers',
                  subtitle: 'Special bonuses and incentives',
                  value: promotionalOffers,
                  onChanged: (v) => setState(() => promotionalOffers = v),
                ),
                _divider(),
                _settingTile(
                  icon: Icons.system_update_alt,
                  title: 'App Updates',
                  subtitle: 'Info on new features and versions',
                  value: appUpdates,
                  onChanged: (v) => setState(() => appUpdates = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.bodyText,
        letterSpacing: 1,
        fontSize: R.sp(13),
      ),
    );
  }

  // ================= SETTINGS CARD =================

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: R.r(12),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ================= SETTING TILE =================

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.w(16),
        vertical: R.h(14),
      ),
      child: Row(
        children: [
          Container(
            width: R.w(44),
            height: R.w(44),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(R.r(12)),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreen,
              size: R.sp(22),
            ),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: R.sp(16),
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: R.sp(14),
                  ),
                ),
              ],
            ),
          ),
          RemixIconToggle(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderLight,
    );
  }
}
