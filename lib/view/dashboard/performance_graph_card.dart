import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_performance_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class PerformanceGraphCard extends StatefulWidget {
  final List<DailyPerformance> data;

  const PerformanceGraphCard({super.key, required this.data});

  @override
  State<PerformanceGraphCard> createState() => _PerformanceGraphCardState();
}

class _PerformanceGraphCardState extends State<PerformanceGraphCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    R.init(context);

    // Show only last 7 days of data
    final displayData = widget.data.length > 7
        ? widget.data.sublist(widget.data.length - 7)
        : widget.data;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white, // Using white background
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
          Text(
            'Weekly Performance',
            style: TextStyle(
              fontSize: R.sp(16),
              fontWeight: FontWeight.w700,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: R.h(24)),
          if (displayData.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: R.h(20)),
                child: Text(
                  'No performance data available',
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
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < displayData.length) {
                            final dateStr = displayData[index].date;
                            try {
                              final date = DateTime.parse(dateStr);
                              final formatted = DateFormat('E').format(date);
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
                  maxY: (displayData.map((e) => e.totalOrders).fold<int>(
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
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: AppColors.primaryGreen,
                          );
                        },
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
