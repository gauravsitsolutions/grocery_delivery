import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/delivery_history_model.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view_model/delivery_history_view_model.dart';
import 'package:samrudhi_delivery_agent_app/widget/order_shimmer.dart';
import 'package:remixicon/remixicon.dart';
import 'package:intl/intl.dart';

class DeliveryHistoryView extends StatefulWidget {
  const DeliveryHistoryView({super.key});

  @override
  State<DeliveryHistoryView> createState() => _DeliveryHistoryViewState();
}

class _DeliveryHistoryViewState extends State<DeliveryHistoryView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryHistoryViewModel>().fetchDeliveryHistory();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<DeliveryHistoryViewModel>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final viewModel = context.watch<DeliveryHistoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Delivery History'),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.headingText,
          fontSize: R.sp(18),
          fontWeight: FontWeight.w700,
        ),
        leading: const BackButton(color: AppColors.headingText),
      ),
      body: viewModel.isLoading
          ? const Center(
              child: OrderShimmer()) // Reuse shimmer or create unified
          : RefreshIndicator(
              onRefresh: () async {
                await viewModel.fetchDeliveryHistory(refresh: true);
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(R.w(16)),
                  child: Column(
                    children: [
                      if (viewModel.historyData?.summary != null)
                        _buildSummaryStats(viewModel.historyData!.summary),
                      SizedBox(height: R.h(20)),
                      if (viewModel.orders.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.orders.length +
                              (viewModel.isLoadingMore ? 1 : 0),
                          separatorBuilder: (context, index) =>
                              SizedBox(height: R.h(12)),
                          itemBuilder: (context, index) {
                            if (index == viewModel.orders.length) {
                              return const Center(
                                  child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ));
                            }
                            return _buildDeliveryCard(viewModel.orders[index]);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryStats(DeliveryHistorySummary summary) {
    return Row(
      children: [
        Expanded(child: _statCard('Total', '${summary.total}', AppColors.info)),
        SizedBox(width: R.w(10)),
        Expanded(
            child: _statCard(
                'Completed',
                '${summary.completed}',
                AppColors
                    .primaryGreen)), // Assuming primaryGreen matches success
        SizedBox(width: R.w(10)),
        Expanded(
            child: _statCard(
                'Cancelled', '${summary.cancelled}', AppColors.warning)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: R.h(16), horizontal: R.w(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: R.sp(20),
              fontWeight: FontWeight.w800,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: R.h(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: R.sp(12),
              color: AppColors.bodyText.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Order order) {
    // Simplified card for history
    return Container(
      padding: EdgeInsets.all(R.w(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
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
                'Order #${order.orderNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: R.sp(14),
                  color: AppColors.headingText,
                ),
              ),
              _statusChip(order.status),
            ],
          ),
          SizedBox(height: R.h(8)),
          Row(
            children: [
              Icon(Remix.time_line, size: R.sp(14), color: AppColors.bodyText),
              SizedBox(width: R.w(4)),
              Text(
                DateFormat('MMM dd, yyyy  hh:mm a')
                    .format(order.createdAt ?? DateTime.now()),
                style: TextStyle(
                  fontSize: R.sp(12),
                  color: AppColors.bodyText.withOpacity(0.8),
                ),
              ),
            ],
          ),
          ...[
          SizedBox(height: R.h(8)),
          Text(
            '₹${order.totalAmount}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: R.sp(14),
              color: AppColors.primaryGreen,
            ),
          ),
        ]
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = AppColors.primaryGreen;
        break;
      case 'cancelled':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.info;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(R.r(4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: R.sp(10),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: R.h(40)),
        child: Column(
          children: [
            Icon(Remix.inbox_line, size: R.sp(60), color: AppColors.hintText),
            SizedBox(height: R.h(16)),
            Text(
              'No deliveries found',
              style: TextStyle(
                fontSize: R.sp(16),
                color: AppColors.bodyText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
