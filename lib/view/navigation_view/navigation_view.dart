import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';

class NavigationView extends StatelessWidget {
  final int? orderId;
  final Order? order;
  const NavigationView({super.key, this.orderId, this.order});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // ================= MAP =================
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=1200',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.grey300,
                alignment: Alignment.center,
                child: Icon(Icons.map, size: R.sp(64)),
              ),
            ),
          ),

          // ================= TOP BAR =================
          Positioned(
            top: topInset + R.h(12),
            left: R.w(16),
            right: R.w(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: R.r(24),
                  backgroundColor: AppColors.white,
                  child: const CustomBackButton(color: AppColors.headingText),
                ),
                SizedBox(width: R.w(12)),
                Expanded(child: Center(child: _orderPill())),
                SizedBox(width: R.w(12)),
                _sosButton(),
              ],
            ),
          ),

          // ================= TRAFFIC PILL =================
          Positioned(
            top: topInset + R.h(88),
            left: R.w(40),
            right: R.w(40),
            child: _trafficPill(),
          ),

          // ================= ZOOM CONTROLS =================
          Positioned(
            right: R.w(16),
            top: MediaQuery.of(context).size.height * 0.35,
            child: _zoomControls(),
          ),

          // ================= BOTTOM SHEET =================
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: _bottomSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  // ================= COMMON =================

  Widget _circleButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: R.r(24),
        backgroundColor: AppColors.white,
        child: Icon(icon, color: AppColors.headingText, size: R.sp(22)),
      ),
    );
  }

  Widget _sosButton() {
    return CircleAvatar(
      radius: R.r(24),
      backgroundColor: AppColors.lightRedBg,
      child: Text(
        'SOS',
        style: TextStyle(
          color: AppColors.red,
          fontWeight: FontWeight.w700,
          fontSize: R.sp(14),
        ),
      ),
    );
  }

  // ================= ORDER PILL =================

  Widget _orderPill() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: R.w(260)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.w(14),
          vertical: R.h(10),
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(40)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.12),
              blurRadius: R.r(12),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: R.r(18),
              backgroundColor: AppColors.primaryGreen,
              child: Icon(
                RemixIcons.shopping_bag_3_fill,
                color: AppColors.white,
                size: R.sp(18),
              ),
            ),
            SizedBox(width: R.w(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ORDER #${order?.orderNumber ?? '0000'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: R.sp(12),
                      color: AppColors.bodyText,
                    ),
                  ),
                  Text(
                    'Navigating to ${order?.deliveryAddress?.city ?? 'Customer'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: R.sp(14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TRAFFIC =================

  Widget _trafficPill() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.w(16),
        vertical: R.h(10),
      ),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(R.r(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.traffic, color: AppColors.white, size: R.sp(18)),
          SizedBox(width: R.w(8)),
          Text(
            'Traffic is heavier than usual (+4m)',
            style: TextStyle(color: AppColors.white, fontSize: R.sp(13)),
          ),
        ],
      ),
    );
  }

  // ================= ZOOM =================

  Widget _zoomControls() {
    return Column(
      children: [
        _zoomButton(Icons.add),
        SizedBox(height: R.h(8)),
        _zoomButton(Icons.remove),
      ],
    );
  }

  Widget _zoomButton(IconData icon) {
    return Container(
      width: R.w(44),
      height: R.w(44),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(14)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.12),
            blurRadius: R.r(8),
          ),
        ],
      ),
      child: Icon(icon, size: R.sp(20)),
    );
  }

  // ================= BOTTOM SHEET =================

  Widget _bottomSheet(BuildContext context) {
    final address = order?.deliveryAddress;
    return Container(
      padding: EdgeInsets.fromLTRB(
        R.w(16),
        R.h(8),
        R.w(16),
        R.h(20),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(28))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HANDLE
          Container(
            width: R.w(36),
            height: R.h(4),
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(R.r(4)),
            ),
          ),
          SizedBox(height: R.h(16)),

          // ETA
          Row(
            children: [
              Text(
                '12',
                style: TextStyle(
                  fontSize: R.sp(34),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: R.w(6)),
              Text(
                'min • 2.4 km',
                style: TextStyle(
                  fontSize: R.sp(16),
                  color: AppColors.bodyText,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () async {
                  if (address != null) {
                    final query = Uri.encodeComponent(
                        "${address.addressLine1}, ${address.city}, ${address.postcode}");
                    final url = Uri.parse(
                        "https://www.google.com/maps/search/?api=1&query=$query");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }
                },
                child: CircleAvatar(
                  radius: R.r(22),
                  backgroundColor: AppColors.lightGreenBg,
                  child: Icon(
                    RemixIcons.direction_fill,
                    color: AppColors.primaryGreen,
                    size: R.sp(20),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(4)),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '14:35 Arrival',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: R.sp(14),
              ),
            ),
          ),

          SizedBox(height: R.h(20)),
          const Divider(),

          // CUSTOMER
          Row(
            children: [
              CircleAvatar(
                radius: R.r(26),
                backgroundColor: AppColors.primaryGreen.withAlpha(30),
                child: Text(
                  order?.user?.fullName.substring(0, 1).toUpperCase() ?? 'C',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order?.user?.fullName ?? 'Customer',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: R.sp(16),
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      address?.addressLine1 ?? 'No address',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.bodyText,
                        fontSize: R.sp(14),
                      ),
                    ),
                  ],
                ),
              ),
              _circleButton(
                icon: RemixIcons.phone_line,
                onTap: () async {
                  final phone = order?.user?.mobile;
                  if (phone != null) {
                    final url = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }
                },
              ),
              SizedBox(width: R.w(8)),
              _circleButton(
                icon: RemixIcons.message_3_line,
                onTap: () async {
                  final phone = order?.user?.mobile;
                  if (phone != null) {
                    final url = Uri.parse('sms:$phone');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }
                },
              ),
            ],
          ),

          SizedBox(height: R.h(16)),

          // INSTRUCTIONS
          Container(
            padding: EdgeInsets.all(R.w(14)),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(R.r(14)),
            ),
            child: Row(
              children: [
                Icon(Icons.menu, size: R.sp(20)),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Text(
                    order?.deliveryInstructions?.isNotEmpty == true
                        ? '"${order!.deliveryInstructions}"'
                        : 'No instructions',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: R.sp(14),
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, size: R.sp(20)),
              ],
            ),
          ),

          SizedBox(height: R.h(20)),

          // MARK AS ARRIVED BUTTON
          InkWell(
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.verificationView,
                arguments: order,
              );
            },
            child: Container(
              height: R.h(60),
              margin: EdgeInsets.only(bottom: R.h(8)),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(R.r(18)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.35),
                    blurRadius: R.r(14),
                    offset: Offset(0, R.h(6)),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: R.w(16)),
                  CircleAvatar(
                    radius: R.r(18),
                    backgroundColor: AppColors.white,
                    child: Icon(
                      RemixIcons.check_fill,
                      color: AppColors.primaryGreen,
                      size: R.sp(18),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Mark as Arrived',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: R.sp(18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.double_arrow,
                      color: AppColors.white, size: R.sp(18)),
                  SizedBox(width: R.w(16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
