import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view_model/delivery_summary_view_model.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_summary_model.dart';
import 'package:intl/intl.dart';

class DeliverySummaryView extends StatefulWidget {
  const DeliverySummaryView({super.key});

  @override
  State<DeliverySummaryView> createState() => _DeliverySummaryViewState();
}

class _DeliverySummaryViewState extends State<DeliverySummaryView> {
  String _selectedRange = 'today'; // today, week, custom
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliverySummaryViewModel>().fetchSummary();
    });
  }

  void _onRangeChanged(String range) {
    setState(() {
      _selectedRange = range;
    });
    if (range != 'custom') {
      context.read<DeliverySummaryViewModel>().fetchSummary(dateRange: range);
    } else {
      _selectCustomDateRange();
    }
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      context.read<DeliverySummaryViewModel>().fetchSummary(
            dateRange: 'custom',
            fromDate: picked.start,
            toDate: picked.end,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final viewModel = context.watch<DeliverySummaryViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Summary')),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: EdgeInsets.all(R.w(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterChip('Today', 'today'),
                _filterChip('This Week', 'week'),
                _filterChip('Custom', 'custom'),
              ],
            ),
          ),
          if (_selectedRange == 'custom' &&
              _fromDate != null &&
              _toDate != null)
            Padding(
              padding: EdgeInsets.only(bottom: R.h(16)),
              child: Text(
                '${DateFormat('MMM dd').format(_fromDate!)} - ${DateFormat('MMM dd').format(_toDate!)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          // Content Section
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.error != null
                    ? Center(child: Text(viewModel.error!))
                    : viewModel.summary == null
                        ? const Center(child: Text('No data available'))
                        : _buildSummaryContent(viewModel.summary!),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _selectedRange == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _onRangeChanged(value);
      },
      selectedColor: Colors.green.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Colors.green : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSummaryContent(DeliverySummary summary) {
    return ListView(
      padding: EdgeInsets.all(R.w(16)),
      children: [
        _statCard('Completed Orders', '${summary.completedCount}'),
        SizedBox(height: R.h(16)),
        _statCard('Total Distance', '${summary.totalDistanceKm} km'),
        SizedBox(height: R.h(16)),
        _statCard('Avg. Delivery Time',
            '${summary.avgDeliveryTimeMin.toStringAsFixed(1)} min'),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    IconData icon;
    Color color;

    if (title.contains('Orders')) {
      icon = Icons.check_circle_outline;
      color = Colors.green;
    } else if (title.contains('Distance')) {
      icon = Icons.directions_bike;
      color = Colors.blue;
    } else {
      icon = Icons.timer;
      color = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(R.w(12)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: R.sp(24)),
          ),
          SizedBox(width: R.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: R.sp(20),
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
