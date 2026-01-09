import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/routes/app_routes.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_toggle_button.dart';
import 'package:samrudhi_delivery_agent_app/widget/slide_to_complete_widget.dart';

class CustomerInfoView extends StatefulWidget {
  const CustomerInfoView({super.key});

  @override
  State<CustomerInfoView> createState() => _CustomerInfoViewState();
}

class _CustomerInfoViewState extends State<CustomerInfoView> {
  bool instructionsRead = false;

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
        leading: const BackButton(color: AppColors.headingText),
        title: Text(
          'Order #48291',
          style: TextStyle(
            color: AppColors.headingText,
            fontWeight: FontWeight.w700,
            fontSize: R.sp(20),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: R.w(16)),
            child: Icon(
              RemixIcons.customer_service_fill,
              color: AppColors.headingText,
              size: R.sp(24),
            ),
          ),
        ],
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(R.w(16), R.h(16), R.w(16), R.h(150)),
        child: Column(
          children: [
            _customerCard(),
            SizedBox(height: R.h(16)),
            _mapCard(),
            SizedBox(height: R.h(16)),
            _instructionCard(),
            SizedBox(height: R.h(24)),
            _orderHeader(),
            SizedBox(height: R.h(12)),
            _orderItem(
              'Organic Bananas',
              '1 bunch • ₹2.49',
              'https://images.unsplash.com/photo-1574226516831-e1dff420e37b?w=400',
            ),
            _orderItem(
              'Whole Milk',
              '1 gallon • ₹4.99',
              'https://images.unsplash.com/photo-1585238342028-4bbc0d77b7aa?w=400',
            ),
            _orderItem(
              'Sourdough Bread',
              'Sliced • ₹5.49',
              'https://images.unsplash.com/photo-1608198093002-de2b4f20b7b8?w=400',
            ),
          ],
        ),
      ),

      // ================= BOTTOM =================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(R.w(16), R.h(8), R.w(16), R.h(16)),
          color: AppColors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Verify all items before completing order',
                style: TextStyle(
                  color: AppColors.bodyText,
                  fontSize: R.sp(13),
                ),
              ),
              SizedBox(height: R.h(12)),
              SlideToCompleteWidget(
                enabled: instructionsRead,
                onCompleted: () {
                  Navigator.pushNamed(context, AppRoutes.navigationView);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CUSTOMER =================

  Widget _customerCard() {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: R.r(28),
                backgroundImage: const NetworkImage(
                  'https://randomuser.me/api/portraits/women/44.jpg',
                ),
              ),
              SizedBox(width: R.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sarah Jenkins',
                    style: TextStyle(
                      fontSize: R.sp(18),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    'Customer since 2021',
                    style: TextStyle(
                      color: AppColors.bodyText,
                      fontSize: R.sp(13),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: RemixIcons.phone_line,
                  label: 'Call',
                  bg: AppColors.primaryGreen,
                  textColor: AppColors.white,
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: _actionButton(
                  icon: RemixIcons.message_3_line,
                  label: 'Message',
                  bg: AppColors.borderLight,
                  textColor: AppColors.headingText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= MAP =================

  Widget _mapCard() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(R.r(20))),
                child: Image.network(
                  'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?w=900',
                  height: R.h(170),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: R.w(16),
                bottom: R.h(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISTANCE',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: R.sp(12),
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      '2.4 km • 15 mins',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: R.sp(18),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(R.w(16)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DROP-OFF LOCATION',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(12),
                        ),
                      ),
                      SizedBox(height: R.h(6)),
                      Text(
                        '1234 Green Street, Apt 4B',
                        style: TextStyle(
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: R.h(4)),
                      Text(
                        'San Francisco, CA 94109',
                        style: TextStyle(color: AppColors.bodyText),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: AppColors.borderLight,
                  child: Icon(
                    Icons.navigation,
                    color: AppColors.black,
                    size: R.sp(24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= INSTRUCTIONS =================

  Widget _instructionCard() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFFF7E0), // alert bg (can move to AppColors later)
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppColors.headingText, size: R.sp(24)),
              SizedBox(width: R.w(8)),
              Text(
                'DELIVERY INSTRUCTIONS',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingText,
                  fontSize: R.sp(14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Gate Code: 1234. Please do not ring the doorbell, baby is sleeping.',
            style: TextStyle(fontSize: R.sp(14)),
          ),
          SizedBox(height: R.h(12)),
          Row(
            children: [
              Expanded(
                key: const ValueKey('instruction_checkbox'),
                child: Text(
                  'I have read the instructions',
                  style: TextStyle(fontSize: R.sp(14)),
                ),
              ),
              RemixIconToggle(
                value: instructionsRead,
                onChanged: (v) => setState(() => instructionsRead = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ORDER =================

  Widget _orderHeader() {
    return Row(
      children: [
        Text(
          'Order Items (5)',
          style: TextStyle(fontSize: R.sp(18), fontWeight: FontWeight.w700),
        ),
        Spacer(),
        Text(
          'Est. Earnings: ₹18.50',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w700,
            fontSize: R.sp(14),
          ),
        ),
      ],
    );
  }

  Widget _orderItem(
    String title,
    String subtitle,
    String image, {
    String qty = 'x1',
  }) {
    return _card(
      margin: EdgeInsets.only(top: R.h(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(R.r(12)),
            child: Image.network(
              image,
              width: R.w(56),
              height: R.h(56),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: R.w(56),
                height: R.h(56),
                color: AppColors.borderLight,
                alignment: Alignment.center,
                child: Icon(Icons.image_not_supported, size: R.sp(24)),
              ),
            ),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  subtitle,
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
          SizedBox(width: R.w(12)),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(6)),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(R.r(10)),
            ),
            child: Text(
              qty,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: R.sp(14)),
            ),
          ),
          SizedBox(width: R.w(12)),
          Container(
            width: R.w(24),
            height: R.h(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(R.r(6)),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color bg,
    required Color textColor,
  }) {
    return Container(
      height: R.h(48),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(R.r(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: R.sp(18), color: textColor),
          SizedBox(width: R.w(8)),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
              fontSize: R.sp(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}
