import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';
import 'package:samrudhi_delivery_agent_app/view/verification/verification_view.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/widgets/delivery_progress_timeline.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/widgets/customer_details_card.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/widgets/order_manifest_section.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/widgets/payment_collection_card.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;

class NavigationView extends StatefulWidget {
  final int? orderId;
  final Order? order;
  const NavigationView({super.key, this.orderId, this.order});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  final ApiService _apiService = ApiService();
  Order? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    if (widget.orderId != null) {
      try {
        // Fetch both details and items to ensure everything is visible
        final results = await Future.wait([
          _apiService.getOrderDetails(widget.orderId!),
          _apiService.getOrderItems(widget.orderId!),
        ]);

        if (mounted) {
          setState(() {
            final orderData = results[0] as Order;
            final items = results[1] as List<OrderItem>;
            // Combine items into order
            _order = orderData.copyWith(orderItems: items);
            _isLoading = false;
          });
        }
      } catch (e) {
        dev.log('Error fetching order details in NavigationView: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _order = widget.order;
          });
        }
      }
    } else {
      setState(() {
        _order = widget.order;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final topInset = MediaQuery.of(context).padding.top;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FBF9),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Debug logging
    dev.log('=== NAVIGATION VIEW ORDER DATA ===');
    dev.log('Order ID: ${_order?.id}');
    dev.log('Delivery Address: ${_order?.deliveryAddress}');
    if (_order?.deliveryAddress != null) {
      dev.log('  - addressLine1: ${_order!.deliveryAddress!.addressLine1}');
      dev.log('  - addressLine2: ${_order!.deliveryAddress!.addressLine2}');
      dev.log('  - city: ${_order!.deliveryAddress!.city}');
      dev.log('  - state: ${_order!.deliveryAddress!.state}');
      dev.log('  - postcode: ${_order!.deliveryAddress!.postcode}');
    }
    dev.log('==================================');

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Order #${_order?.orderNumber ?? widget.order?.orderNumber ?? _order?.id ?? widget.orderId ?? '00000'}',
                        style: TextStyle(
                          fontSize: R.sp(20),
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_order?.id != null)
                        Text(
                          'ID: ${_order?.id}',
                          style: TextStyle(
                            fontSize: R.sp(12),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
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
                    pickedUpTime: _order != null
                        ? DateFormat('hh:mm a').format(_order!.createdAt)
                        : 'Today, 10:30 AM',
                    isReachedLocation: false,
                  ),
                  SizedBox(height: R.h(24)),
                  CustomerDetailsCard(
                    name: _order?.user?.fullName ?? 'Unknown Customer',
                    membershipType: 'Premium Member',
                    address: _buildAddress(_order?.deliveryAddress),
                    profileImage: _order?.user?.profilePhoto,
                    onCall: () async {
                      final phone = _order?.user?.mobile;
                      if (phone != null) {
                        final url = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      }
                    },
                    onMessage: () async {
                      final phone = _order?.user?.mobile;
                      if (phone != null) {
                        final url = Uri.parse('sms:$phone');
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      }
                    },
                  ),
                  SizedBox(height: R.h(24)),
                  OrderManifestSection(
                    items: _order?.orderItems ?? [],
                  ),
                  SizedBox(height: R.h(24)),
                  PaymentCollectionCard(
                    totalAmount: _order?.totalAmount ?? '0',
                    paymentMethod: _order?.paymentMethod ?? 'COD',
                  ),
                  SizedBox(height: R.h(12)),
                ],
              ),
            ),
          ),

          // ================= BOTTOM BUTTON =================
          Container(
            padding: EdgeInsets.fromLTRB(R.w(20), R.h(8), R.w(20), R.h(8)),
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
              child: SizedBox(
                width: double.infinity,
                height: R.h(48),
                child: ElevatedButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: VerificationView(
                        order: _order,
                        orderId: _order?.id,
                      ),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
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

  String _buildAddress(DeliveryAddress? address) {
    if (address == null) return 'Address not available';

    // Build address parts, filtering out empty/null values
    final parts = <String>[];

    if (address.addressLine1.isNotEmpty) {
      parts.add(address.addressLine1);
    }

    if (address.addressLine2 != null && address.addressLine2!.isNotEmpty) {
      parts.add(address.addressLine2!);
    }

    if (address.city.isNotEmpty) {
      parts.add(address.city);
    }

    if (address.state.isNotEmpty) {
      parts.add(address.state);
    }

    if (address.postcode.isNotEmpty) {
      parts.add(address.postcode);
    }

    // If no parts were added, return fallback
    if (parts.isEmpty) {
      return 'Address details not available';
    }

    // Join parts with comma and space
    return parts.join(', ');
  }
}
