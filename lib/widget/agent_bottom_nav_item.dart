import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/agent_home_dashboard_view.dart';
import 'package:samrudhi_delivery_agent_app/view/deliveries/deliveries_view.dart';
import 'package:samrudhi_delivery_agent_app/view/profile/profile_view.dart';
import '../../constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';

class AgentBottomNavView extends StatefulWidget {
  const AgentBottomNavView({super.key});

  @override
  State<AgentBottomNavView> createState() => _AgentBottomNavViewState();
}

class _AgentBottomNavViewState extends State<AgentBottomNavView> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  bool isOnline = true;

  PersistentBottomNavBarItem _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return PersistentBottomNavBarItem(
      icon: Icon(activeIcon, size: R.sp(24)),
      inactiveIcon: Icon(icon, size: R.sp(24)),
      title: label,
      activeColorPrimary: AppColors.primaryGreen,
      inactiveColorPrimary: AppColors.grey,
      activeColorSecondary: AppColors.primaryGreen,
      textStyle: TextStyle(
        fontSize: R.sp(12),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    // Calculate nav bar height + bottom padding for the lock layer
    // Style15/Floating usually has a higher visual height due to logic

    return Stack(
      children: [
        PersistentTabView(
          context,
          controller: _controller,
          screens: [
            AgentDashboardView(
              isOnline: isOnline,
              onStatusChanged: (val) async {
                try {
                  final token = await SharedPrefsUtil.getToken();

                  if (token == null) {
                    if (!context.mounted) return;
                    CustomSnackBar.showError(
                        context, 'Error: Authentication token not found');
                    return;
                  }

                  final apiService = ApiService();
                  await apiService.updateAgentStatus(token, val);

                  if (!context.mounted) return;
                  setState(() => isOnline = val);

                  if (val) {
                    CustomSnackBar.showSuccess(context, 'You are now Online');
                  } else {
                    CustomSnackBar.showInfo(context, 'You are now Offline');
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  CustomSnackBar.showError(
                      context, e.toString().replaceAll('Exception: ', ''));
                }
              },
              onViewDeliveries: () {
                _controller.jumpToTab(1); // Switch to Deliveries Tab (index 1)
              },
            ),
            const DeliveriesView(),
            const ProfileView(),
          ],
          items: [
            _navItem(
              icon: Remix.home_5_line,
              activeIcon: Remix.home_5_fill,
              label: 'Home',
            ),
            _navItem(
              icon: Remix.truck_line,
              activeIcon: Remix.truck_fill,
              label: 'Deliveries',
            ),
            _navItem(
              icon: Remix.user_3_line,
              activeIcon: Remix.user_3_fill,
              label: 'Profile',
            ),
          ],
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardAppears: true,
          margin: EdgeInsets.zero,
          decoration: const NavBarDecoration(
            colorBehindNavBar: Colors.white,
          ),
          navBarStyle: NavBarStyle.style1,
        ),

        // Lock Layer for Bottom Navigation (When Offline)
        if (!isOnline)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: kBottomNavigationBarHeight +
                MediaQuery.of(context).padding.bottom,
            child: AbsorbPointer(
              child: Container(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}
