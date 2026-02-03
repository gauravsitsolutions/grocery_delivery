import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view/return_orders/handover_receipt_view.dart';
import 'package:samrudhi_delivery_agent_app/view/return_orders/items_handover_view.dart';

class ReturningToStoreView extends StatefulWidget {
  final String returnId;
  final bool showBackButton;

  const ReturningToStoreView({
    super.key,
    this.returnId = '#RTN-9921',
    this.showBackButton = true,
  });

  @override
  State<ReturningToStoreView> createState() => _ReturningToStoreViewState();
}

class _ReturningToStoreViewState extends State<ReturningToStoreView> {
  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.showBackButton
            ? Padding(
                padding: EdgeInsets.all(R.w(8)),
                child: CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: AppColors.headingText, size: R.sp(20)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              )
            : null,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Returning to Store',
              style: TextStyle(
                color: AppColors.headingText,
                fontSize: R.sp(18),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: R.h(2)),
            Text(
              'ID: ${widget.returnId}',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: R.sp(12),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: R.w(16)),
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              child: IconButton(
                icon: Icon(RemixIcons.question_mark,
                    color: AppColors.headingText, size: R.sp(20)),
                onPressed: () {
                  // Help action
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(16)),
        child: Column(
          children: [
            // 1. Central Distribution Hub Card
            Container(
              padding: EdgeInsets.all(R.w(20)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(R.r(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(R.w(12)),
                        decoration: BoxDecoration(
                          color: AppColors.paleGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                            RemixIcons
                                .share_line, // Using share/connect icon as approx for molecule
                            color: AppColors.primaryGreen,
                            size: R.sp(24)),
                      ),
                      SizedBox(width: R.w(16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Central Distribution Hub',
                              style: TextStyle(
                                fontSize: R.sp(18),
                                fontWeight: FontWeight.w800,
                                color: AppColors.headingText,
                              ),
                            ),
                            SizedBox(height: R.h(4)),
                            Text(
                              'Main Logistics Park',
                              style: TextStyle(
                                fontSize: R.sp(14),
                                color: AppColors.bodyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(20)),
                  Row(
                    children: [
                      Icon(RemixIcons.map_pin_fill,
                          color: AppColors.bodyText, size: R.sp(20)),
                      SizedBox(width: R.w(12)),
                      Expanded(
                        child: Text(
                          '123 Logistics Way, Sector 4\nNorth Industrial Zone, 560012',
                          style: TextStyle(
                            fontSize: R.sp(14),
                            color: AppColors.headingText,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(20)),
                  Divider(color: AppColors.divider.withValues(alpha: 0.5)),
                  SizedBox(height: R.h(12)),
                  GestureDetector(
                    onTap: _openMap,
                    child: Row(
                      children: [
                        Icon(RemixIcons.direction_fill,
                            color: AppColors.primaryGreen, size: R.sp(20)),
                        SizedBox(width: R.w(8)),
                        Text(
                          'Open in Maps',
                          style: TextStyle(
                            fontSize: R.sp(14),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: R.h(20)),

            // 2. Arrival Instructions Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(R.w(20)),
              decoration: BoxDecoration(
                color: AppColors.paleGreen, // Keeping it green as per image
                borderRadius: BorderRadius.circular(R.r(24)),
                border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(RemixIcons.information_fill,
                          color: AppColors.primaryGreen, size: R.sp(18)),
                      SizedBox(width: R.w(8)),
                      Text(
                        'ARRIVAL INSTRUCTIONS',
                        style: TextStyle(
                          fontSize: R.sp(12),
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(12)),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: R.sp(20),
                        fontWeight: FontWeight.w800,
                        color: AppColors.headingText,
                        height: 1.2,
                        fontFamily: 'Outfit', // Assuming default font
                      ),
                      children: [
                        const TextSpan(text: 'Head to Returns Desk\n'),
                        TextSpan(
                          text: '— Section 4',
                          style: TextStyle(color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: R.h(12)),
                  Text(
                    'Use the Rear Service Entrance (Gate B) for all return items.',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      color: AppColors.bodyText, // Darker text on light green
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: R.h(20)),

            // 3. Store Manager Card
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(16)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.circular(R.r(40)), // High radius pill shape
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: R.w(50),
                    height: R.w(50),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E3B2F), // Dark bg for logo
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Icon(RemixIcons.store_2_fill,
                        color: Colors.white70, size: R.sp(24)),
                    // In real app, use CustomNetworkImage(imageUrl: managerAvatar)
                  ),
                  SizedBox(width: R.w(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STORE MANAGER',
                          style: TextStyle(
                            fontSize: R.sp(10),
                            fontWeight: FontWeight.w800,
                            color: AppColors.bodyText,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: R.h(2)),
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w700,
                            color: AppColors.headingText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]),
                    child: IconButton(
                      onPressed: _callManager,
                      icon: Icon(RemixIcons.phone_fill,
                          color: Colors.white, size: R.sp(24)),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: R.h(40)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(R.w(16)),
        decoration: BoxDecoration(color: AppColors.white, boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ]),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Print Handover Receipt Button
              SizedBox(
                width: double.infinity,
                height: R.h(50),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HandoverReceiptView()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppColors.grey.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(30)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(RemixIcons.printer_fill,
                          color: AppColors.headingText, size: R.sp(18)),
                      SizedBox(width: R.w(8)),
                      Text(
                        'Print Handover Receipt',
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.headingText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: R.h(12)),

              // Arrived at Store Button
              SizedBox(
                width: double.infinity,
                height: R.h(56),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ItemsHandoverView()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(30)),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Arrived at Store',
                        style: TextStyle(
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(width: R.w(8)),
                      Icon(RemixIcons.checkbox_circle_fill,
                          color: AppColors.white, size: R.sp(20)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMap() async {
    // Placeholder location
    const lat = 12.9716;
    const lng = 77.5946;
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch maps')));
      }
    }
  }

  Future<void> _callManager() async {
    final uri = Uri.parse('tel:+919876543210'); // Placeholder number
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not make call')));
      }
    }
  }
}
