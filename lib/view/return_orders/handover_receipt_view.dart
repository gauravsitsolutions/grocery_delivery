import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class HandoverReceiptView extends StatelessWidget {
  final String orderId;

  const HandoverReceiptView({
    super.key,
    this.orderId = 'ORD-8832',
  });

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(R.w(8)),
          child: CircleAvatar(
            backgroundColor: AppColors.white,
            child: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: AppColors.headingText, size: R.sp(20)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Handover Receipt',
          style: TextStyle(
            color: AppColors.headingText,
            fontSize: R.sp(18),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(16)),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(R.r(16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(R.w(20)),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(R.w(16)),
                decoration: BoxDecoration(
                  color: AppColors.paleGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(RemixIcons.store_2_fill,
                    color: AppColors.primaryGreen, size: R.sp(32)),
              ),
              SizedBox(height: R.h(16)),
              Text(
                'GreenGrocer Central Hub',
                style: TextStyle(
                  fontSize: R.sp(20),
                  fontWeight: FontWeight.w800,
                  color: AppColors.headingText,
                ),
              ),
              SizedBox(height: R.h(8)),
              Text(
                'RETURN #$orderId',
                style: TextStyle(
                  fontSize: R.sp(14),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: R.h(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(RemixIcons.calendar_line,
                      size: R.sp(14), color: Colors.grey),
                  SizedBox(width: R.w(4)),
                  Text(
                    'Oct 24, 2023',
                    style: TextStyle(fontSize: R.sp(12), color: Colors.grey),
                  ),
                  SizedBox(width: R.w(12)),
                  Icon(RemixIcons.time_line,
                      size: R.sp(14), color: Colors.grey),
                  SizedBox(width: R.w(4)),
                  Text(
                    '02:45 PM',
                    style: TextStyle(fontSize: R.sp(12), color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: R.h(24)),
              Divider(color: Colors.grey.shade200),
              SizedBox(height: R.h(16)),

              // Returned Items
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'RETURNED ITEMS',
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: R.h(12)),
              _buildReceiptItem('Milk (1L) x1', 'Condition: Good'),
              _buildReceiptItem('Whole Wheat Bread x1', 'Condition: Intact'),
              _buildReceiptItem('Organic Eggs (12pk) x1', 'Condition: Checked'),

              SizedBox(height: R.h(24)),
              Divider(
                color: Colors.grey.shade200,
                thickness:
                    1, // Mimicking dotted line with thickness or perhaps using a Row of dots instead if needed, but for now just fix the error. The error was invalid param 'style'.
              ),
              // Actually the code below it draws the dots: List.generate... Text("-").
              // So maybe I just remove the Divider if it was meant to be invisible?
              // The code has a Divider AND a Row of dashes.
              // Let's just fix the Divider.

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                    20,
                    (index) => Text("-",
                        style: TextStyle(color: Colors.grey.shade300))),
              ),
              SizedBox(height: R.h(24)),

              // Signatures
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: R.h(60),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.accentYellow.withValues(
                                alpha: 0.1), // Orange/yellowish tint
                            borderRadius: BorderRadius.circular(R.r(8)),
                            // In real app, put SVG signature here
                          ),
                          child: Center(
                              child: Text("Signature",
                                  style: TextStyle(
                                      fontFamily: 'Cursive',
                                      color: AppColors.accentYellow))),
                        ),
                        SizedBox(height: R.h(8)),
                        Text('DELIVERY AGENT',
                            style: TextStyle(
                                fontSize: R.sp(10),
                                color: Colors.grey,
                                fontWeight: FontWeight.w700)),
                        Text('John Doe',
                            style: TextStyle(
                                fontSize: R.sp(12),
                                color: AppColors.headingText,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  SizedBox(width: R.w(16)),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: R.h(60),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A7C7C)
                                .withValues(alpha: 0.1), // Greenish tint
                            borderRadius: BorderRadius.circular(R.r(8)),
                          ),
                          child: Center(
                              child: Text("Signature",
                                  style: TextStyle(
                                      fontFamily: 'Cursive',
                                      color: Color(0xFF4A7C7C)))),
                        ),
                        SizedBox(height: R.h(8)),
                        Text('WAREHOUSE MANAGER',
                            style: TextStyle(
                                fontSize: R.sp(10),
                                color: Colors.grey,
                                fontWeight: FontWeight.w700)),
                        Text('Sarah Smith',
                            style: TextStyle(
                                fontSize: R.sp(12),
                                color: AppColors.headingText,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: R.h(32)),

              // QR Code
              Container(
                padding: EdgeInsets.all(R.w(16)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(R.r(16)),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Container(
                  height: R.w(120),
                  width: R.w(120),
                  color: Colors.black, // Placeholder for QR
                  alignment: Alignment.center,
                  child: Container(
                    height: R.w(110),
                    width: R.w(110),
                    color: Colors.white,
                    child: Icon(Icons.qr_code_2, size: R.w(100)),
                  ),
                ),
              ),
              SizedBox(height: R.h(8)),
              Text(
                'SCAN TO LOG ENTRY',
                style: TextStyle(
                  fontSize: R.sp(10),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade400,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(R.w(16)),
        decoration: BoxDecoration(
          color: AppColors.white,
        ),
        child: SafeArea(
          // No shadow on bottom for receipt usually, or minimal
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Save as PDF Button
              SizedBox(
                width: double.infinity,
                height: R.h(50),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: AppColors.white, size: R.sp(20)),
                      SizedBox(width: R.w(8)),
                      Text(
                        'Save as PDF',
                        style: TextStyle(
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: R.h(16)),
              // Print Receipt Button
              GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(RemixIcons.printer_fill,
                        size: R.sp(18), color: AppColors.headingText),
                    SizedBox(width: R.w(8)),
                    Text(
                      'Print Receipt',
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w700,
                        color: AppColors.headingText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.h(8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptItem(String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: R.h(12)),
      padding: EdgeInsets.all(R.w(12)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(R.r(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(R.w(8)),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check,
                color: AppColors.primaryGreen, size: R.sp(16)),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.headingText,
                  ),
                ),
                SizedBox(height: R.h(2)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: R.sp(12),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(R.r(4)),
            ),
            child: Text(
              'VERIFIED',
              style: TextStyle(
                fontSize: R.sp(10),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
