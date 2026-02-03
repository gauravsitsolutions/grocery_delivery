import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:intl/intl.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';

class DeliveryCompletedView extends StatefulWidget {
  final Order? order;
  const DeliveryCompletedView({super.key, this.order});

  @override
  State<DeliveryCompletedView> createState() => _DeliveryCompletedViewState();
}

class _DeliveryCompletedViewState extends State<DeliveryCompletedView> {
  final InAppReview _inAppReview = InAppReview.instance;
  int rating = 5;

  Future<void> _requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    } catch (e) {
      debugPrint('In-app review error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: const CustomBackButton(color: AppColors.headingText),
        centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
        title: Text(
          'Summary',
          style: TextStyle(
            fontSize: R.sp(18),
            fontWeight: FontWeight.w700,
            color: AppColors.headingText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          R.w(16),
          R.h(16),
          R.w(16),
          R.h(40),
        ),
        child: Column(
          children: [
            _successIcon(),
            SizedBox(height: R.h(24)),
            _title(),
            SizedBox(height: R.h(12)),
            _orderMeta(),
            SizedBox(height: R.h(24)),
            _earningsCard(),
            SizedBox(height: R.h(16)),
            _mapSection(),
            SizedBox(height: R.h(16)),
            _customerCard(),
            SizedBox(height: R.h(16)),
            _orderSummary(),
            SizedBox(height: R.h(24)),
            _primaryButton(),
            SizedBox(height: R.h(32)),
            _ratingSection(),
            SizedBox(height: R.h(40)),
          ],
        ),
      ),
    );
  }

  // ================= SUCCESS =================

  Widget _successIcon() {
    return AvatarGlow(
      glowColor: AppColors.primaryGreen,
      glowRadiusFactor: 0.4,
      duration: const Duration(milliseconds: 2000),
      repeat: true,
      child: Container(
        width: R.w(100),
        height: R.w(100),
        decoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x4010C971),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: R.w(50),
            height: R.w(50),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              RemixIcons.check_line,
              color: AppColors.primaryGreen,
              size: R.sp(32),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return Text(
      'Delivery Completed!',
      style: TextStyle(
        fontSize: R.sp(26),
        fontWeight: FontWeight.w800,
        color: AppColors.headingText,
      ),
    );
  }

  Widget _orderMeta() {
    final timeStr = widget.order?.deliveredAt != null
        ? DateFormat('h:mm a').format(widget.order!.deliveredAt!)
        : DateFormat('h:mm a').format(DateTime.now());

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.w(16),
        vertical: R.h(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
      ),
      child: Text(
        'Order #${widget.order?.orderNumber ?? '0000'} • $timeStr',
        style: TextStyle(
          fontSize: R.sp(14),
          color: AppColors.bodyText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= EARNINGS =================

  Widget _earningsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'TOTAL EARNINGS',
                style: TextStyle(
                  fontSize: R.sp(13),
                  color: AppColors.bodyText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: R.w(12),
                  vertical: R.h(6),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(R.r(20)),
                ),
                child: Text(
                  'PAID',
                  style: TextStyle(
                    fontSize: R.sp(12),
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          Text(
            '₹ ${widget.order?.totalAmount ?? '0.00'}',
            style: TextStyle(
              fontSize: R.sp(36),
              fontWeight: FontWeight.w800,
              color: AppColors.headingText,
            ),
          ),
          SizedBox(height: R.h(8)),
          Row(
            children: [
              Text(
                'Subtotal: ₹ ${widget.order?.totalAmount ?? '0.00'}',
                style: TextStyle(
                  fontSize: R.sp(14),
                  color: AppColors.bodyText,
                ),
              ),
              const Spacer(),
              Text(
                'Payment: ${widget.order?.paymentMethod ?? 'Online'}',
                style: TextStyle(
                  fontSize: R.sp(14),
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= MAP SECTION =================

  Widget _mapSection() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(R.r(20)),
              topRight: Radius.circular(R.r(20)),
            ),
            child: Image.asset(
              'assets/images/map_placeholder.png',
              width: double.infinity,
              height: R.h(150),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(R.w(16)),
            child: Row(
              children: [
                Icon(RemixIcons.map_pin_2_fill,
                    color: AppColors.primaryGreen, size: R.sp(20)),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Route',
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingText,
                        ),
                      ),
                      Text(
                        'Route tracked successfully',
                        style: TextStyle(
                          fontSize: R.sp(12),
                          color: AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.w(10),
                    vertical: R.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withAlpha(20),
                    borderRadius: BorderRadius.circular(R.r(12)),
                  ),
                  child: Text(
                    '2.4 KM',
                    style: TextStyle(
                      fontSize: R.sp(12),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= CUSTOMER =================

  Widget _customerCard() {
    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: R.r(26),
            backgroundColor: AppColors.primaryGreen.withAlpha(30),
            child: Text(
              widget.order?.user?.fullName.substring(0, 1).toUpperCase() ?? 'C',
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
                  widget.order?.user?.fullName ?? 'Customer',
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  widget.order?.deliveryAddress?.addressLine1 ?? 'No address',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.sp(14),
                    color: AppColors.bodyText,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: AppColors.borderLight,
            radius: R.r(20),
            child: Icon(
              RemixIcons.home_2_fill,
              color: AppColors.headingText,
              size: R.sp(18),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ORDER =================

  Widget _orderSummary() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ORDER SUMMARY',
                style: TextStyle(
                  fontSize: R.sp(13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText,
                ),
              ),
              const Spacer(),
              Text(
                'ID: #${widget.order?.orderNumber ?? '0000'}',
                style: TextStyle(
                  fontSize: R.sp(13),
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.softGreyBg,
                radius: R.r(20),
                child: Icon(
                  Icons.shopping_bag,
                  color: AppColors.primaryGreen,
                  size: R.sp(20),
                ),
              ),
              SizedBox(width: R.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Delivered',
                    style: TextStyle(
                      fontSize: R.sp(15),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    '${widget.order?.orderItems.length ?? 0} Items',
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (widget.order?.orderItems.isNotEmpty == true) ...[
            SizedBox(height: R.h(12)),
            Text(
              widget.order!.orderItems
                  .map((e) => e.product?.name ?? 'Item')
                  .join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: R.sp(14),
                color: AppColors.bodyText,
              ),
            ),
          ]
        ],
      ),
    );
  }

  // ================= BUTTON =================

  Widget _primaryButton() {
    return SizedBox(
      width: double.infinity,
      height: R.h(56),
      child: ElevatedButton(
        onPressed: () async {
          await _requestReview();
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/', // Splash or main entry
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(R.r(16)),
          ),
        ),
        child: Text(
          'Complete & Go Online',
          style: TextStyle(
            fontSize: R.sp(18),
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  // ================= RATING =================

  Widget _ratingSection() {
    return Column(
      children: [
        Text(
          'Rate Customer',
          style: TextStyle(
            fontSize: R.sp(20),
            fontWeight: FontWeight.w700,
            color: AppColors.headingText,
          ),
        ),
        SizedBox(height: R.h(8)),
        Text(
          'How was your experience with ${widget.order?.user?.fullName ?? 'the customer'}?',
          style: TextStyle(
            fontSize: R.sp(14),
            color: AppColors.bodyText,
          ),
        ),
        SizedBox(height: R.h(16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            return IconButton(
              onPressed: () {
                setState(() => rating = i + 1);
              },
              icon: Icon(
                RemixIcons.star_fill,
                size: R.sp(32),
                color:
                    i < rating ? AppColors.primaryGreen : AppColors.borderLight,
              ),
            );
          }),
        ),
        SizedBox(height: R.h(12)),
        Wrap(
          spacing: R.w(10),
          children: [
            _chip('Friendly', selected: true),
            _chip('Quick Handover'),
            _chip('Easy to Find'),
          ],
        ),
      ],
    );
  }

  Widget _chip(String text, {bool selected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: R.w(16),
        vertical: R.h(12),
      ),
      decoration: BoxDecoration(
        color:
            selected ? AppColors.primaryGreen.withAlpha(20) : AppColors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
        border: Border.all(
          color: selected ? AppColors.primaryGreen : AppColors.borderLight,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: R.sp(14),
          color: selected ? AppColors.primaryGreen : AppColors.headingText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= CARD =================

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: R.r(12),
          ),
        ],
      ),
      child: child,
    );
  }
}
