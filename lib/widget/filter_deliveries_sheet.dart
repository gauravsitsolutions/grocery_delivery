import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';

class FilterDeliveriesSheet extends StatefulWidget {
  const FilterDeliveriesSheet({super.key});

  @override
  State<FilterDeliveriesSheet> createState() => _FilterDeliveriesSheetState();
}

class _FilterDeliveriesSheetState extends State<FilterDeliveriesSheet> {
  String date = 'Today';
  String status = 'Pending';
  String type = 'Standard';

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.7,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8F6),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(R.r(24)),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: R.h(10)),

              // Handle
              Container(
                width: R.w(48),
                height: R.h(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(R.r(6)),
                ),
              ),

              SizedBox(height: R.h(16)),

              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Filter Deliveries',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: R.sp(20),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: R.w(48)),
                ],
              ),

              const Divider(),

              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: EdgeInsets.all(R.w(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Title('Date Range'),
                      Wrap(
                        spacing: R.w(12),
                        children: [
                          _dateChip('Today'),
                          _dateChip('Yesterday'),
                          _dateChip('Last 7 Days'),
                        ],
                      ),
                      SizedBox(height: R.h(24)),
                      const _Title('Order Status'),
                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: R.h(12),
                        crossAxisSpacing: R.w(12),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _statusCard('Pending', RemixIcons.time_line),
                          _statusCard(
                              'Delivered', RemixIcons.checkbox_circle_line),
                          _statusCard(
                              'Cancelled', RemixIcons.close_circle_line),
                          _statusCard('On Route', RemixIcons.truck_line),
                        ],
                      ),
                      SizedBox(height: R.h(24)),
                      const _Title('Delivery Type'),
                      _deliveryTile(
                        'Express Delivery',
                        'Under 30 mins',
                        Icons.rocket_launch,
                        'Express',
                      ),
                      SizedBox(height: R.h(12)),
                      _deliveryTile(
                        'Standard Delivery',
                        'Regular Schedule',
                        Icons.inventory_2,
                        'Standard',
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(R.w(16)),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            date = 'Today';
                            status = 'Pending';
                            type = 'Standard';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: R.h(16)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(14)),
                          ),
                        ),
                        child: const Text(
                          'Clear Filters',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          padding: EdgeInsets.symmetric(vertical: R.h(16)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(14)),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- Widgets ----------------

  Widget _dateChip(String label) {
    final active = date == label;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => setState(() => date = label),
      selectedColor: AppColors.primaryGreen,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: active ? Colors.black : Colors.grey.shade700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(R.r(24)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _statusCard(String label, IconData icon) {
    final active = status == label;
    return GestureDetector(
      onTap: () => setState(() => status = label),
      child: Container(
        padding: EdgeInsets.all(R.w(14)),
        decoration: BoxDecoration(
          color:
              active ? AppColors.primaryGreen.withOpacity(.15) : Colors.white,
          borderRadius: BorderRadius.circular(R.r(16)),
          border: Border.all(
            color: active ? AppColors.primaryGreen : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      active ? AppColors.primaryGreen : Colors.grey.shade300,
                  child: Icon(icon, color: Colors.black),
                ),
                const Spacer(),
                if (active)
                  CircleAvatar(
                    radius: R.r(10),
                    backgroundColor: AppColors.primaryGreen,
                    child: Icon(Icons.check, size: R.sp(14), color: Colors.black),
                  ),
              ],
            ),
            SizedBox(height: R.h(16)),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: R.sp(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
  ) {
    final active = type == value;
    return GestureDetector(
      onTap: () => setState(() => type = value),
      child: Container(
        padding: EdgeInsets.all(R.w(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(16)),
          border: Border.all(
            color: active ? AppColors.primaryGreen : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: active
                  ? AppColors.primaryGreen.withOpacity(.2)
                  : Colors.grey.shade200,
              child: Icon(icon, color: Colors.black),
            ),
            SizedBox(width: R.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: R.sp(16),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: R.sp(14),
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              CircleAvatar(
                radius: R.r(12),
                backgroundColor: AppColors.primaryGreen,
                child: Icon(Icons.circle, size: R.sp(10), color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- TITLE ----------------

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(12)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: R.sp(18),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
