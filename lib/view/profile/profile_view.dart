import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:developer';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/view_model/profile_view_model.dart';
import 'package:samrudhi_delivery_agent_app/widget/profile_shimmer.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoggingOut = false;
  String? _userName;
  String? _userId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadSPData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchProfile();
    });
  }

  Future<void> _loadSPData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name');
      _userId = prefs.getInt('user_id')?.toString();
      _userRole = prefs.getString('user_role');
    });
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: R.sp(18),
            color: AppColors.headingText,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
      ),
      body: SafeArea(
        bottom: false,
        child: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.profile == null) {
              return const ProfileShimmer();
            }

            if (viewModel.error != null && viewModel.profile == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewModel.error!),
                    ElevatedButton(
                      onPressed: () => viewModel.fetchProfile(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final profile = viewModel.profile;
            final name = _userName ?? profile?.name ?? 'Agent';
            final id = _userId ?? profile?.id?.toString() ?? '---';
            final role = _userRole ?? 'Delivery Partner';

            return RefreshIndicator(
              onRefresh: () => viewModel.fetchProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  R.w(16),
                  R.h(16),
                  R.w(16),
                  R.h(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileHeader(name, id, role),
                    SizedBox(height: R.h(28)),
                    _performanceSection(),
                    SizedBox(height: R.h(32)),
                    _infoSection(
                      title: 'Personal Information',
                      children: [
                        _infoRow(RemixIcons.phone_line, 'Phone Number',
                            profile?.mobile ?? '---',
                            edit: true, onTap: _showEditPhoneDialog),
                        _infoRow(RemixIcons.mail_line, 'Email Address',
                            profile?.email ?? '---',
                            edit: true, onTap: _showEditEmailDialog),
                        _infoRow(RemixIcons.map_pin_line, 'Address',
                            profile?.address ?? '---'),
                      ],
                    ),
                    SizedBox(height: R.h(28)),
                    _infoSection(
                      title: 'Vehicle Details',
                      children: [
                        _infoRow(RemixIcons.motorbike_line, 'Vehicle Type',
                            profile?.vehicleType ?? '---',
                            edit: true, onTap: _showEditVehicleDialog),
                        _infoRow(Icons.confirmation_number, 'License Number',
                            profile?.vehicleNumber ?? '---'),
                        _infoRow(
                            RemixIcons.verified_badge_line,
                            'Documents',
                            profile?.status == 1
                                ? 'Verified & Active'
                                : 'Inactive',
                            highlight: profile?.status == 1),
                      ],
                    ),
                    SizedBox(height: R.h(32)),
                    _logoutButton(),
                    SizedBox(height: R.h(16)),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        String text = '';
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          text = 'Verifying version...';
                        } else if (snapshot.hasError) {
                          text = 'Version info unavailable (Restart App)';
                        } else if (snapshot.hasData) {
                          text = 'Version ${snapshot.data!.version}';
                        }

                        if (text.isEmpty) return const SizedBox();

                        return Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: R.h(20)),
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: R.sp(12),
                                color: AppColors.bodyText,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      // SafeArea
    ); // Scaffold
  }
  // ================= HEADER =================

  Widget _profileHeader(String name, String id, String role) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: R.h(8)),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: R.w(104),
                height: R.w(104),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF1F1F1),
                ),
              ),
              CircleAvatar(
                radius: R.r(44),
                backgroundImage:
                    const AssetImage('assets/images/profile_placeholder.png'),
              ),
              Positioned(
                bottom: R.h(10),
                right: R.w(10),
                child: Container(
                  width: R.w(14),
                  height: R.w(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: R.w(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          Text(
            name,
            style: TextStyle(
              fontSize: R.sp(22),
              fontWeight: FontWeight.w700,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: R.h(6)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: R.w(12),
              vertical: R.h(4),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(R.r(20)),
            ),
            child: Text(
              'ID #$id  •  $role',
              style: TextStyle(
                fontSize: R.sp(13),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PERFORMANCE =================

  Widget _performanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: TextStyle(
            fontSize: R.sp(20),
            fontWeight: FontWeight.w700,
            color: AppColors.headingText,
          ),
        ),
        SizedBox(height: R.h(16)),
        Row(
          children: [
            _statCard('Orders', '142'),
            SizedBox(width: R.w(12)),
            _statCard('Hours', '38h'),
          ],
        ),
        SizedBox(height: R.h(16)),
        _chartCard(),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: R.h(16)),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(R.r(16)),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Text(label,
                style:
                    TextStyle(fontSize: R.sp(13), color: AppColors.bodyText)),
            SizedBox(height: R.h(6)),
            Text(
              value,
              style: TextStyle(
                fontSize: R.sp(20),
                fontWeight: FontWeight.w700,
                color: AppColors.headingText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 7,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(enabled: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    const days = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun'
                    ];
                    if (value < 0 || value > 6) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        days[value.toInt()],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.bodyText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 3),
                  FlSpot(1, 4),
                  FlSpot(2, 2),
                  FlSpot(3, 5),
                  FlSpot(4, 4),
                  FlSpot(5, 6),
                  FlSpot(6, 4),
                ],
                isCurved: true,
                curveSmoothness: 0.35, // 🔑 important
                color: AppColors.primaryGreen,
                barWidth: 3,
                isStrokeCapRound: true,

                dotData: FlDotData(
                  show: false, // 🔑 hides dots (old look)
                ),

                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryGreen.withValues(alpha: 0.25),
                      AppColors.primaryGreen.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INFO =================

  Widget _infoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: R.sp(20),
            fontWeight: FontWeight.w700,
            color: AppColors.headingText,
          ),
        ),
        SizedBox(height: R.h(12)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(R.r(16)),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value, {
    bool edit = false,
    bool highlight = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.w(16),
          vertical: R.h(14),
        ),
        child: Row(
          children: [
            Container(
              width: R.w(40),
              height: R.w(40),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(R.r(12)),
              ),
              child: Icon(icon, color: AppColors.headingText),
            ),
            SizedBox(width: R.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: R.sp(14), fontWeight: FontWeight.w600)),
                  SizedBox(height: R.h(2)),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: highlight
                          ? AppColors.primaryGreen
                          : AppColors.bodyText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              edit ? RemixIcons.pencil_line : Icons.chevron_right,
              color: AppColors.bodyText,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPhoneDialog() {
    final viewModel = context.read<ProfileViewModel>();
    final controller = TextEditingController(text: viewModel.profile?.mobile);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Phone Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter new phone number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await viewModel.updatePhone(controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  CustomSnackBar.showSuccess(
                      context, 'Phone updated successfully');
                } else {
                  CustomSnackBar.showError(
                      context, viewModel.error ?? 'Failed to update phone');
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog() {
    final viewModel = context.read<ProfileViewModel>();
    final controller = TextEditingController(text: viewModel.profile?.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Email Address'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter new email address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await viewModel.updateEmail(controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  CustomSnackBar.showSuccess(
                      context, 'Email updated successfully');
                } else {
                  CustomSnackBar.showError(
                      context, viewModel.error ?? 'Failed to update email');
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditVehicleDialog() {
    final viewModel = context.read<ProfileViewModel>();
    final typeController =
        TextEditingController(text: viewModel.profile?.vehicleType);
    final numberController =
        TextEditingController(text: viewModel.profile?.vehicleNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Vehicle Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Type',
                hintText: 'e.g. Scooter, Bike',
              ),
            ),
            SizedBox(height: R.h(12)),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Number',
                hintText: 'e.g. MH-12-AB-1234',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await viewModel.updateVehicle(
                typeController.text,
                numberController.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  CustomSnackBar.showSuccess(
                      context, 'Vehicle details updated successfully');
                } else {
                  CustomSnackBar.showError(
                      context, viewModel.error ?? 'Failed to update vehicle');
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ================= LOGOUT =================
  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      log('Logout initiated. Token present: ${token != null}');

      if (token != null) {
        try {
          // Attempt API logout with a short timeout to prevent UI freeze
          log('Calling Logout API...');
          await ApiService().logout(token).timeout(const Duration(seconds: 3));
          log('Logout API call successful');
        } catch (e) {
          log('Logout API failed or timed out: $e');
          // Start local logout regardless of API failure
        }
      }

      log('Clearing SharedPreferences...');
      await prefs.clear();
      log('SharedPreferences cleared.');

      if (!mounted) {
        log('Context not mounted, skipping navigation');
        return;
      }

      // Show Logout Success
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Logout Successful');
      }

      // Wait a moment
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      log('Navigating to Login Screen...');
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    } catch (e) {
      log('Critical Error during logout: $e');
      setState(
          () => _isLoggingOut = false); // Re-enable button if something crashes
    }
  }

  Widget _logoutButton() {
    return OutlinedButton.icon(
      onPressed: _isLoggingOut ? null : _handleLogout,
      icon: _isLoggingOut
          ? SizedBox(
              width: R.sp(20),
              height: R.sp(20),
              child: const CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.error))
          : const Icon(RemixIcons.logout_circle_r_line, color: AppColors.error),
      label: Text(
        _isLoggingOut ? 'Logging Out...' : 'Log Out',
        style: TextStyle(fontSize: R.sp(16), color: AppColors.error),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, R.h(56)),
        side: const BorderSide(color: AppColors.error),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.r(16)),
        ),
      ),
    );
  }
}
