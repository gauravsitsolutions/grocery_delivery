import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:remixicon/remixicon.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_network_image.dart';
import 'package:samrudhi_delivery_agent_app/constant/app_color.dart';
import 'package:samrudhi_delivery_agent_app/view/navigation_view/navigation_view.dart';
import 'package:samrudhi_delivery_agent_app/utils/responsive.dart';
import 'package:samrudhi_delivery_agent_app/widget/custom_toggle_button.dart';
import 'package:samrudhi_delivery_agent_app/model/order_model.dart';
import 'package:samrudhi_delivery_agent_app/view_model/order_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as dev;

import 'package:samrudhi_delivery_agent_app/widget/custom_back_button.dart';

class CustomerInfoView extends StatefulWidget {
  final int? orderId;
  final Order? order;
  const CustomerInfoView({super.key, this.orderId, this.order});

  @override
  State<CustomerInfoView> createState() => _CustomerInfoViewState();
}

class _CustomerInfoViewState extends State<CustomerInfoView> {
  bool _localInstructionsRead = false;

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return ChangeNotifierProvider(
      create: (_) => OrderViewModel(
          orderId: widget.orderId ?? widget.order?.id ?? 0,
          initialOrder: widget.order)
        ..fetchOrderDetails(),
      child: Consumer<OrderViewModel>(
        builder: (context, viewModel, child) {
          final order = viewModel.order;

          if (viewModel.isLoading && order == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (order == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(child: Text('Order not found')),
            );
          }

          // Debug logging
          dev.log('=== ORDER DATA DEBUG ===');
          dev.log('Order ID: ${order.id}');
          dev.log('Delivery Address: ${order.deliveryAddress}');
          if (order.deliveryAddress != null) {
            dev.log('  - addressLine1: ${order.deliveryAddress!.addressLine1}');
            dev.log('  - addressLine2: ${order.deliveryAddress!.addressLine2}');
            dev.log('  - city: ${order.deliveryAddress!.city}');
            dev.log('  - state: ${order.deliveryAddress!.state}');
            dev.log('  - postcode: ${order.deliveryAddress!.postcode}');
          }
          dev.log('Order Items Count: ${order.orderItems.length}');
          if (order.orderItems.isNotEmpty) {
            final firstItem = order.orderItems.first;
            dev.log('First Item:');
            dev.log('  - name: ${firstItem.product?.name}');
            dev.log('  - price: ${firstItem.price}');
            dev.log('  - total: ${firstItem.total}');
            dev.log('  - lineTotal: ${firstItem.lineTotal}');
            dev.log(
                '  - product.retailerPrice: ${firstItem.product?.retailerPrice}');
          }
          dev.log('========================');

          final instructionsRead =
              viewModel.hasReadInstructions || _localInstructionsRead;

          return Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              centerTitle: true,
              leading: const CustomBackButton(color: AppColors.headingText),
              title: Column(
                children: [
                  Text(
                    'Delivery Details',
                    style: TextStyle(
                      color: AppColors.headingText,
                      fontWeight: FontWeight.w800,
                      fontSize: R.sp(18),
                    ),
                  ),
                  Text(
                    '#${order.orderNumber}',
                    style: TextStyle(
                      color: AppColors.bodyText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: R.sp(13),
                    ),
                  ),
                ],
              ),
            ),
            body: RefreshIndicator(
              onRefresh: viewModel.fetchOrderDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    EdgeInsets.fromLTRB(R.w(16), R.h(16), R.w(16), R.h(150)),
                child: Column(
                  children: [
                    _customerCard(order),
                    SizedBox(height: R.h(16)),
                    _mapCard(order),
                    SizedBox(height: R.h(16)),
                    _instructionCard(viewModel),
                    SizedBox(height: R.h(24)),
                    _orderHeader(order),
                    SizedBox(height: R.h(12)),
                    if (order.orderItems.isEmpty)
                      const Center(child: Text('No items found'))
                    else
                      ...order.orderItems.map((item) => _orderItem(
                            item.product?.name ?? 'Unknown Item',
                            '${item.quantity}${item.product?.unitValue ?? ''} • ${_getItemPrice(item)}',
                            (item.product?.productImageUrls.isNotEmpty == true)
                                ? item.product!.productImageUrls.first
                                : '',
                            qty: 'x${item.quantity}',
                          )),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(R.w(16), R.h(8), R.w(16), R.h(16)),
                color: AppColors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: R.h(56),
                      child: ElevatedButton(
                        onPressed: instructionsRead
                            ? () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: NavigationView(
                                    order: order,
                                    orderId: order.id,
                                  ),
                                  withNavBar: false,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade200,
                          disabledForegroundColor: Colors.grey.shade500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(28)),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'START DELIVERY',
                              style: TextStyle(
                                fontSize: R.sp(16),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: R.w(8)),
                            Icon(RemixIcons.arrow_right_line, size: R.sp(20)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _customerCard(Order order) {
    return Container(
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: R.r(35),
                    backgroundColor:
                        AppColors.primaryGreen.withValues(alpha: 0.1),
                    child: Text(
                      order.user?.fullName.substring(0, 1).toUpperCase() ?? 'C',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: R.sp(24),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(R.w(4)),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        RemixIcons.checkbox_circle_fill,
                        color: Colors.white,
                        size: R.sp(16),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: R.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.user?.fullName ?? 'Customer',
                      style: TextStyle(
                        fontSize: R.sp(20),
                        fontWeight: FontWeight.w800,
                        color: AppColors.headingText,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(10), vertical: R.h(4)),
                      decoration: BoxDecoration(
                        color: Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(R.r(8)),
                      ),
                      child: Text(
                        'Primary Customer',
                        style: TextStyle(
                          fontSize: R.sp(11),
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  final phone = order.user?.mobile;
                  if (phone != null) {
                    final url = Uri.parse('tel:$phone');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  }
                },
                child: CircleAvatar(
                  radius: R.r(24),
                  backgroundColor: AppColors.primaryGreen,
                  child: Icon(
                    RemixIcons.phone_fill,
                    color: Colors.white,
                    size: R.sp(22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapCard(Order order) {
    final address = order.deliveryAddress;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(R.r(32)),
                child: Image.asset(
                  'assets/images/map_placeholder.png',
                  height: R.h(220),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: CircleAvatar(
                    radius: R.r(24),
                    backgroundColor: Colors.white,
                    child: Icon(
                      RemixIcons.map_pin_2_fill,
                      color: AppColors.primaryGreen,
                      size: R.sp(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(R.w(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DROP-OFF POINT',
                  style: TextStyle(
                    color: AppColors.bodyText.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                    fontSize: R.sp(11),
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: R.h(8)),
                Text(
                  _buildAddress(address),
                  style: TextStyle(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.w700,
                    color: AppColors.headingText,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructionCard(OrderViewModel viewModel) {
    final hasInstructions =
        viewModel.order?.deliveryInstructions?.isNotEmpty == true;
    final isRead = viewModel.hasReadInstructions || _localInstructionsRead;

    return Container(
      padding: EdgeInsets.all(R.w(20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF9E6),
            const Color(0xFFFFF3D6),
          ],
        ),
        borderRadius: BorderRadius.circular(R.r(24)),
        border: Border.all(
          color: const Color(0xFFFFE4A3).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB800).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(R.w(10)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(R.r(12)),
                ),
                child: Icon(
                  RemixIcons.information_fill,
                  color: const Color(0xFFD97706),
                  size: R.sp(20),
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DELIVERY INSTRUCTIONS',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF92400E),
                        fontSize: R.sp(12),
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (hasInstructions)
                      Text(
                        'Please read carefully',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD97706).withValues(alpha: 0.7),
                          fontSize: R.sp(11),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: R.h(16)),

          // Instructions Content
          Container(
            padding: EdgeInsets.all(R.w(16)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(R.r(16)),
              border: Border.all(
                color: const Color(0xFFFFE4A3).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: R.h(2)),
                  padding: EdgeInsets.all(R.w(4)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB800).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    RemixIcons.chat_quote_line,
                    size: R.sp(14),
                    color: const Color(0xFFD97706),
                  ),
                ),
                SizedBox(width: R.w(10)),
                Expanded(
                  child: Text(
                    hasInstructions
                        ? viewModel.order!.deliveryInstructions!
                        : 'No specific instructions provided for this delivery.',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w600,
                      color: hasInstructions
                          ? AppColors.headingText
                          : AppColors.bodyText.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: R.h(16)),

          // Confirmation Toggle
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: R.w(16),
              vertical: R.h(12),
            ),
            decoration: BoxDecoration(
              color: isRead
                  ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(R.r(16)),
              border: Border.all(
                color: isRead
                    ? const Color(0xFF16A34A).withValues(alpha: 0.3)
                    : const Color(0xFFFFE4A3).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isRead
                      ? RemixIcons.checkbox_circle_fill
                      : RemixIcons.checkbox_blank_circle_line,
                  color: isRead
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD97706).withValues(alpha: 0.5),
                  size: R.sp(20),
                ),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Text(
                    'I have read and understood the instructions',
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w700,
                      color: isRead
                          ? const Color(0xFF16A34A)
                          : AppColors.headingText,
                    ),
                  ),
                ),
                SizedBox(width: R.w(8)),
                RemixIconToggle(
                  value: isRead,
                  onChanged: (v) {
                    setState(() => _localInstructionsRead = v);
                    viewModel.hasReadInstructions = v;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderHeader(Order order) {
    return Row(
      children: [
        Text(
          'Order Items (${order.orderItems.length})',
          style: TextStyle(fontSize: R.sp(18), fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Text(
          'Total: ₹${order.totalAmount}',
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
            child: SizedBox(
              width: R.w(56),
              height: R.h(56),
              child: image.isNotEmpty
                  ? CustomNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                    )
                  : _noImagePlaceholder(),
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
        ],
      ),
    );
  }

  Widget _noImagePlaceholder() {
    return Container(
      width: R.w(56),
      height: R.h(56),
      color: AppColors.borderLight,
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported, size: R.sp(24)),
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

  String _getItemPrice(OrderItem item) {
    // Try to use the price field first
    if (item.price != null &&
        item.price!.isNotEmpty &&
        item.price != '0.00' &&
        item.price != '0') {
      return '₹${item.price}';
    }

    // Fallback to total if price is not available
    if (item.total.isNotEmpty && item.total != '0.00' && item.total != '0') {
      return '₹${item.total}';
    }

    // Fallback to lineTotal if available
    if (item.lineTotal != null &&
        item.lineTotal!.isNotEmpty &&
        item.lineTotal != '0.00' &&
        item.lineTotal != '0') {
      return '₹${item.lineTotal}';
    }

    // Last resort: check product price
    if (item.product?.retailerPrice != null &&
        item.product!.retailerPrice.isNotEmpty &&
        item.product!.retailerPrice != '0.00') {
      return '₹${item.product!.retailerPrice}';
    }

    return '₹0.00';
  }
}
