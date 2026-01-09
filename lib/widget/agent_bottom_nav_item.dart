import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/agent_home_dashboard_view.dart';
import 'package:samrudhi_delivery_agent_app/view/deliveries/deliveries_view.dart';
import 'package:samrudhi_delivery_agent_app/view/profile/profile_view.dart';
import '../../constant/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';

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
      icon: Icon(activeIcon, size: R.sp(22)),
      inactiveIcon: Icon(icon, size: R.sp(22)),
      title: label,

      // colors handled by library
      activeColorPrimary: AppColors.primaryGreen,
      inactiveColorPrimary: AppColors.hintText,

      textStyle: TextStyle(
        fontSize: R.sp(12),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    // Calculate nav bar height + bottom padding
    final double navHeight = R.h(70) + MediaQuery.of(context).padding.bottom;

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
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('auth_token');

                  if (token == null) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Error: Authentication token not found')),
                    );
                    return;
                  }

                  final apiService = ApiService();
                  await apiService.updateAgentStatus(token, val);

                  if (!context.mounted) return;
                  setState(() => isOnline = val);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            val
                                ? RemixIcons.checkbox_circle_line
                                : RemixIcons.close_circle_line,
                            color: Colors.white,
                          ),
                          SizedBox(width: R.w(12)),
                          Text(
                            val ? 'You are now Online' : 'You are now Offline',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: R.sp(14),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor:
                          val ? AppColors.primaryGreen : AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(R.w(16)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.r(12)),
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.error,
                    ),
                  );
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
          navBarHeight: R.h(70),
          navBarStyle: NavBarStyle.style1,
          backgroundColor: AppColors.white,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardAppears: true,
        ),

        // Lock Layer for Bottom Navigation
        if (!isOnline)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: navHeight,
            child: AbsorbPointer(
              child: Container(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    );
  }
}
