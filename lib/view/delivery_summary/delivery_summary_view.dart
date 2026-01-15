import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view_model/delivery_summary_view_model.dart';
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

  Widget _buildSummaryContent(dynamic summary) {
    // Assuming summary is DeliverySummary object
    return ListView(
      padding: EdgeInsets.all(R.w(16)),
      children: [
        _statCard('Total Deliveries', '${summary.totalDeliveries}'),
        SizedBox(height: R.h(16)),
        _statCard(
            'Total Earnings', '₹${summary.totalEarnings.toStringAsFixed(2)}'),
        SizedBox(height: R.h(16)),
        _statCard('Total Distance', '${summary.totalDistance} km'),
        SizedBox(height: R.h(16)),
        _statCard('Duration', '${summary.totalDurationHours} hrs'),
      ],
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: R.sp(14),
            ),
          ),
          SizedBox(height: R.h(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: R.sp(24),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
