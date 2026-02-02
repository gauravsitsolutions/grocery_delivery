import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_performance_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';

class WeeklyPerformanceView extends StatefulWidget {
  const WeeklyPerformanceView({super.key});

  @override
  State<WeeklyPerformanceView> createState() => _WeeklyPerformanceViewState();
}

class _WeeklyPerformanceViewState extends State<WeeklyPerformanceView> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<DailyDutyLog> _logs = [];
  List<DailyPerformance> _graphData = []; // Graph Data
  DateTime _startDate = DateTime.now().subtract(Duration(
      days: DateTime.now().weekday - 1)); // Start of current week (Monday)

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await SharedPrefsUtil.getToken();
      if (token == null) throw Exception('No token found');

      final dateStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final logs = await _apiService.getWeeklyPerformance(token, dateStr);

      // Fetch Graph Data
      final graphData = await _apiService.getPartnerPerformanceGraph(
        token,
        filter: 'custom',
        startDate: dateStr,
        endDate: DateFormat('yyyy-MM-dd')
            .format(_startDate.add(const Duration(days: 6))),
      );

      setState(() {
        _logs = logs;
        _graphData = graphData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _changeWeek(int weeks) {
    setState(() {
      _startDate = _startDate.add(Duration(days: 7 * weeks));
    });
    _fetchData();
  }

  String _formatDuration(num seconds) {
    if (seconds <= 0) return '0h 0m';
    final duration = Duration(seconds: seconds.toInt());
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  Widget _buildGraph() {
    if (_graphData.isEmpty) return const SizedBox.shrink();

    // Prepare data
    // We want to show Orders (Line)
    // X axis: 0..6 (Mon..Sun)
    // We map fetched data to this structure.
    // _graphData might contain gaps. Ideally we fill them.
    // But for now, let's just plot what we have or map properly.

    // Map data to x index (0-6 based on date relative to _startDate)
    List<FlSpot> spots = [];
    List<FlSpot> hoursSpots = [];
    double maxVal = 0;

    for (var item in _graphData) {
      if (item.date.isEmpty) continue;
      try {
        final itemDate = DateTime.parse(item.date);
        final diff = itemDate.difference(_startDate).inDays;
        if (diff >= 0 && diff <= 6) {
          spots.add(FlSpot(diff.toDouble(), item.totalOrders.toDouble()));
          hoursSpots.add(FlSpot(diff.toDouble(), item.totalHours.toDouble()));

          if (item.totalOrders > maxVal) maxVal = item.totalOrders.toDouble();
          if (item.totalHours > maxVal) maxVal = item.totalHours.toDouble();
        }
      } catch (e) {
        // ignore invalid date
      }
    }

    // Sort spots by x
    spots.sort((a, b) => a.x.compareTo(b.x));
    hoursSpots.sort((a, b) => a.x.compareTo(b.x));

    if (maxVal < 5) maxVal = 5;

    return Container(
      margin: EdgeInsets.all(R.w(16)),
      padding: EdgeInsets.fromLTRB(R.w(16), R.h(24), R.w(16), R.h(10)),
      decoration: BoxDecoration(
        color: const Color(0xff232d37),
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: R.w(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance Overview',
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    _chartLegend('Orders', const Color(0xff4af699),
                        isDark: true),
                    SizedBox(width: R.w(12)),
                    _chartLegend('Hours', const Color(0xffaa4cfc),
                        isDark: true),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: R.h(24)),
          AspectRatio(
            aspectRatio: 1.7,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xff37434d),
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index > 6) {
                          return const SizedBox.shrink();
                        }
                        final dayDate = _startDate.add(Duration(days: index));
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            DateFormat('E').format(dayDate)[0], // M, T, W...
                            style: TextStyle(
                              color: const Color(0xff68737d),
                              fontSize: R.sp(12),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: maxVal / 4,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: const Color(0xff67727d),
                            fontSize: R.sp(10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxVal * 1.2, // Add some headroom
                lineBarsData: [
                  // Orders Line
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xff4af699),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xff4af699).withValues(alpha: 0.3),
                          const Color(0xff4af699).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Hours Line
                  LineChartBarData(
                    spots: hoursSpots,
                    isCurved: true,
                    color: const Color(0xffaa4cfc),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xffaa4cfc).withValues(alpha: 0.3),
                          const Color(0xffaa4cfc).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        Colors.blueGrey.withValues(alpha: 0.8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()} Orders',
                          const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(String label, Color color, {bool isDark = false}) {
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
        SizedBox(width: R.w(6)),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.bodyText.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: R.sp(10),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final endDate = _startDate.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Weekly Duty Log',
          style: TextStyle(
            color: AppColors.headingText,
            fontSize: R.sp(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(color: AppColors.headingText),
      ),
      body: Column(
        children: [
          // Week Selector
          Container(
            padding:
                EdgeInsets.symmetric(vertical: R.h(16), horizontal: R.w(16)),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeWeek(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('MMM d').format(endDate)}',
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingText,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeWeek(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!,
                                style: const TextStyle(color: Colors.red)),
                            TextButton(
                              onPressed: _fetchData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _logs.isEmpty
                        ? const Center(child: Text('No data for this week'))
                        : ListView(
                            padding: EdgeInsets.only(bottom: R.h(20)),
                            children: [
                              _buildGraph(), // Add Graph Here

                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(R.w(16)),
                                itemCount: _logs.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: R.h(12)),
                                itemBuilder: (context, index) {
                                  final log = _logs[index];
                                  final date = DateTime.parse(log.date);
                                  final isToday =
                                      DateUtils.isSameDay(date, DateTime.now());

                                  return Container(
                                    padding: EdgeInsets.all(R.w(16)),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(R.r(12)),
                                      border: isToday
                                          ? Border.all(
                                              color: AppColors.primaryGreen,
                                              width: 1.5)
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(R.w(10)),
                                          decoration: BoxDecoration(
                                            color: AppColors.softGreenBg,
                                            borderRadius:
                                                BorderRadius.circular(R.r(8)),
                                          ),
                                          child: Text(
                                            DateFormat('dd').format(date),
                                            style: TextStyle(
                                              fontSize: R.sp(16),
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: R.w(16)),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat('EEEE').format(date),
                                              style: TextStyle(
                                                fontSize: R.sp(14),
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.headingText,
                                              ),
                                            ),
                                            Text(
                                              DateFormat('MMM d, yyyy')
                                                  .format(date),
                                              style: TextStyle(
                                                fontSize: R.sp(12),
                                                color: AppColors.bodyText,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatDuration(log.totalDutyTime),
                                          style: TextStyle(
                                            fontSize: R.sp(16),
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.headingText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}
