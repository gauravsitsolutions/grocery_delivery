import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:remixicon/remixicon.dart';
import 'package:intl/intl.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_performance_model.dart';

class PerformanceGraphCard extends StatefulWidget {
  final List<DailyPerformance> data;

  const PerformanceGraphCard({super.key, required this.data});

  @override
  State<PerformanceGraphCard> createState() => _PerformanceGraphCardState();
}

class _PerformanceGraphCardState extends State<PerformanceGraphCard> {
  int touchedIndex = -1;
  String _selectedFilter = 'Weekly';
  DateTime? _selectedEndDate;

  List<DailyPerformance> get _filteredData {
    if (widget.data.isEmpty) return [];

    final sortedData = List<DailyPerformance>.from(widget.data)
      ..sort(
          (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));

    if (_selectedFilter == 'Weekly') {
      // Last 7 days
      return sortedData.length > 7
          ? sortedData.sublist(sortedData.length - 7)
          : sortedData;
    } else if (_selectedFilter == 'Monthly') {
      // Last 30 days
      return sortedData.length > 30
          ? sortedData.sublist(sortedData.length - 30)
          : sortedData;
    } else if (_selectedFilter == 'Date' && _selectedEndDate != null) {
      // 7 Days ending on selected date
      final endDate = _selectedEndDate!;
      // Find index of the selected date or closest previous date
      // This is a bit tricky with string dates. Let's filter by range.
      final startDate = endDate.subtract(const Duration(days: 6));

      return sortedData.where((element) {
        try {
          final date = DateTime.parse(element.date);
          return date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
              date.isBefore(endDate.add(const Duration(seconds: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Default fallback (Weekly)
    return sortedData.length > 7
        ? sortedData.sublist(sortedData.length - 7)
        : sortedData;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
        _selectedFilter = 'Date';
      });
    } else if (picked == null &&
        _selectedFilter == 'Date' &&
        _selectedEndDate == null) {
      // Revert if cancelled and no date valid
      setState(() {
        _selectedFilter = 'Weekly';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final displayData = _filteredData;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Tracker',
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingText,
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(R.r(8)),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter == 'Date' && _selectedEndDate == null
                        ? 'Weekly'
                        : _selectedFilter,
                    icon: Icon(RemixIcons.arrow_down_s_line, size: R.sp(16)),
                    isDense: true,
                    style: TextStyle(
                      fontSize: R.sp(12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText,
                    ),
                    items: ['Weekly', 'Monthly', 'Date'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue == 'Date') {
                        _pickDate();
                      } else if (newValue != null) {
                        setState(() {
                          _selectedFilter = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(24)),
          if (displayData.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: R.h(40)),
                child: Text(
                  'No performance data for this period',
                  style: TextStyle(
                    color: AppColors.bodyText.withValues(alpha: 0.5),
                    fontSize: R.sp(14),
                  ),
                ),
              ),
            )
          else
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.headingText,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      tooltipMargin: 8,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          final index = flSpot.x.toInt();
                          if (index < 0 || index >= displayData.length) {
                            return null;
                          }
                          final item = displayData[index];

                          return LineTooltipItem(
                            '${item.date}\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: '${item.totalOrders} Orders',
                                style: const TextStyle(
                                  color: AppColors.primaryGreen,
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
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1, // Show all if few, skip if many
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < displayData.length) {
                            // If showing Monthly, show fewer labels to avoid crowding
                            if (_selectedFilter == 'Monthly' &&
                                index % 5 != 0) {
                              return const SizedBox.shrink();
                            }

                            final dateStr = displayData[index].date;
                            try {
                              final date = DateTime.parse(dateStr);
                              // Format: 'Tue' for weekly, 'Mb d' for others?
                              // Let's keep it simple 'E' (Tue) or 'd' (12)
                              final formatted = _selectedFilter == 'Weekly'
                                  ? DateFormat('E').format(date)
                                  : DateFormat('d/M').format(date);

                              return SideTitleWidget(
                                meta: meta,
                                child: Text(
                                  formatted,
                                  style: TextStyle(
                                    color: AppColors.bodyText
                                        .withValues(alpha: 0.6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            } catch (e) {
                              return const SizedBox.shrink();
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value % 1 == 0) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color:
                                      AppColors.bodyText.withValues(alpha: 0.4),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: (displayData.length - 1).toDouble(),
                  minY: 0,
                  // Add buffer to top of chart
                  maxY: (displayData.isEmpty
                          ? 10
                          : displayData.map((e) => e.totalOrders).fold<int>(
                                  0,
                                  (prev, element) =>
                                      prev > element ? prev : element) +
                              1)
                      .toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: displayData.asMap().entries.map((e) {
                        return FlSpot(
                            e.key.toDouble(), e.value.totalOrders.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: AppColors.primaryGreen,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: false,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withValues(alpha: 0.3),
                            AppColors.primaryGreen.withValues(alpha: 0.0),
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
}
