import 'package:flutter/material.dart';

import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';
import 'package:samrudhi_delivery_agent_app/view/verification/verification_view.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/widgets/delivery_progress_timeline.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/widgets/customer_details_card.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/widgets/order_manifest_section.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/widgets/payment_collection_card.dart';
import 'package:intl/intl.dart';

class NavigationView extends StatelessWidget {
  final int? orderId;
  final Order? order;
  const NavigationView({super.key, this.orderId, this.order});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9),
      body: Column(
        children: [
          // ================= CUSTOM APP BAR =================
          Container(
            padding: EdgeInsets.fromLTRB(
                R.w(16), topInset + R.h(8), R.w(16), R.h(16)),
            color: Colors.white,
            child: Row(
              children: [
                const CustomBackButton(color: Colors.black),
                SizedBox(width: R.w(12)),
                Flexible(
                  child: Text(
                    'Order #${order?.orderNumber ?? '00000'}',
                    style: TextStyle(
                      fontSize: R.sp(20),
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(12), vertical: R.h(6)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF7F1),
                    borderRadius: BorderRadius.circular(R.w(12)),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: R.sp(12),
                      fontWeight: FontWeight.w800,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= SCROLLABLE CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(R.w(20)),
              child: Column(
                children: [
                  DeliveryProgressTimeline(
                    pickedUpTime: order != null
                        ? DateFormat('hh:mm a').format(order!.createdAt)
                        : 'Today, 10:30 AM',
                    isReachedLocation: false,
                  ),
                  SizedBox(height: R.h(24)),
                  CustomerDetailsCard(
                    name: order?.user?.fullName ?? 'Unknown Customer',
                    membershipType: 'Premium Member',
                    address:
                        order?.deliveryAddress?.addressLine1 ?? 'No Address',
                    profileImage: order?.user?.profilePhoto,
                    onCall: () async {
                      final phone = order?.user?.mobile;
                      if (phone != null) {
                        final url = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      }
                    },
                    onMessage: () async {
                      final phone = order?.user?.mobile;
                      if (phone != null) {
                        final url = Uri.parse('sms:$phone');
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      }
                    },
                  ),
                  SizedBox(height: R.h(24)),
                  OrderManifestSection(
                    items: order?.orderItems ?? [],
                  ),
                  SizedBox(height: R.h(24)),
                  PaymentCollectionCard(
                    totalAmount: order?.totalAmount ?? '0',
                    paymentMethod: order?.paymentMethod ?? 'COD',
                  ),
                  SizedBox(height: R.h(40)),
                ],
              ),
            ),
          ),

          // ================= BOTTOM BUTTON =================
          Container(
            padding: EdgeInsets.fromLTRB(R.w(20), R.h(10), R.w(20), R.h(10)),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: SizedBox(
                width: double.infinity,
                height: R.h(55),
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
                    backgroundColor: const Color(0xFF00FF85),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.w(32)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: R.sp(20)),
                      SizedBox(width: R.w(12)),
                      Flexible(
                        child: Text(
                          'Mark as Arrived',
                          style: TextStyle(
                            fontSize: R.sp(18),
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
