import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/view/return_orders/handover_receipt_view.dart';

class ItemsHandoverView extends StatefulWidget {
  final String orderId;

  const ItemsHandoverView({
    super.key,
    this.orderId = '8832',
  });

  @override
  State<ItemsHandoverView> createState() => _ItemsHandoverViewState();
}

class _ItemsHandoverViewState extends State<ItemsHandoverView> {
  // Mock data for items
  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Organic Milk x1',
      'reason': 'Damaged Packaging',
      'image':
          'https://via.placeholder.com/150', // Replace with asset or network image
      'isSelected': true,
    },
    {
      'name': 'Bell Peppers x3',
      'reason': 'Quality issue',
      'image': 'https://via.placeholder.com/150',
      'isSelected': false,
    },
    {
      'name': 'Greek Yogurt x2',
      'reason': 'Wrong Item',
      'image': 'https://via.placeholder.com/150',
      'isSelected': false,
    },
  ];

  String? _selectedManager;
  final List<String> _managers = ['Sarah Smith', 'Mike Johnson', 'Emily Davis'];

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
        title: Column(
          children: [
            Text(
              'Items Handover',
              style: TextStyle(
                color: AppColors.headingText,
                fontSize: R.sp(18),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: R.h(2)),
            Text(
              'ORDER #${widget.orderId}',
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
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Instructions Card
            Container(
              padding: EdgeInsets.all(R.w(16)),
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
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(R.w(8)),
                        decoration: BoxDecoration(
                          color: AppColors.paleGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(RemixIcons.information_fill,
                            color: AppColors.headingText, size: R.sp(20)),
                      ),
                      SizedBox(width: R.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Handover Instructions',
                              style: TextStyle(
                                fontSize: R.sp(16),
                                fontWeight: FontWeight.w700,
                                color: AppColors.headingText,
                              ),
                            ),
                            SizedBox(height: R.h(4)),
                            Text(
                              'Please verify all items with the warehouse manager before finalizing the return.',
                              style: TextStyle(
                                fontSize: R.sp(13),
                                color: AppColors.primaryGreen,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: R.h(16)),
                  SizedBox(
                    width: double.infinity,
                    height: R.h(45),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen, // Bright green
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.r(25)),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'View Return Protocol',
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w700,
                          color: AppColors
                              .headingText, // Dark text on bright green button? Image looks like dark text.
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: R.h(24)),

            // 2. Checklist Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Return Items Checklist',
                  style: TextStyle(
                    fontSize: R.sp(18),
                    fontWeight: FontWeight.w800,
                    color: AppColors.headingText,
                  ),
                ),
                Text(
                  '${_items.length} Items total',
                  style: TextStyle(
                    fontSize: R.sp(12),
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: R.h(16)),

            // 3. Checklist Items
            ..._items.map((item) {
              int index = _items.indexOf(item);
              return Container(
                margin: EdgeInsets.only(bottom: R.h(12)),
                padding: EdgeInsets.all(R.w(12)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(R.r(20)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Item Image Placeholder
                    Container(
                      width: R.w(60),
                      height: R.w(60),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(item['image']), // Placeholder
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                              fontSize: R.sp(16),
                              fontWeight: FontWeight.w700,
                              color: AppColors.headingText,
                            ),
                          ),
                          SizedBox(height: R.h(4)),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: R.w(8), vertical: R.h(2)),
                            decoration: BoxDecoration(
                              color: AppColors.paleGreen,
                              borderRadius: BorderRadius.circular(R.r(8)),
                            ),
                            child: Text(
                              'Reason: ${item['reason']}',
                              style: TextStyle(
                                fontSize: R.sp(12),
                                color:
                                    AppColors.primaryGreen, // Darker green text
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _items[index]['isSelected'] =
                              !_items[index]['isSelected'];
                        });
                      },
                      child: Container(
                        width: R.w(28),
                        height: R.w(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item['isSelected']
                              ? AppColors.primaryGreen
                              : Colors.transparent,
                          border: Border.all(
                            color: item['isSelected']
                                ? AppColors.primaryGreen
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: item['isSelected']
                            ? Icon(Icons.check,
                                size: R.sp(18), color: Colors.white)
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: R.h(24)),

            // 4. Handover Sign-off
            Text(
              'Handover Sign-off',
              style: TextStyle(
                fontSize: R.sp(18),
                fontWeight: FontWeight.w800,
                color: AppColors.headingText,
              ),
            ),
            SizedBox(height: R.h(16)),

            Text(
              'Receiving Manager Name',
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(height: R.h(8)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: R.w(16)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(R.r(30)),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedManager,
                  hint: Text('Select Manager',
                      style: TextStyle(color: AppColors.headingText)),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: AppColors.bodyText),
                  items: _managers.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedManager = newValue;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: R.h(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manager Signature',
                  style: TextStyle(
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen, // Label color
                  ),
                ),
                Text(
                  'CLEAR',
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            SizedBox(height: R.h(8)),
            Container(
              height: R.h(150),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(R.r(24)),
                border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle
                        .solid), // Should be dashed strictly speaking, but solid is fine for basic
              ),
              // Placeholder for Signature Pad
              child: Center(
                child: Text(
                  'Sign within this area',
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: R.sp(16),
                  ),
                ),
              ),
            ),

            SizedBox(height: R.h(32)),
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
              SizedBox(
                width: double.infinity,
                height: R.h(56),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HandoverReceiptView()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(30)),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Complete Handover',
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(12)),
              Text(
                'DIGITAL CONFIRMATION REQUIRED BY STORE POLICY',
                style: TextStyle(
                  fontSize: R.sp(10),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                  letterSpacing: 0.5,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
