import 'package:flutter/material.dart';

import 'dart:developer';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_url.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/view_model/profile_view_model.dart';
import 'package:samrudhi_delivery_agent_app/widget/profile_shimmer.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_retry_button.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_performance_model.dart'; // Restore Import
import 'package:fl_chart/fl_chart.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoggingOut = false;
  String? _userName;
  String? _userId;
  List<DailyPerformance> _performanceData = [];
  String? _graphError;
  String _selectedFilter = 'week'; // week, month, custom
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGraphLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSPData();
    _fetchPerformanceGraph(); // Restore API call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchProfile();
    });
  }

  Future<void> _fetchPerformanceGraph() async {
    try {
      setState(() {
        _graphError = null;
        _isGraphLoading = true;
      });
      final token = await SharedPrefsUtil.getToken();
      if (token != null) {
        final data = await ApiService().getPartnerPerformanceGraph(
          token,
          filter: _selectedFilter == 'custom' ? null : _selectedFilter,
          startDate: _startDate?.toIso8601String().split('T')[0],
          endDate: _endDate?.toIso8601String().split('T')[0],
        );
        if (mounted) {
          setState(() {
            _performanceData = data;
            _isGraphLoading = false;
          });
        }
      }
    } catch (e) {
      log('Error fetching performance graph: $e');
      if (mounted) {
        setState(() {
          _isGraphLoading = false;
          if (e.toString().contains('Agent profile not found')) {
            _graphError = 'Agent profile not found';
          } else {
            _graphError = 'Could not load performance data';
          }
        });
      }
    }
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter && filter != 'custom') return;

    if (filter == 'custom') {
      _selectDateRange();
    } else {
      setState(() {
        _selectedFilter = filter;
        _startDate = null;
        _endDate = null;
      });
      _fetchPerformanceGraph();
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.headingText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedFilter = 'custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchPerformanceGraph();
    }
  }

  Future<void> _loadSPData() async {
    final userName = await SharedPrefsUtil.getUserName();
    final userId = await SharedPrefsUtil.getUserId();
    setState(() {
      _userName = userName;
      _userId = userId?.toString();
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
                    CustomRetryButton(
                      onTap: () => viewModel.fetchProfile(),
                      isLoading: viewModel.isLoading,
                    ),
                  ],
                ),
              );
            }

            final profile = viewModel.profile;
            final name = _userName ?? profile?.name ?? 'Agent';
            final id = _userId ?? profile?.id?.toString() ?? '---';
            const role = 'Delivery Partner';

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

  ImageProvider? _getProfileImage(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }
    try {
      if (url.startsWith('http') || url.startsWith('https')) {
        return NetworkImage(url);
      } else if (url.startsWith('file://')) {
        debugPrint('Warning: Ignoring file URI from profile: $url');
        return null;
      } else {
        // Handle relative path (e.g. /storage/...)
        // Fix for 404: Ensure 'storage/' is present in the path for Laravel public storage
        String path = url;
        if (path.startsWith('/')) {
          path = path.substring(1);
        }

        if (!path.startsWith('storage/')) {
          path = 'storage/$path';
        }

        final fullUrl = '${AppUrls.baseUrl}/$path';
        return NetworkImage(fullUrl);
      }
    } catch (e) {
      debugPrint('Error creating image provider: $e');
    }
    return null;
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.softGreyBg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Consumer<ProfileViewModel>(
                builder: (context, viewModel, _) {
                  return GestureDetector(
                    onTap: viewModel.isLoading
                        ? null
                        : () async {
                            final success =
                                await viewModel.pickAndUploadImage();
                            if (success && context.mounted) {
                              CustomSnackBar.showSuccess(context,
                                  'Profile photo updated successfully');
                            } else if (viewModel.error != null &&
                                context.mounted) {
                              CustomSnackBar.showError(
                                  context, viewModel.error!);
                            }
                          },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: R.r(44),
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              _getProfileImage(viewModel.profile?.profilePhoto),
                          child: viewModel.isLoading
                              ? const CircularProgressIndicator()
                              : null,
                        ),
                        if (!viewModel.isLoading)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(R.w(4)),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(RemixIcons.camera_line,
                                  color: AppColors.white, size: R.sp(14)),
                            ),
                          ),
                      ],
                    ),
                  );
                },
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
    final viewModel = context.watch<ProfileViewModel>();
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
            _statCard('Orders', '${viewModel.totalOrders}'),
            SizedBox(width: R.w(12)),
            _statCard('Hours', '${viewModel.loginHours.toStringAsFixed(1)}h'),
          ],
        ),
        SizedBox(height: R.h(24)),
        _lineChartSection(),
      ],
    );
  }

  Widget _lineChartSection() {
    // Colors
    final Color ordersColor = AppColors.primaryGreen;
    final Color hoursColor = AppColors.info; // Blue for hours
    final Color cardBg = AppColors.white;

    // Determine Logic based on data availability
    final List<DailyPerformance> displayData =
        _performanceData.isNotEmpty ? _performanceData : [];

    log('Graph Debug: Data Length: ${displayData.length}');

    // Max Y for scale
    double maxY = 10;
    if (displayData.isNotEmpty) {
      final maxOrders = displayData
          .map((e) => e.totalOrders)
          .fold(0, (prev, e) => prev > e ? prev : e)
          .toDouble();
      final maxHours = displayData
          .map((e) => e.totalHours)
          .fold(0.0, (prev, e) => prev > e ? prev : e);

      // Use the larger of the two maxes for the scale
      final overallMax = maxOrders > maxHours ? maxOrders : maxHours;
      maxY = (overallMax + 2).ceilToDouble();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(R.r(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Filter Selectors
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Performance Activity',
                    style: TextStyle(
                      fontSize: R.sp(18),
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingText,
                    ),
                  ),
                  Row(
                    children: [
                      _chartLegendItem('Orders', ordersColor),
                      SizedBox(width: R.w(12)),
                      _chartLegendItem('Hours', hoursColor),
                    ],
                  )
                ],
              ),
              SizedBox(height: R.h(16)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('Week', 'week'),
                    SizedBox(width: R.w(8)),
                    _filterChip('Month', 'month'),
                    SizedBox(width: R.w(8)),
                    _filterChip('Custom', 'custom'),
                  ],
                ),
              ),
              if (_selectedFilter == 'custom' &&
                  _startDate != null &&
                  _endDate != null)
                Padding(
                  padding: EdgeInsets.only(top: R.h(8)),
                  child: Text(
                    '${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}',
                    style: TextStyle(
                      fontSize: R.sp(12),
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: R.h(24)),
          if (_isGraphLoading)
            SizedBox(
              height: R.h(200),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
            )
          else if (_graphError != null)
            SizedBox(
              height: R.h(200),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(RemixIcons.error_warning_line,
                      color: AppColors.error, size: R.sp(24)),
                  SizedBox(height: R.h(8)),
                  Text(
                    _graphError!,
                    style: TextStyle(
                        color: AppColors.bodyText, fontSize: R.sp(13)),
                  ),
                ],
              )),
            )
          else if (displayData.isEmpty)
            SizedBox(
              height: R.h(200),
              child: Center(
                  child: Text(
                'No activity data available',
                style: TextStyle(
                    color: AppColors.bodyText.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic),
              )),
            )
          else
            SizedBox(
              height: R.h(220),
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.headingText,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          final item = displayData[flSpot.x.toInt()];
                          final isOrders = barSpot.barIndex == 0;

                          return LineTooltipItem(
                            '${item.date}\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: isOrders
                                    ? '${item.totalOrders} Orders'
                                    : '${item.totalHours} Hours',
                                style: TextStyle(
                                  color: isOrders ? ordersColor : hoursColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.grey.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < displayData.length) {
                            final dateStr = displayData[index].date;
                            final label = dateStr.length > 3
                                ? dateStr.substring(0, 3)
                                : dateStr;
                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: Text(
                                label,
                                style: TextStyle(
                                  color:
                                      AppColors.bodyText.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: R.sp(10),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxY / 4).clamp(1.0, 100.0),
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppColors.bodyText.withValues(alpha: 0.5),
                              fontSize: R.sp(10),
                            ),
                          ),
                        ),
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (displayData.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    // Orders Line
                    LineChartBarData(
                      spots: displayData.asMap().entries.map((e) {
                        return FlSpot(
                            e.key.toDouble(), e.value.totalOrders.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: ordersColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            ordersColor.withValues(alpha: 0.2),
                            ordersColor.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Hours Line
                    LineChartBarData(
                      spots: displayData.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.totalHours);
                      }).toList(),
                      isCurved: true,
                      color: hoursColor,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            hoursColor.withValues(alpha: 0.15),
                            hoursColor.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: R.w(8),
          height: R.w(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: R.w(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: R.sp(12),
            fontWeight: FontWeight.w600,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => _onFilterChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : AppColors.primaryGreen.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(R.r(20)),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.primaryGreen.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: R.sp(12),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.primaryGreen,
          ),
        ),
      ),
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
      final token = await SharedPrefsUtil.getToken();

      log('Logout initiated. Token present: ${token != null}');

      if (token != null) {
        try {
          // Attempt API logout with a short timeout
          log('Calling Logout API...');
          await ApiService().logout(token).timeout(const Duration(seconds: 3));
          log('Logout API call successful');
        } catch (e) {
          log('Logout API failed or timed out: $e');
        }
      }

      log('Clearing session...');
      await SharedPrefsUtil.clearSession();
      log('Session cleared.');

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
      setState(() => _isLoggingOut = false);
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
