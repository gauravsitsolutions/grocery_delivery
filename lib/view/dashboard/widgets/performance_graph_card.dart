import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class PerformanceGraphCard extends StatefulWidget {
  const PerformanceGraphCard({super.key});

  @override
  State<PerformanceGraphCard> createState() => _PerformanceGraphCardState();
}

class _PerformanceGraphCardState extends State<PerformanceGraphCard> {
  // Mock Data: Mon-Sun Orders (Average daily range 12-28)
  final List<double> weeklyOrders = [12, 18, 15, 22, 28, 20, 25];
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)), // Matched currentTaskCard
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Performance',
                    style: TextStyle(
                      fontSize: R.sp(18),
                      fontWeight: FontWeight.w800,
                      color: AppColors.headingText,
                    ),
                  ),
                  SizedBox(height: R.h(2)),
                  Text(
                    'Orders vs Last Week',
                    style: TextStyle(
                      fontSize: R.sp(12),
                      color: AppColors.bodyText.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              DropdownButtonHideUnderline(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(12), vertical: R.h(4)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(R.r(20)),
                    border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.2)),
                  ),
                  child: DropdownButton<String>(
                    value: 'Last 7 Days',
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryGreen, size: R.sp(18)),
                    style: TextStyle(
                      fontSize: R.sp(12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                    isDense: true,
                    items: ['Last 7 Days', 'Last 30 Days'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(24)),
          SizedBox(
            height: R.h(160),
            child: LineChart(
              mainData(),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.borderLight.withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 10,
            getTitlesWidget: leftTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 35,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(weeklyOrders.length, (index) {
            return FlSpot(index.toDouble(), weeklyOrders[index]);
          }),
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: const LinearGradient(
            colors: [
              AppColors.primaryGreen,
              Color(0xFF81C784), // Lighter green for gradient
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.white,
                strokeWidth: 2,
                strokeColor: AppColors.primaryGreen,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGreen.withValues(alpha: 0.15),
                AppColors.primaryGreen.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => AppColors.headingText,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              return LineTooltipItem(
                '${touchedSpot.y.toInt()} Orders',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
          tooltipMargin: 10,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 10,
      color: Color(0xFF94A3B8),
    );
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(value.toInt().toString(), style: style),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Color(0xFF64748B),
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mon';
        break;
      case 1:
        text = 'Tue';
        break;
      case 2:
        text = 'Wed';
        break;
      case 3:
        text = 'Thu';
        break;
      case 4:
        text = 'Fri';
        break;
      case 5:
        text = 'Sat';
        break;
      case 6:
        text = 'Sun';
        break;
      default:
        return Container();
    }

    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(text, style: style),
    );
  }
}
