import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/partner_performance_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/utils/shared_prefs_util.dart';

class MonthlyPerformanceView extends StatefulWidget {
  const MonthlyPerformanceView({super.key});

  @override
  State<MonthlyPerformanceView> createState() => _MonthlyPerformanceViewState();
}

class _MonthlyPerformanceViewState extends State<MonthlyPerformanceView> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<DailyDutyLog> _logs = [];
  DateTime _currentMonth = DateTime.now();

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
      final monthStr = DateFormat('yyyy-MM').format(_currentMonth);
      final logs = await _apiService.getMonthlyPerformance(token, monthStr);

      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + offset);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Monthly Duty Log',
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
          // Month Selector
          Container(
            padding:
                EdgeInsets.symmetric(vertical: R.h(16), horizontal: R.w(16)),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: TextStyle(
                    fontSize: R.sp(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.headingText,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  // Disable future months if needed, but API might allow empty future
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
                        ? const Center(child: Text('No data for this month'))
                        : ListView.separated(
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
                                  borderRadius: BorderRadius.circular(R.r(12)),
                                  border: isToday
                                      ? Border.all(
                                          color: AppColors.primaryGreen,
                                          width: 1.5)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
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
          ),
        ],
      ),
    );
  }
}
