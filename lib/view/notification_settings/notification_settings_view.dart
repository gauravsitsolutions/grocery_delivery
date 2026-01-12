import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_toggle_button.dart';
import '../../constant/app_color.dart';
import '../../utils/responsive.dart';
import '../../view_model/notifications_view_model.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().fetchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: const BackButton(color: AppColors.headingText),
        centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
        title: Text(
          'Notification Settings',
          style: TextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w700,
            fontSize: R.sp(18),
          ),
        ),
      ),
      body: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, child) {
          final settings = viewModel.settings;
          return SingleChildScrollView(
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
                      value: settings['new_order_alerts'] ?? true,
                      onChanged: (v) =>
                          viewModel.updateSetting('new_order_alerts', v),
                    ),
                    _divider(),
                    _settingTile(
                      icon: Icons.local_shipping,
                      title: 'Delivery Updates',
                      subtitle: 'Order status changes and info',
                      value: settings['delivery_updates'] ?? true,
                      onChanged: (v) =>
                          viewModel.updateSetting('delivery_updates', v),
                    ),
                    _divider(),
                    _settingTile(
                      icon: Icons.chat_bubble_outline,
                      title: 'Chat Messages',
                      subtitle: 'Messages from customers or support',
                      value: settings['chat_messages'] ?? true,
                      onChanged: (v) =>
                          viewModel.updateSetting('chat_messages', v),
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
                      value: settings['promotional_offers'] ?? false,
                      onChanged: (v) =>
                          viewModel.updateSetting('promotional_offers', v),
                    ),
                    _divider(),
                    _settingTile(
                      icon: Icons.system_update_alt,
                      title: 'App Updates',
                      subtitle: 'Info on new features and versions',
                      value: settings['app_updates'] ?? true,
                      onChanged: (v) =>
                          viewModel.updateSetting('app_updates', v),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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
            color: Colors.black.withValues(alpha: 0.04),
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
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
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
