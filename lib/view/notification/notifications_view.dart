import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/model/notification_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/notifications_view_model.dart';
import 'package:samrudhi_delivery_agent_app/view/notification_settings/notification_settings_view.dart';
import 'package:intl/intl.dart';
import 'package:samrudhi_delivery_agent_app/widget/animated_order_card.dart';
import 'package:samrudhi_delivery_agent_app/widget/notification_shimmer.dart';
import '../../../constant/app_color.dart';
import '../../../utils/responsive.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  int selectedTab = 0;
  final tabs = ['All', 'Orders', 'Updates', 'System'];
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
          return Column(
            children: [
              _tabs(),
              const Divider(height: 1),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => viewModel.fetchNotifications(refresh: true),
                  color: AppColors.primaryGreen,
                  child: _buildContent(viewModel),
                ),
              ),
            ],
          );
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${viewModel.error}'),
            ElevatedButton(
              onPressed: () => viewModel.fetchNotifications(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final notifications = viewModel.getNotificationsByType(tabs[selectedTab]);

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(RemixIcons.notification_off_line,
                size: R.sp(60), color: AppColors.grey.withValues(alpha: 0.5)),
            SizedBox(height: R.h(16)),
            Text(
              'No notifications found',
              style: TextStyle(
                fontSize: R.sp(16),
                color: AppColors.bodyText,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: R.h(8)),
            Text(
              'Your notifications will appear here',
              style: TextStyle(
                fontSize: R.sp(14),
                color: AppColors.bodyText.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Split into New and Earlier
    final unread = notifications.where((n) => !n.isRead).toList();
    final read = notifications.where((n) => n.isRead).toList();

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.all(R.w(16)),
      children: [
        if (unread.isNotEmpty) ...[
          _sectionHeader('NEW & UNREAD', action: 'Clear all'),
          SizedBox(height: R.h(12)),
          ...unread.map((n) => Padding(
                padding: EdgeInsets.only(bottom: R.h(12)),
                child: AnimatedOrderCard(
                  key: ValueKey(n.id),
                  visible: !_animatingIds.contains(n.id),
                  child: _mapNotificationToCard(n),
                ),
              )),
          SizedBox(height: R.h(12)),
        ],
        if (read.isNotEmpty) ...[
          _sectionHeader('EARLIER'),
          SizedBox(height: R.h(12)),
          ...read.map((n) => Padding(
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
      icon = Icons.shopping_bag;
      iconColor = AppColors.primaryGreen;
      iconBg = AppColors.primaryGreen.withValues(alpha: .15);
    } else if (notification.type?.toLowerCase().contains('system') ?? false) {
      icon = Icons.info;
      iconColor = AppColors.blue;
      iconBg = AppColors.iconBgBlue;
    } else if (notification.type?.toLowerCase().contains('update') ?? false) {
      icon = Icons.map;
      iconColor = AppColors.orange;
      iconBg = AppColors.iconBgOrange;
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
      centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
      title: Text(
        'Notifications',
        style: TextStyle(
          fontSize: R.sp(20),
          fontWeight: FontWeight.w800,
          color: AppColors.headingText,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(RemixIcons.mail_check_line, size: R.sp(22)),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(RemixIcons.settings_3_line, size: R.sp(22)),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => const NotificationSettingsView(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ================= TABS =================

  Widget _tabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(R.w(16), R.h(8), R.w(16), R.h(12)),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = selectedTab == i;
          return Padding(
            padding: EdgeInsets.only(right: R.w(10)),
            child: ChoiceChip(
              label: Text(
                tabs[i],
                style: TextStyle(fontSize: R.sp(14)),
              ),
              selected: selected,
              onSelected: (_) => setState(() => selectedTab = i),
              selectedColor: AppColors.primaryGreen,
              backgroundColor: AppColors.white,
              labelStyle: TextStyle(
                color: selected ? AppColors.white : AppColors.headingText,
                fontWeight: FontWeight.w700,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color:
                      selected ? AppColors.primaryGreen : AppColors.borderLight,
                ),
              ),
            ),
          );
        }),
      ),
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: .04),
              blurRadius: R.r(12),
            ),
          ],
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
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: R.sp(15),
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: AppColors.bodyText,
                          fontSize: R.sp(12),
                        ),
                      ),
                      if (unread)
                        Container(
                          margin: EdgeInsets.only(left: R.w(8)),
                          width: R.w(10),
                          height: R.w(10),
                          decoration: const BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: R.h(6)),
                  Text(
                    message,
                    style: TextStyle(
                      color: AppColors.bodyText,
                      fontSize: R.sp(14),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: R.sp(20)),
          ],
        ),
      ),
    );
  }

  // ================= HELPERS =================

  Widget _icon(IconData icon, Color color, {Color? bg}) {
    return CircleAvatar(
      radius: R.r(26),
      backgroundColor: bg ?? color.withValues(alpha: .15),
      child: Icon(icon, color: color, size: R.sp(20)),
    );
  }
}
