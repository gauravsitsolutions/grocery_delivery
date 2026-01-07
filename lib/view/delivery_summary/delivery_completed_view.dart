import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lottie/lottie.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/agent_bottom_nav_item.dart';

class DeliverySummaryView extends StatefulWidget {
  const DeliverySummaryView({super.key});

  @override
  State<DeliverySummaryView> createState() => _DeliverySummaryViewState();
}

class _DeliverySummaryViewState extends State<DeliverySummaryView> {
  final InAppReview _inAppReview = InAppReview.instance;
  int rating = 4;

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
        leading: const BackButton(color: AppColors.headingText),
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
    return Container(
      width: R.r(120),
      height: R.r(120),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        // Removed border as Lottie usually looks better without it or has its own
      ),
      child: Lottie.asset(
        'assets/lottie/success_check.json',
        width: R.r(120),
        height: R.r(120),
        fit: BoxFit.contain,
        repeat: false, // Usually success animations run once
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
        'Order #2938 • 2:30 PM',
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
                  color: AppColors.softGreyBg,
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
            '₹ 14.50',
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
                'Base: ₹ 10.00',
                style: TextStyle(
                  fontSize: R.sp(14),
                  color: AppColors.bodyText,
                ),
              ),
              SizedBox(width: R.w(8)),
              Text('•', style: TextStyle(color: AppColors.bodyText)),
              SizedBox(width: R.w(8)),
              Text(
                'Tip: ₹ 4.50',
                style: TextStyle(
                  fontSize: R.sp(14),
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
            backgroundImage: const NetworkImage(
              'https://randomuser.me/api/portraits/women/44.jpg',
            ),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alice M.',
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  '123 Main St, Apt 4B',
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
                'ID: #938122',
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
                    'Grocery Delivery',
                    style: TextStyle(
                      fontSize: R.sp(15),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    '2 Bags • 15 Items',
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          Text(
            'Whole Wheat Bread, Organic Eggs (12ct), Almond Milk, '
            'Bananas (x5), Avocados...',
            style: TextStyle(
              fontSize: R.sp(14),
              color: AppColors.bodyText,
            ),
          ),
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AgentBottomNavView(),
            ),
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
          'Rate Delivery Agent',
          style: TextStyle(
            fontSize: R.sp(20),
            fontWeight: FontWeight.w700,
            color: AppColors.headingText,
          ),
        ),
        SizedBox(height: R.h(8)),
        Text(
          'How was your experience with Alice?',
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
              onPressed: () async {
                setState(() => rating = i + 1);
                if (rating == 5) await _requestReview();
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
            _chip('Easy Parking'),
            _chip('Tip Received'),
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
        color: selected ? AppColors.softGreyBg : AppColors.white,
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

  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
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
