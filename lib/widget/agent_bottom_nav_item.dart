import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/agent_home_dashboard_view.dart';
import 'package:samrudhi_delivery_agent_app/view/deliveries/deliveries_view.dart';
import 'package:samrudhi_delivery_agent_app/view/profile/profile_view.dart';
import '../../constant/app_color.dart';

class AgentBottomNavView extends StatefulWidget {
  const AgentBottomNavView({super.key});

  @override
  State<AgentBottomNavView> createState() => _AgentBottomNavViewState();
}

class _AgentBottomNavViewState extends State<AgentBottomNavView> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  PersistentBottomNavBarItem _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return PersistentBottomNavBarItem(
      icon: Icon(activeIcon, size: 22),
      inactiveIcon: Icon(icon, size: 22),
      title: label,

      // colors handled by library
      activeColorPrimary: AppColors.primaryGreen,
      inactiveColorPrimary: AppColors.hintText,

      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    R.init(context); // ✅ REQUIRED FOR RESPONSIVENESS

    return PersistentTabView(
      context,
      controller: _controller,
      screens: const [
        AgentDashboardView(),
        DeliveriesView(),
        ProfileView(),
      ],
      items: [
        _navItem(
          icon: Remix.home_line,
          activeIcon: RemixIcons.home_fill,
          label: 'Home',
        ),
        _navItem(
          icon: Remix.truck_line,
          activeIcon: RemixIcons.truck_fill,
          label: 'Deliveries',
        ),
        _navItem(
          icon: RemixIcons.user_line,
          activeIcon: Remix.user_fill,
          label: 'Profile',
        ),
      ],
      navBarHeight: R.h(70), // ✅ responsive height
      navBarStyle: NavBarStyle.style1,
      backgroundColor: AppColors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
    );
  }
}
