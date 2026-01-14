import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/model/notification_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/notifications_view_model.dart';
import 'package:intl/intl.dart';
import 'package:samrudhi_delivery_agent_app/widget/animated_order_card.dart';
import 'package:samrudhi_delivery_agent_app/widget/notification_shimmer.dart';
import '../../../constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_retry_button.dart';
import '../../../utils/responsive.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _animatingIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().fetchNotifications(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationsViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: _appBar(),
      body: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, child) {
          return _buildContent(viewModel);
        },
      ),
    );
  }

  Widget _buildContent(NotificationsViewModel viewModel) {
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return const NotificationListShimmer();
    }

    if (viewModel.error != null && viewModel.notifications.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                RemixIcons.error_warning_line,
                size: R.sp(60),
                color: AppColors.grey,
              ),
              SizedBox(height: R.h(16)),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: R.sp(18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingText,
                ),
              ),
              SizedBox(height: R.h(8)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(40)),
                child: Text(
                  viewModel.error ?? 'Unknown error occurred',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.sp(14),
                    color: AppColors.bodyText.withValues(alpha: 0.7),
                  ),
                ),
              ),
              SizedBox(height: R.h(24)),
              CustomRetryButton(
                onTap: () => viewModel.fetchNotifications(refresh: true),
                isLoading: viewModel.isLoading,
              ),
            ],
          ),
        ),
      );
    }

    final notifications =
        viewModel.notifications; // Use all notifications directly

    if (notifications.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Stack
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: R.w(280),
                    height: R.w(280),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.02),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: R.w(200),
                    height: R.w(200),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: Stack(children: [
                      Icon(RemixIcons.notification_off_line,
                          size: R.sp(80), color: AppColors.primaryGreen),
                      Positioned(
                        top: R.h(15),
                        left: R.w(15),
                        child: Transform.rotate(
                            angle: -0.5,
                            child: Container(
                                color: AppColors.white, width: 2, height: 60)),
                      )
                    ])),
                  ),
                ],
              ),
              SizedBox(height: R.h(24)),
              Text(
                'All caught up!',
                style: TextStyle(
                  fontSize: R.sp(22),
                  color: AppColors.headingText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: R.h(12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(60)),
                child: Text(
                  'No new notifications for you at the moment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.sp(14),
                    height: 1.5,
                    color: AppColors.bodyText.withValues(alpha: 0.7),
                  ),
                ),
              ),
              SizedBox(height: R.h(32)),
            ],
          ),
        ),
      );
    }

    // Split into Today and Earlier
    final now = DateTime.now();
    final today = notifications.where((n) {
      final date = n.createdAt;
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();

    final earlier = notifications.where((n) {
      final date = n.createdAt;
      return !(date.year == now.year &&
          date.month == now.month &&
          date.day == now.day);
    }).toList();

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.all(R.w(16)),
      children: [
        if (today.isNotEmpty) ...[
          _sectionHeader('TODAY'),
          SizedBox(height: R.h(12)),
          ...today.map((n) => Padding(
                padding: EdgeInsets.only(bottom: R.h(12)),
                child: AnimatedOrderCard(
                  key: ValueKey(n.id),
                  visible: !_animatingIds.contains(n.id),
                  child: _mapNotificationToCard(n),
                ),
              )),
          SizedBox(height: R.h(12)),
        ],
        if (earlier.isNotEmpty) ...[
          _sectionHeader('EARLIER'),
          SizedBox(height: R.h(12)),
          ...earlier.map((n) => Padding(
                padding: EdgeInsets.only(bottom: R.h(12)),
                child: AnimatedOrderCard(
                  key: ValueKey(n.id),
                  child: _mapNotificationToCard(n),
                ),
              )),
        ],
        if (viewModel.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: NotificationShimmer(),
          ),
        SizedBox(height: R.h(40)),
      ],
    );
  }

  Widget _mapNotificationToCard(NotificationModel notification) {
    // Determine icon and colors based on type
    IconData icon = Icons.notifications;
    Color iconColor = AppColors.primaryGreen;
    Color iconBg = AppColors.primaryGreen.withValues(alpha: .15);

    if (notification.type?.toLowerCase().contains('order') ?? false) {
      icon = RemixIcons.truck_fill;
      iconColor = AppColors.primaryGreen; // Hex #10C971 approx
      iconBg = AppColors.primaryGreen.withValues(alpha: .15);
    } else if (notification.type?.toLowerCase().contains('system') ?? false) {
      icon = RemixIcons.notification_4_fill;
      iconColor = AppColors.info; // Blue
      iconBg = AppColors.info.withValues(alpha: .15);
    } else if (notification.type?.toLowerCase().contains('cancel') ?? false) {
      // Assuming 'cancel' type
      icon = RemixIcons.alert_fill;
      iconColor = AppColors.error; // Red
      iconBg = AppColors.error.withValues(alpha: .15);
    } else if (notification.type?.toLowerCase().contains('update') ?? false) {
      icon = RemixIcons.map_pin_user_fill;
      iconColor = AppColors.warning; // Orange
      iconBg = AppColors.warning.withValues(alpha: .15);
    }

    return _notificationCard(
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      title: notification.title,
      time: _formatTime(notification.createdAt),
      message: notification.message,
      unread: !notification.isRead,
      onTap: () async {
        if (_animatingIds.contains(notification.id)) return;

        setState(() {
          _animatingIds.add(notification.id);
        });

        // Wait for animation
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          context.read<NotificationsViewModel>().markAsRead(notification.id);
          setState(() {
            _animatingIds.remove(notification.id);
          });
        }
      },
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }

  // ================= APP BAR =================

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldBg,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: BackButton(),
      title: Text(
        'Notifications',
        style: TextStyle(
          fontSize: R.sp(20),
          fontWeight: FontWeight.w800,
          color: AppColors.headingText,
        ),
      ),
      actions: [
        Consumer<NotificationsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.notifications.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(right: R.w(16)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      viewModel.clearAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notifications cleared'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              // Undo logic if needed, currently viewmodel restores on error but we might want explicit undo
                              viewModel.fetchNotifications(refresh: true);
                            },
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: R.sp(14),
                        color: AppColors.bodyText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.w(8)),
                    child: Text(
                      '|',
                      style: TextStyle(color: AppColors.borderLight),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => viewModel.markAllRead(),
                    child: Text(
                      'Mark all as read',
                      style: TextStyle(
                        fontSize: R.sp(14),
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ================= SECTION HEADER =================

  Widget _sectionHeader(String title, {String? action}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.bodyText,
            fontSize: R.sp(13),
          ),
        ),
        const Spacer(),
        if (action != null)
          Text(
            action,
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w700,
              fontSize: R.sp(13),
            ),
          ),
      ],
    );
  }

  // ================= NORMAL NOTIFICATION =================

  Widget _notificationCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String time,
    required String message,
    bool unread = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(R.w(16)),
        decoration: BoxDecoration(
          color: unread
              ? AppColors.primaryGreen.withValues(alpha: 0.05)
              : AppColors.white,
          // Removed bottom border for cleaner look in list
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _icon(icon, iconColor, bg: iconBg),
            SizedBox(width: R.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: R.sp(15),
                            color: AppColors.headingText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: AppColors.bodyText.withValues(alpha: 0.6),
                          fontSize: R.sp(11),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(4)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: AppColors.bodyText.withValues(alpha: 0.8),
                            fontSize: R.sp(13),
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          margin: EdgeInsets.only(left: R.w(8)),
                          width: R.w(8),
                          height: R.w(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _icon(IconData icon, Color color, {Color? bg}) {
    return Container(
      width: R.w(48),
      height: R.w(48),
      decoration: BoxDecoration(
        color: bg ?? color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(R.r(14)),
      ),
      child: Center(
        child: Icon(icon, color: color, size: R.sp(22)),
      ),
    );
  }
}
