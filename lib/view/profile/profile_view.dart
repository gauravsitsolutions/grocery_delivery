import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserDetails(),
          builder: (context, snapshot) {
            final name = snapshot.data?['name'] ?? 'Agent';
            final id = snapshot.data?['id']?.toString() ?? '---';
            final role = snapshot.data?['role'] ?? 'Partner';
            
            return SingleChildScrollView(
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

                  SizedBox(height: R.h(28)), // spacing preserved

                  _performanceSection(),
                  SizedBox(height: R.h(32)),

                  _infoSection(
                title: 'Personal Information',
                children: [
                  _infoRow(RemixIcons.phone_line, 'Phone Number',
                      '+1 (555) 019-2834',
                      edit: true),
                  _infoRow(RemixIcons.mail_line, 'Email Address',
                      'm.scott@dunder.com',
                      edit: true),
                  _infoRow(RemixIcons.map_pin_line, 'Delivery Region',
                      'Scranton Downtown'),
                ],
              ),

              SizedBox(height: R.h(28)),

              _infoSection(
                title: 'Vehicle Details',
                children: [
                  _infoRow(RemixIcons.motorbike_line, 'Vehicle Type',
                      'Scooter - Yamaha NMAX',
                      edit: true),
                  _infoRow(
                      Icons.confirmation_number, 'License Plate', '8X-9921'),
                  _infoRow(RemixIcons.verified_badge_line, 'Documents',
                      'Verified & Active',
                      highlight: true),
                ],
              ),

              SizedBox(height: R.h(32)),
              _logoutButton(),

              SizedBox(height: R.h(16)),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  String text = '';
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    text = 'Verifying version...';
                  } else if (snapshot.hasError) {
                    // This creates visible feedback if the plugin isn't linked (MissingPluginException)
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
        );
      },
        ), // FutureBuilder
      ), // SafeArea
    ); // Scaffold
  }
  // ================= HEADER =================

  Future<Map<String, dynamic>> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final id = prefs.getInt('user_id');
    final role = prefs.getString('user_role');
    
    // Debug print to check what's stored
    debugPrint('Profile Fetch - Name: $name, ID: $id, Role: $role');

    return {
      'name': name,
      'id': id,
      'role': role,
    };
  }

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
  }) {
    return Padding(
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
                    color:
                        highlight ? AppColors.primaryGreen : AppColors.bodyText,
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
    );
  }

  // ================= LOGOUT =================
  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data
    if (context.mounted) {
       Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login, // Ensure this route exists in your routes map
        (route) => false,
      );
    }
  }

  Widget _logoutButton() {
    return Builder(
      builder: (context) {
        return OutlinedButton.icon(
          onPressed: () => _handleLogout(context),
          icon: const Icon(RemixIcons.logout_circle_r_line, color: AppColors.error),
          label: Text(
            'Log Out',
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
    );
  }
}
