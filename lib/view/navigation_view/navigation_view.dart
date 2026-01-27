import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/view/verification/verification_view.dart';
import 'package:animations/animations.dart';
import '../../utils/responsive.dart';

class NavigationView extends StatelessWidget {
  const NavigationView({super.key});

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
                color: Colors.grey.shade300,
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
                  child: BackButton(color: AppColors.headingText),
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
      backgroundColor: const Color(0xFFFFEAEA),
      child: Text(
        'SOS',
        style: TextStyle(
          color: Colors.red,
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
              color: Colors.black.withValues(alpha: 0.12),
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
                    'ORDER #5592',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: R.sp(12),
                      color: AppColors.bodyText,
                    ),
                  ),
                  Text(
                    'Navigating to Market St',
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
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(R.r(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.traffic, color: Colors.white, size: R.sp(18)),
          SizedBox(width: R.w(8)),
          Text(
            'Traffic is heavier than usual (+4m)',
            style: TextStyle(color: Colors.white, fontSize: R.sp(13)),
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
            color: Colors.black.withValues(alpha: 0.12),
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
              color: Colors.grey.shade300,
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
              CircleAvatar(
                radius: R.r(22),
                backgroundColor: const Color(0xFFEAF7F0),
                child: Icon(
                  RemixIcons.direction_fill,
                  color: AppColors.primaryGreen,
                  size: R.sp(20),
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
                      'Sarah J.',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: R.sp(16),
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      '1024 Market St, Apt 4B',
                      style: TextStyle(
                        color: AppColors.bodyText,
                        fontSize: R.sp(14),
                      ),
                    ),
                  ],
                ),
              ),
              _circleButton(icon: RemixIcons.phone_line),
              SizedBox(width: R.w(8)),
              _circleButton(icon: RemixIcons.message_3_line),
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
                    '"Leave at front desk, code 4920"',
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
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const VerificationView(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
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
