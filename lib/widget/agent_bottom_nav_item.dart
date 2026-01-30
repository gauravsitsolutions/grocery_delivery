import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view/dashboard/agent_home_dashboard_view.dart';
import 'package:samrudhi_delivery_agent_app/view/deliveries/deliveries_view.dart';
import 'package:samrudhi_delivery_agent_app/view/delivery_history/delivery_history_view.dart';
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
  bool isOnline = false; // Default to false until we know status
  bool isLoading = true;
  String? dutyStatus;

  // GlobalKey to access dashboard state for refreshing
  final GlobalKey<State> _dashboardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // If switching TO the home tab (index 0)
    if (_controller.index == 0) {
      // Find the state and call refreshData if it exists
      // We need to cast it dynamically or define an interface, simpler to use dynamic given imports
      final state = _dashboardKey.currentState;
      if (state != null) {
        // Use reflection-like dynamic call since we don't want to export the State class publicly
        // just for this. Or we can assume the method exists.
        try {
          (state as dynamic).refreshData();
        } catch (e) {
          // Method might not be defined or state mismatch, ignore
        }
      }
    }
  }

  Future<void> _checkInitialStatus() async {
    try {
      // 1. Try to load from cache first for immediate UI
      final cachedStatus = await SharedPrefsUtil.getDutyStatus();
      if (cachedStatus != null && mounted) {
        setState(() {
          dutyStatus = cachedStatus;
          isOnline = cachedStatus == 'online' || cachedStatus == 'paused';
          // We can stop initial loading if we have a cache, or keep it until API returns
          // Let's keep loading true until API confirms to avoid split-second outdated data
          // But the UI will already "know" the likely state.
        });
      }

      final token = await SharedPrefsUtil.getToken();
      if (token != null) {
        final apiService = ApiService();
        final summary = await apiService.getPartnerProfileSummary(token);
        if (mounted) {
          setState(() {
            // 'online' or 'paused' means the agent session is active (isOnline = true for UI lock purposes)
            dutyStatus = summary.dutyStatus;
            isOnline = summary.dutyStatus == 'online' ||
                summary.dutyStatus == 'paused';
            isLoading = false;
          });
          // Update cache with fresh status
          await SharedPrefsUtil.setDutyStatus(summary.dutyStatus ?? 'offline');
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      // Fallback or just stop loading
      if (mounted) setState(() => isLoading = false);
    }
  }

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
              key: _dashboardKey,
              isOnline: isOnline,
              dutyStatus: dutyStatus,
              onStatusChanged: (val) async {
                final newStatus = val ? 'online' : 'offline';
                // 1. Optimistic Update
                setState(() {
                  isOnline = val;
                  dutyStatus = newStatus;
                });

                // Save to cache immediately
                await SharedPrefsUtil.setDutyStatus(newStatus);

                try {
                  final token = await SharedPrefsUtil.getToken();

                  if (token == null) {
                    if (!context.mounted) return;
                    // Revert
                    final revertedStatus = !val ? 'online' : 'offline';
                    setState(() {
                      isOnline = !val;
                      dutyStatus = revertedStatus;
                    });
                    await SharedPrefsUtil.setDutyStatus(revertedStatus);

                    if (!context.mounted) return;
                    CustomSnackBar.showError(
                        context, 'Error: Authentication token not found');
                    return;
                  }

                  final apiService = ApiService();
                  await apiService.updateAgentStatus(token, val);

                  if (!context.mounted) return;

                  // Success - State is already updated optimistically in cache and RAM.
                  if (val) {
                    CustomSnackBar.showSuccess(context, 'You are now Online');
                  } else {
                    CustomSnackBar.showSuccess(context, 'You are now Offline',
                        title: 'Offline', color: AppColors.error);
                  }
                } catch (e) {
                  if (!context.mounted) return;

                  // Check if it's an "Already online" validation error
                  final errorMessage = e.toString().toLowerCase();
                  if (val && errorMessage.contains('already online')) {
                    // It's actually a success state (we are online), so don't revert.
                    CustomSnackBar.showSuccess(
                        context, 'You are already Online');
                    return;
                  }

                  // 2. Revert on Failure for other errors
                  final revertedStatus = !val ? 'online' : 'offline';
                  setState(() {
                    isOnline = !val;
                    dutyStatus = revertedStatus;
                  });
                  await SharedPrefsUtil.setDutyStatus(revertedStatus);

                  if (context.mounted) {
                    CustomSnackBar.showError(
                        context, e.toString().replaceAll('Exception: ', ''));
                  }
                }
              },
              onViewDeliveries: () {
                // _controller.jumpToTab(1);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveryHistoryView(),
                  ),
                );
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
