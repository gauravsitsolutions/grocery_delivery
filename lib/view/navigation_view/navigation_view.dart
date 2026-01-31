import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';

import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';
import 'package:samrudhi_delivery_agent_app/view/verification/verification_view.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(40))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: EdgeInsets.symmetric(vertical: R.h(12)),
            child: Container(
              width: R.w(40),
              height: R.h(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(R.r(2)),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(R.w(20), 0, R.w(20), R.h(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Order',
                    style: TextStyle(
                      fontSize: R.sp(22),
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingText,
                    ),
                  ),
                  SizedBox(height: R.h(20)),

                  // Timeline Section
                  _timelineSection(),
                  SizedBox(height: R.h(24)),

                  // Customer Profile Card
                  _customerProfileCard(),
                  SizedBox(height: R.h(24)),

                  // Order Manifest
                  _orderManifestSection(),
                  SizedBox(height: R.h(24)),

                  // COD Summary Card
                  _codSummaryCard(),
                  SizedBox(height: R.h(32)),

                  // Mark as Arrived Button
                  _markAsArrivedButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineSection() {
    return Row(
      children: [
        _timelineStep(
          title: "Order Picked up",
          isCompleted: true,
          isActive: false,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: AppColors.primaryGreen,
            margin: EdgeInsets.symmetric(horizontal: R.w(8)),
          ),
        ),
        _timelineStep(
          title: "Reach Location",
          isCompleted: false,
          isActive: true,
        ),
      ],
    );
  }

  Widget _timelineStep({
    required String title,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: R.w(24),
          height: R.w(24),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primaryGreen : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted
                  ? AppColors.primaryGreen
                  : (isActive ? AppColors.primaryGreen : Colors.grey.shade300),
              width: 2,
            ),
          ),
          child: isCompleted
              ? Icon(RemixIcons.check_line, color: Colors.white, size: R.sp(14))
              : Center(
                  child: Container(
                    width: R.w(8),
                    height: R.w(8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryGreen
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
        ),
        SizedBox(width: R.w(8)),
        Text(
          title,
          style: TextStyle(
            fontSize: R.sp(14),
            fontWeight:
                isActive || isCompleted ? FontWeight.w800 : FontWeight.w600,
            color: isCompleted
                ? AppColors.primaryGreen
                : (isActive
                    ? AppColors.headingText
                    : AppColors.bodyText.withValues(alpha: 0.5)),
          ),
        ),
      ],
    );
  }

  Widget _customerProfileCard() {
    final address = order?.deliveryAddress;
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(R.r(24)),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: R.r(24),
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                child: Text(
                  order?.user?.fullName.substring(0, 1).toUpperCase() ?? 'C',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: R.sp(18),
                  ),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order?.user?.fullName ?? 'Customer Name',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w800,
                        color: AppColors.headingText,
                      ),
                    ),
                    SizedBox(height: R.h(2)),
                    Text(
                      address?.addressLine1 ?? 'No Address Provided',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.sp(13),
                        color: AppColors.bodyText.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _actionIconCircle(RemixIcons.phone_fill, () async {
                final phone = order?.user?.mobile;
                if (phone != null) {
                  final url = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(url)) await launchUrl(url);
                }
              }),
              SizedBox(width: R.w(8)),
              _actionIconCircle(RemixIcons.message_3_fill, () async {
                final phone = order?.user?.mobile;
                if (phone != null) {
                  final url = Uri.parse('sms:$phone');
                  if (await canLaunchUrl(url)) await launchUrl(url);
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIconCircle(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(R.w(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: R.sp(18)),
      ),
    );
  }

  Widget _orderManifestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER MANIFEST',
          style: TextStyle(
            fontSize: R.sp(11),
            fontWeight: FontWeight.w800,
            color: AppColors.bodyText.withValues(alpha: 0.4),
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: R.h(12)),
        ...?order?.orderItems.map((item) => Padding(
              padding: EdgeInsets.only(bottom: R.h(8)),
              child: Row(
                children: [
                  Container(
                    width: R.w(6),
                    height: R.w(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: R.w(12)),
                  Expanded(
                    child: Text(
                      item.product?.name ?? "Unknown Product",
                      style: TextStyle(
                        fontSize: R.sp(15),
                        fontWeight: FontWeight.w600,
                        color: AppColors.headingText,
                      ),
                    ),
                  ),
                  Text(
                    'x${item.quantity}',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w800,
                      color: AppColors.headingText,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _codSummaryCard() {
    return Container(
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(R.r(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.w(10)),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(RemixIcons.coins_fill,
                    color: AppColors.primaryGreen, size: R.sp(20)),
              ),
              SizedBox(width: R.w(16)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'C.O.D',
                    style: TextStyle(
                      fontSize: R.sp(13),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Text(
                    'Cash on Delivery',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.bodyText.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '₹${order?.totalAmount ?? "0"}',
            style: TextStyle(
              fontSize: R.sp(22),
              fontWeight: FontWeight.w900,
              color: AppColors.headingText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _markAsArrivedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: R.h(60),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(R.r(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationView(
                order: order,
                orderId: order?.id,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(R.r(30)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mark as Arrived',
              style: TextStyle(
                color: Colors.white,
                fontSize: R.sp(18),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: R.w(12)),
            const Icon(RemixIcons.arrow_right_line, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
