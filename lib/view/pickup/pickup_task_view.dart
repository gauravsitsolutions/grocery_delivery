import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:samrudhi_delivery_agent_app/utils/custom_snackbar.dart';
import 'package:samrudhi_delivery_agent_app/view/order_details/order_details_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class PickupTaskView extends StatefulWidget {
  final Order order;

  const PickupTaskView({super.key, required this.order});

  @override
  State<PickupTaskView> createState() => _PickupTaskViewState();
}

class _PickupTaskViewState extends State<PickupTaskView> {
  final Set<int> _selectedItemIds = {};
  File? _pickupProof;

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool get _canProceed =>
      _selectedItemIds.length == widget.order.orderItems.length &&
      _pickupProof != null;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _pickupProof = File(image.path);
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openMap(String address) async {
    // Encode the address for the query parameter
    final query = Uri.encodeComponent(address);
    final googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$query";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    }
  }

  void _toggleItem(int id) {
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Light gray background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: R.sp(20)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'PICKUP TASK',
              style: TextStyle(
                color: Colors.black,
                fontSize: R.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '#${widget.order.orderNumber}',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: R.sp(12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: R.w(16),
              right: R.w(16),
              top: R.h(16),
              bottom: R.h(100), // Space for bottom button
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationCard(),
                SizedBox(height: R.h(24)),
                _buildItemChecklist(),
                SizedBox(height: R.h(24)),
                _buildPickupProof(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(R.w(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: R.h(50),
                child: ElevatedButton(
                  onPressed:
                      _canProceed && !_isLoading ? _handleConfirmPickup : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor:
                        AppColors.primaryGreen.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(25)),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm & Start Delivery',
                        style: TextStyle(
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_canProceed) ...[
                        SizedBox(width: R.w(8)),
                        Icon(RemixIcons.checkbox_circle_fill,
                            color: Colors.white, size: R.sp(20)),
                      ],
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

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(R.w(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PICKUP LOCATION',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: R.sp(11),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: R.h(8)),
                Text(
                  widget.order.vendor?.storeName ?? 'Warehouse Bay 4B',
                  style: TextStyle(
                    color: const Color(0xFF1F2937),
                    fontSize: R.sp(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  widget.order.vendor?.address ??
                      'Avenue 5, Logistics Park, Sector 12',
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontSize: R.sp(14),
                  ),
                ),
                SizedBox(height: R.h(16)),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Use vendor address or a default one
                          final address = widget.order.vendor?.address ??
                              'Avenue 5, Logistics Park, Sector 12';
                          _openMap(address);
                        },
                        icon: Icon(RemixIcons.map_2_fill, size: R.sp(18)),
                        label: const Text('Show on Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: R.h(12)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(30)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.h(12)),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // Use vendor mobile or a default
                          _makePhoneCall(
                              widget.order.vendor?.mobile ?? '1234567890');
                        },
                        icon: Icon(RemixIcons.phone_fill,
                            color: const Color(0xFF1F2937), size: R.sp(18)),
                        label: Text(
                          'Call Manager',
                          style: TextStyle(
                            color: const Color(0xFF1F2937),
                            fontWeight: FontWeight.w600,
                            fontSize: R.sp(14),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          padding: EdgeInsets.symmetric(vertical: R.h(12)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(30)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map Placeholder Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(R.r(20)),
              bottomRight: Radius.circular(R.r(20)),
            ),
            child: SizedBox(
              height: R.h(120),
              width: double.infinity,
              child: Image.asset(
                'assets/images/map_placeholder.png', // Needs to be generated/added
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                      color: Colors.grey[200],
                      child:
                          Center(child: Icon(Icons.map, color: Colors.grey)));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemChecklist() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ITEM CHECKLIST',
              style: TextStyle(
                color: const Color(0xFF1F2937),
                fontSize: R.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(R.r(6)),
              ),
              child: Text(
                '${widget.order.orderItems.length} ITEMS',
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: R.sp(11),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: R.h(16)),
        ...widget.order.orderItems.map((item) {
          final isSelected = _selectedItemIds.contains(item.id);
          return Padding(
            padding: EdgeInsets.only(bottom: R.h(12)),
            child: Theme(
              data: ThemeData(
                  checkboxTheme: CheckboxThemeData(
                shape: CircleBorder(),
                side: BorderSide(color: Colors.grey[300]!, width: 2),
              )),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(16)),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.5))
                      : null,
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (val) => _toggleItem(item.id),
                  activeColor: AppColors.primaryGreen,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: R.w(16), vertical: R.h(6)),
                  secondary: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    radius: R.r(24),
                    child: Icon(RemixIcons.shopping_bag_3_fill,
                        color: Colors.grey[400], size: R.sp(20)),
                  ),
                  title: Text(
                    item.product?.name ?? 'Product Item',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  subtitle: Text(
                    'Qty: ${item.quantity}',
                    style: TextStyle(
                      fontSize: R.sp(13),
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPickupProof() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PICKUP PROOF',
          style: TextStyle(
            color: const Color(0xFF1F2937),
            fontSize: R.sp(16),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: R.h(16)),
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(R.r(24)),
          child: Container(
            width: double.infinity,
            height: R.h(180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(R.r(24)),
              border: Border.all(
                color: const Color(0xFFE5E7EB), // Grey 200
                style: BorderStyle.solid,
              ),
            ),
            child: _pickupProof != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(R.r(24)),
                    child: Image.file(
                      _pickupProof!,
                      fit: BoxFit.cover,
                    ),
                  )
                : CustomPaint(
                    painter: DottedBorderPainter(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(R.w(16)),
                          decoration: const BoxDecoration(
                            color: Color(0xFFECFDF5), // Light green
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            RemixIcons.camera_fill,
                            color: AppColors.primaryGreen,
                            size: R.sp(32),
                          ),
                        ),
                        SizedBox(height: R.h(12)),
                        Text(
                          'Take Photo of Items',
                          style: TextStyle(
                            color: const Color(0xFF1F2937),
                            fontSize: R.sp(14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: R.h(4)),
                        Text(
                          'Required to start delivery',
                          style: TextStyle(
                            color: const Color(0xFF9CA3AF),
                            fontSize: R.sp(12),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleConfirmPickup() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Authentication token not found');

      // 1. Upload Proof
      if (_pickupProof != null) {
        await _apiService.uploadPickupProof(
            token, widget.order.id, _pickupProof!);
      }

      // 2. Confirm Pickup
      await _apiService.confirmPickup(token, widget.order.id);

      if (!mounted) return;

      CustomSnackBar.showSuccess(context, 'Pickup confirmed successfully!');

      // Navigate to Order Details (which handles delivery flow)
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: OrderDetailsView(
          orderId: widget.order.id,
          orderNumber: widget.order.orderNumber,
          order: widget.order, // You might want to refresh order here ideally
        ),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, 'Failed to confirm pickup: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB) // Grey 300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final double dashWidth = 8;
    final double dashSpace = 6;
    final double r = 24.0; // Radius matching container

    // Start top center
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(r)));

    // Draw dashed path
    final Path dashedPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
